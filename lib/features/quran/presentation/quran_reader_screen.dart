import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../data/models/ayah_bookmark.dart';
import '../data/models/ayah_model.dart';
import '../data/models/surah_model.dart';
import '../data/services/audio_player_service.dart';
import '../providers/quran_providers.dart';
import '../providers/reader_providers.dart';
import 'widgets/audio_player_bar.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surah,
    this.initialAyahIndex,
    this.initialScrollOffset,
  });

  final SurahModel surah;
  final int? initialAyahIndex;
  final double? initialScrollOffset;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final _scrollController = ScrollController();
  final _audioService = AudioPlayerService();

  // Recognizers are re-created only when ayahs list identity changes
  List<TapGestureRecognizer> _recognizers = [];
  List<AyahModel>? _lastAyahList;

  int? _playingIndex;
  bool _isRepeat = false;
  int _visibleAyahNumber = 1;
  Timer? _saveDebounce;
  bool _positionRestored = false;

  static const _kPosPrefixKey = 'reader_pos_';

  bool get _hasBasmala =>
      widget.surah.number != 1 && widget.surah.number != 9;

  String? _basmalUrl(String reciterId) {
    if (!_hasBasmala) return null;
    return 'https://cdn.islamic.network/quran/audio/128/$reciterId/1.mp3';
  }

  @override
  void initState() {
    super.initState();
    initReciterFromPrefs(ref);
    initFontSizeFromPrefs(ref);
    _audioService.displayIndexStream.listen((idx) {
      if (mounted) setState(() => _playingIndex = idx);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    writeLastRead(
      widget.surah.number,
      _visibleAyahNumber,
      scrollOffset: _scrollController.hasClients ? _scrollController.offset : null,
    );
    _clearRecognizers();
    _audioService.stop();
    _audioService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent > 0) {
      final fraction =
          (_scrollController.offset / maxExtent).clamp(0.0, 1.0);
      _visibleAyahNumber =
          ((fraction * widget.surah.numberOfAyahs).floor() + 1)
              .clamp(1, widget.surah.numberOfAyahs);
    }

    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 800),
      () => writeLastRead(
        widget.surah.number,
        _visibleAyahNumber,
        scrollOffset: _scrollController.offset,
      ),
    );
  }

  // ── Recognizer lifecycle ─────────────────────────────────────────────────────

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers = [];
    _lastAyahList = null;
  }

  void _ensureRecognizers(List<AyahModel> ayahs) {
    if (identical(_lastAyahList, ayahs) && _recognizers.length == ayahs.length) {
      return;
    }
    _clearRecognizers();
    _lastAyahList = ayahs;
    for (int i = 0; i < ayahs.length; i++) {
      final idx = i;
      _recognizers
          .add(TapGestureRecognizer()..onTap = () => _onAyahTap(ayahs, idx));
    }
  }

  // ── Position persistence ─────────────────────────────────────────────────────

  Future<void> _restorePosition() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!_scrollController.hasClients) return;

    // Prefer saved scroll offset (accurate) over the ayah-index formula.
    final savedOffset = widget.initialScrollOffset;
    if (savedOffset != null && savedOffset > 0) {
      _scrollController.jumpTo(
        savedOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
      return;
    }

    // Legacy path: approximate from ayah index when no offset is stored.
    final targetIndex = widget.initialAyahIndex;
    if (targetIndex != null && targetIndex > 0) {
      const bannerApprox = 220.0;
      const basmalApprox = 60.0;
      const avgAyahHeight = 75.0;
      final offset = bannerApprox + basmalApprox + targetIndex * avgAyahHeight;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('$_kPosPrefixKey${widget.surah.number}');
    if (saved != null && _scrollController.hasClients) {
      _scrollController.jumpTo(
        saved.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  Future<void> _savePosition() async {
    if (!_scrollController.hasClients) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      '$_kPosPrefixKey${widget.surah.number}',
      _scrollController.offset,
    );
  }

  // Flush all position state before navigating away so callers can await it.
  Future<void> _flushAndLeave(VoidCallback navigate) async {
    _saveDebounce?.cancel();
    final offset =
        _scrollController.hasClients ? _scrollController.offset : null;
    await Future.wait([
      _savePosition(),
      writeLastRead(widget.surah.number, _visibleAyahNumber,
          scrollOffset: offset),
    ]);
    navigate();
  }

  // ── Audio callbacks ──────────────────────────────────────────────────────────

  Future<void> _onReciterChanged(List<AyahModel> ayahs) async {
    final reciterId = ref.read(selectedReciterProvider);
    final args = (widget.surah.number, reciterId);
    ref.invalidate(surahAyahsProvider(args));
    if (_playingIndex != null && _audioService.playing) {
      final wasIndex = _playingIndex!;
      try {
        await _audioService.stop();
        final updated = await ref.read(surahAyahsProvider(args).future);
        await _audioService.play(updated, startIndex: wasIndex);
      } catch (_) {
        // just_audio can throw a platform race condition during reciter switch;
        // the player recovers on the next tap.
      }
    }
  }

  void _onRepeatToggle(List<AyahModel> ayahs) {
    setState(() => _isRepeat = !_isRepeat);
    _audioService.setRepeat(_isRepeat, _playingIndex ?? 0);
  }

  void _onAyahTap(List<AyahModel> ayahs, int index) {
    final reciterId = ref.read(selectedReciterProvider);
    if (_playingIndex == index && _audioService.playing) {
      _audioService.pause();
    } else if (!_audioService.playing && _audioService.displayIndex == null) {
      _audioService.play(
        ayahs,
        startIndex: index,
        basmalUrl: _basmalUrl(reciterId),
      );
    } else {
      _audioService.playFromIndex(index);
    }
  }

  void _toggleBookmark(AyahModel ayah) {
    ref.read(ayahBookmarksProvider.notifier).toggle(AyahBookmark(
      surahNumber: ayah.surahNumber,
      ayahNumberInSurah: ayah.numberInSurah,
      surahName: widget.surah.name,
      ayahText: ayah.text,
      createdAt: DateTime.now(),
    ));
  }

  void _navigateToAdjacentSurah(
      BuildContext context, List<SurahModel> allSurahs, int targetNumber) {
    _audioService.stop();
    final target = allSurahs.firstWhere((s) => s.number == targetNumber);
    _flushAndLeave(() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: target)),
        ));
  }

  void _showFontSizeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundParchment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FontSizeSheet(onChanged: (size) async {
        ref.read(fontSizeProvider.notifier).state = size;
        await persistFontSize(size);
      }),
    );
  }

  // ── Mushaf surah banner ──────────────────────────────────────────────────────

  Widget _buildSurahBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: CustomPaint(
        painter: const _BannerFramePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
          child: Column(
            children: [
              Text(
                'سورة ${widget.surah.name}',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.amiriQuran,
                  fontSize: 22,
                  color: AppColors.mushafBannerCenter,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '◆',
                      style: TextStyle(
                          fontSize: 5,
                          color: AppColors.goldDark.withValues(alpha: 0.7)),
                    ),
                  ),
                  Text(
                    '${widget.surah.numberOfAyahs} آية',
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Basmala ──────────────────────────────────────────────────────────────────

  Widget _buildBasmala() {
    if (!_hasBasmala) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.mushafBasmalaLine.withValues(alpha: 0.45),
                ]),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppFonts.amiriQuran,
                fontSize: 18,
                color: AppColors.mushafText,
                height: 2.2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.mushafBasmalaLine.withValues(alpha: 0.45),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Continuous Mushaf text ────────────────────────────────────────────────────

  // Exact codepoint sequence as returned by the quran-uthmani API edition.
  // shadda (0x651) precedes fatha (0x64e) in "اللَّهِ" — differs from common
  // copy-paste variants where the order is reversed, causing startsWith to fail.
  static const _basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  // Strip the basmala from the first ayah's text when we already render it
  // as a standalone decorative widget above, to avoid it appearing twice.
  String _displayText(int index, AyahModel ayah) {
    if (index != 0 || !_hasBasmala) return ayah.text;
    final trimmed = ayah.text.trimLeft();
    if (trimmed.startsWith(_basmala)) {
      return trimmed.substring(_basmala.length).trimLeft();
    }
    return ayah.text;
  }

  Widget _buildMushafText(
    List<AyahModel> ayahs,
    double fontSize,
    List<AyahBookmark> bookmarks,
  ) {
    _ensureRecognizers(ayahs);

    final spans = <InlineSpan>[];
    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      final isPlaying = _playingIndex == i;
      final isBookmarked = bookmarks.any((b) =>
          b.surahNumber == ayah.surahNumber &&
          b.ayahNumberInSurah == ayah.numberInSurah);

      spans.add(TextSpan(
        text: '${_displayText(i, ayah)} ',
        recognizer: _recognizers[i],
        style: TextStyle(
          fontFamily: AppFonts.amiriQuran,
          fontSize: fontSize,
          color: isPlaying ? AppColors.goldText : AppColors.mushafText,
          height: 2.2,
        ),
      ));

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: _AyahEndMarker(
          number: ayah.numberInSurah,
          isPlaying: isPlaying,
          isBookmarked: isBookmarked,
          onTap: () => _toggleBookmark(ayah),
          fontSize: fontSize,
        ),
      ));

      spans.add(const TextSpan(text: ' '));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text.rich(
        TextSpan(children: spans),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reciterId = ref.watch(selectedReciterProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final ayahsAsync =
        ref.watch(surahAyahsProvider((widget.surah.number, reciterId)));
    final bookmarks = ref.watch(ayahBookmarksProvider);
    final allSurahs = ref.watch(surahListProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundParchment,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.mushafBannerCenter, size: 20),
          onPressed: () =>
              _flushAndLeave(() => Navigator.of(context).pop()),
        ),
        title: Text(
          widget.surah.englishName,
          style: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 15,
            color: AppColors.textMuted,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size,
                color: AppColors.mushafBannerCenter, size: 20),
            onPressed: () => _showFontSizeSheet(context),
          ),
          IconButton(
            icon: Icon(Icons.chevron_left,
                color: widget.surah.number > 1
                    ? AppColors.mushafBannerCenter
                    : AppColors.textMuted,
                size: 24),
            onPressed: widget.surah.number > 1 && allSurahs.isNotEmpty
                ? () => _navigateToAdjacentSurah(
                    context, allSurahs, widget.surah.number - 1)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: widget.surah.number < 114
                    ? AppColors.mushafBannerCenter
                    : AppColors.textMuted,
                size: 24),
            onPressed: widget.surah.number < 114 && allSurahs.isNotEmpty
                ? () => _navigateToAdjacentSurah(
                    context, allSurahs, widget.surah.number + 1)
                : null,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: AppColors.mushafBasmalaLine.withValues(alpha: 0.3),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ayahsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.mushafBannerCenter),
              ),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off,
                        color: AppColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'تعذّر تحميل السورة',
                      style: TextStyle(
                        fontFamily: AppFonts.amiri,
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(surahAyahsProvider(
                          (widget.surah.number, reciterId))),
                      child: const Text('إعادة المحاولة',
                          style: TextStyle(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.goldText)),
                    ),
                  ],
                ),
              ),
              data: (ayahs) {
                if (!_positionRestored) {
                  _positionRestored = true;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _restorePosition());
                }
                return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification) _savePosition();
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      _buildSurahBanner(),
                      _buildBasmala(),
                      _buildMushafText(ayahs, fontSize, bookmarks),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
          ayahsAsync.maybeWhen(
            data: (ayahs) => AudioPlayerBar(
              audioService: _audioService,
              ayahs: ayahs,
              currentIndex: _playingIndex,
              isRepeat: _isRepeat,
              onRepeatToggle: () => _onRepeatToggle(ayahs),
              onReciterChanged: () => _onReciterChanged(ayahs),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Ayah end marker ───────────────────────────────────────────────────────────
// Uses U+06DD (Arabic End of Ayah) — Scheherazade New renders this as the
// authentic ornate circle with the number inside, matching printed Mushaf style.

class _AyahEndMarker extends StatelessWidget {
  const _AyahEndMarker({
    required this.number,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onTap,
    required this.fontSize,
  });

  final int number;
  final bool isPlaying;
  final bool isBookmarked;
  final VoidCallback onTap;
  final double fontSize;

  static const _digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String _toArabic(int n) =>
      n.toString().split('').map((d) => _digits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context) {
    final color = isBookmarked
        ? AppColors.gold
        : isPlaying
            ? AppColors.goldText
            : AppColors.mushafBasmalaLine;

    // ۝ (U+06DD) provides the ornate circle; we stack the number on top.
    final glyphSize = fontSize * 1.35;
    final numSize = (fontSize * 0.36).clamp(7.0, 13.0);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '۝',
              style: TextStyle(
                fontFamily: AppFonts.quran,
                fontSize: glyphSize,
                color: color,
                height: 1,
              ),
            ),
            Padding(
              // slight upward nudge so the number sits in the visual centre
              // of the ۝ glyph (the glyph descends below its baseline)
              padding: EdgeInsets.only(bottom: glyphSize * 0.08),
              child: Text(
                _toArabic(number),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: AppFonts.quran,
                  fontSize: numSize,
                  color: color,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ornate banner frame painter ───────────────────────────────────────────────

class _BannerFramePainter extends CustomPainter {
  const _BannerFramePainter();

  static const _bg = AppColors.surfaceCard;

  @override
  void paint(Canvas canvas, Size size) {
    // Background fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bg,
    );

    final outerPaint = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final innerPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final goldFill = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    // Outer border
    canvas.drawRect(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        outerPaint);
    // Inner border (inset 6px)
    canvas.drawRect(
        Rect.fromLTWH(6, 6, size.width - 12, size.height - 12), innerPaint);

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Corner diamonds
    for (final p in [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height)
    ]) {
      _diamond(canvas, p, 8, goldFill);
    }

    // Mid-edge small diamonds
    for (final p in [
      Offset(cx, 0),
      Offset(cx, size.height),
      Offset(0, cy),
      Offset(size.width, cy)
    ]) {
      _diamond(canvas, p, 5.5,
          Paint()..color = AppColors.gold.withValues(alpha: 0.85));
    }

    // Small diamonds along top & bottom edges
    final segW = (size.width - 48) / 5;
    for (int i = 1; i <= 4; i++) {
      if (i == 2 || i == 3) continue; // skip near center to avoid crowding
      final x = 24 + i * segW;
      _diamond(canvas, Offset(x, 0), 3.5,
          Paint()..color = AppColors.gold.withValues(alpha: 0.5));
      _diamond(canvas, Offset(x, size.height), 3.5,
          Paint()..color = AppColors.gold.withValues(alpha: 0.5));
    }

    // Left & right side medallions (sit on border, clipped to edge)
    _medallion(canvas, Offset(0, cy), 15, _bg);
    _medallion(canvas, Offset(size.width, cy), 15, _bg);

    // Thin decorative lines inside the inner border (top & bottom)
    final deco = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(const Offset(18, 10), Offset(size.width - 18, 10), deco);
    canvas.drawLine(
        Offset(18, size.height - 10), Offset(size.width - 18, size.height - 10), deco);
  }

  void _diamond(Canvas canvas, Offset c, double half, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - half)
      ..lineTo(c.dx + half, c.dy)
      ..lineTo(c.dx, c.dy + half)
      ..lineTo(c.dx - half, c.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _medallion(Canvas canvas, Offset c, double r, Color bg) {
    canvas.drawCircle(c, r, Paint()..color = bg);
    canvas.drawCircle(c, r,
        Paint()
          ..color = AppColors.goldDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    canvas.drawCircle(c, r * 0.62,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);
    canvas.drawCircle(c, r * 0.22,
        Paint()..color = AppColors.gold.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Font size sheet ───────────────────────────────────────────────────────────

class _FontSizeSheet extends ConsumerWidget {
  const _FontSizeSheet({required this.onChanged});

  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(fontSizeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'حجم الخط',
            style: TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 16,
              color: AppColors.mushafBannerCenter,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SizeBtn(label: 14, value: 16, current: size, onTap: onChanged),
              const SizedBox(width: 12),
              _SizeBtn(label: 17, value: 20, current: size, onTap: onChanged),
              const SizedBox(width: 12),
              _SizeBtn(label: 21, value: 24, current: size, onTap: onChanged),
              const SizedBox(width: 12),
              _SizeBtn(label: 25, value: 28, current: size, onTap: onChanged),
              const SizedBox(width: 12),
              _SizeBtn(label: 29, value: 32, current: size, onTap: onChanged),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SizeBtn extends StatelessWidget {
  const _SizeBtn({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  final double label;
  final double value;
  final double current;
  final void Function(double) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.mushafBannerCenter
                : AppColors.textMuted.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? AppColors.mushafBannerCenter.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          'ص',
          style: TextStyle(
            fontFamily: AppFonts.amiriQuran,
            fontSize: label,
            color: selected
                ? AppColors.mushafBannerCenter
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
