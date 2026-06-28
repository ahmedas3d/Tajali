import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/reciter_model.dart';
import '../../data/services/audio_player_service.dart';
import '../../providers/reader_providers.dart';
import 'reciter_picker_sheet.dart';

class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({
    super.key,
    required this.audioService,
    required this.ayahs,
    required this.currentIndex,
    required this.isRepeat,
    required this.onRepeatToggle,
    required this.onReciterChanged,
  });

  final AudioPlayerService audioService;
  final List<AyahModel> ayahs;
  final int? currentIndex;
  final bool isRepeat;
  final VoidCallback onRepeatToggle;
  final VoidCallback onReciterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciterId = ref.watch(selectedReciterProvider);
    final reciter = ReciterModel.byIdentifier(reciterId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryGreenDark,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // ── Reciter section ──────────────────────────────────────────
              GestureDetector(
                onTap: () => _showReciterPicker(context, ref),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showReciterPicker(context, ref),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'الآن يُشغَّل',
                        style: TextStyle(
                          fontFamily: AppFonts.amiri,
                          fontSize: 10,
                          color: AppColors.navInactive,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        reciter.nameAr,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: AppFonts.amiri,
                          fontSize: 13,
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // ── Separator ────────────────────────────────────────────────
              Container(
                width: 1,
                height: 36,
                color: AppColors.gold.withValues(alpha: 0.25),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // ── Transport controls ───────────────────────────────────────
              // Repeat toggle
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  isRepeat ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                  color: isRepeat ? AppColors.gold : AppColors.navInactive,
                ),
                onPressed: onRepeatToggle,
              ),
              // Previous ayah
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 22,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: currentIndex != null && currentIndex! > 0
                      ? AppColors.textOnDark
                      : AppColors.navInactive,
                ),
                onPressed: currentIndex != null && currentIndex! > 0
                    ? () => audioService.playFromIndex(currentIndex! - 1)
                    : null,
              ),
              // Play / Pause
              _PlayButton(audioService: audioService, ayahs: ayahs, currentIndex: currentIndex),
              // Next ayah
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 22,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: currentIndex != null && currentIndex! < ayahs.length - 1
                      ? AppColors.textOnDark
                      : AppColors.navInactive,
                ),
                onPressed: currentIndex != null && currentIndex! < ayahs.length - 1
                    ? () => audioService.playFromIndex(currentIndex! + 1)
                    : null,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _showReciterPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.primaryGreenDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReciterPickerSheet(
        currentReciterId: ref.read(selectedReciterProvider),
        onSelected: (id) async {
          ref.read(selectedReciterProvider.notifier).state = id;
          await persistReciter(id);
          onReciterChanged();
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Play/Pause button ─────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.audioService,
    required this.ayahs,
    required this.currentIndex,
  });

  final AudioPlayerService audioService;
  final List<AyahModel> ayahs;
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snap) {
        final state = snap.data;
        final loading = state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering;
        final playing = state?.playing ?? false;

        return GestureDetector(
          onTap: () async {
            if (playing) {
              await audioService.pause();
            } else if (ayahs.isNotEmpty) {
              if (audioService.displayIndex != null) {
                await audioService.resume();
              } else {
                await audioService.play(ayahs, startIndex: currentIndex ?? 0);
              }
            }
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreenDark,
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.primaryGreenDark,
                    size: 30,
                  ),
          ),
        );
      },
    );
  }
}
