import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../providers/adhkar_providers.dart';

class DhikrDetailScreen extends ConsumerStatefulWidget {
  const DhikrDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.initialIndex,
  });

  final String categoryId;
  final String categoryName;
  final int initialIndex;

  @override
  ConsumerState<DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends ConsumerState<DhikrDetailScreen> {
  late int _currentIndex;
  bool _autoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _advance(int total) {
    if (_autoAdvancing || _currentIndex >= total - 1) return;
    _autoAdvancing = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _autoAdvancing = false;
        });
      } else {
        _autoAdvancing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dhikrListAsync = ref.watch(dhikrListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: dhikrListAsync.maybeWhen(
          data: (list) => Text(
            '${widget.categoryName}  ${_currentIndex + 1} / ${list.length}',
            style: const TextStyle(
              fontFamily: AppFonts.arabic,
              fontSize: 16,
              color: AppColors.gold,
            ),
          ),
          orElse: () => Text(
            widget.categoryName,
            style: const TextStyle(
              fontFamily: AppFonts.arabic,
              fontSize: 16,
              color: AppColors.gold,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: dhikrListAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('لا توجد أذكار'));
          }

          final dhikr = list[_currentIndex];
          final counterKey =
              (categoryId: widget.categoryId, index: _currentIndex);
          final remaining = ref.watch(dhikrCounterProvider(counterKey));
          final isComplete = remaining == 0;

          // Auto-advance when counter hits 0 and there's a next dhikr
          ref.listen<int>(dhikrCounterProvider(counterKey), (prev, next) {
            if (next == 0 && prev != null && prev > 0) {
              _advance(list.length);
            }
          });

          void countOnce() {
            if (!isComplete) {
              final key =
                  (categoryId: widget.categoryId, index: _currentIndex);
              ref.read(dhikrCounterProvider(key).notifier).decrement();
            }
          }

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: countOnce,
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceIvory,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              dhikr.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppFonts.quran,
                                fontSize: 22,
                                color: isComplete
                                    ? AppColors.textMuted
                                    : AppColors.mushafText,
                                height: 2.2,
                              ),
                            ),
                            if (dhikr.source != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                dhikr.source!,
                                style: const TextStyle(
                                  fontFamily: AppFonts.arabic,
                                  fontSize: 13,
                                  color: AppColors.goldText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (dhikr.virtue != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  dhikr.virtue!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.arabic,
                                    fontSize: 13,
                                    color: AppColors.textMedium,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _CounterWidget(
                        remaining: remaining,
                        total: dhikr.repeat,
                        isComplete: isComplete,
                      ),
                      const SizedBox(height: 20),
                      _PageDots(
                        total: list.length,
                        current: _currentIndex,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                ),
              ),
              _BottomActions(
                remaining: remaining,
                isComplete: isComplete,
                onCount: () {
                  final key =
                      (categoryId: widget.categoryId, index: _currentIndex);
                  ref.read(dhikrCounterProvider(key).notifier).decrement();
                },
                onNext: _currentIndex < list.length - 1
                    ? () => setState(() => _currentIndex++)
                    : null,
                onPrev: _currentIndex > 0
                    ? () => setState(() => _currentIndex--)
                    : null,
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => const Center(
          child: Text('خطأ في التحميل'),
        ),
      ),
    );
  }
}

class _CounterWidget extends StatelessWidget {
  const _CounterWidget({
    required this.remaining,
    required this.total,
    required this.isComplete,
  });

  final int remaining;
  final int total;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.textMuted.withValues(alpha: 0.15)
                : AppColors.primaryGreen,
            boxShadow: isComplete
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              '$remaining',
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isComplete ? AppColors.textMuted : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$total مرات',
          style: const TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    final visibleCount = total > 12 ? 12 : total;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visibleCount, (i) {
        final isActive = i == (current > 11 ? 11 : current);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryGreen
                : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.remaining,
    required this.isComplete,
    required this.onCount,
    this.onNext,
    this.onPrev,
  });

  final int remaining;
  final bool isComplete;
  final VoidCallback onCount;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceIvory,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isComplete ? null : onCount,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isComplete ? AppColors.textMuted : AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: isComplete ? 0 : 4,
              ),
              child: Text(
                isComplete ? 'أتممت الذكر' : 'تقبّل الله',
                style: const TextStyle(
                  fontFamily: AppFonts.arabic,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (onNext != null || onPrev != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onPrev,
                  label: const Text(
                    'الذكر السابق',
                    style: TextStyle(fontFamily: AppFonts.arabic, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: onPrev == null
                        ? AppColors.textMuted
                        : AppColors.primaryGreen,
                  ),
                ),
                TextButton.icon(
                  onPressed: onNext,
                  label: const Text(
                    'الذكر التالي',
                    style: TextStyle(fontFamily: AppFonts.arabic, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: onNext == null
                        ? AppColors.textMuted
                        : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
