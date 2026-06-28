import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/adhan_notification_service.dart';
import '../../prayer_times/providers/prayer_times_providers.dart';
import '../data/services/settings_service.dart';
import 'widgets/calculation_method_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(calculationMethodProvider);
    final notifMode = ref.watch(notificationModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text('الإعدادات',
            style: AppTextStyles.heading2.copyWith(color: AppColors.gold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── Calculation method ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'طريقة الحساب',
              style: AppTextStyles.heading3.copyWith(color: AppColors.goldText),
            ),
          ),
          const Divider(height: 1),
          ...CalculationMethodConfig.all.map(
            (method) => CalculationMethodTile(
              method: method,
              isSelected: selectedMethod == method.id,
              onTap: () => _selectMethod(ref, method.id),
            ),
          ),

          // ── Adhan notification mode ─────────────────────────────────────
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'إشعار الأذان',
              style: AppTextStyles.heading3.copyWith(color: AppColors.goldText),
            ),
          ),
          const Divider(height: 1),
          _NotifTile(
            icon: Icons.volume_up_rounded,
            title: 'صوت الأذان كامل',
            subtitle: 'إشعار مع صوت الأذان عند دخول وقت الصلاة',
            selected: notifMode == AdhanNotificationMode.fullSound,
            onTap: () => _setNotifMode(ref, AdhanNotificationMode.fullSound),
          ),
          _NotifTile(
            icon: Icons.notifications_outlined,
            title: 'إشعار صامت',
            subtitle: 'إشعار بدون صوت عند دخول وقت الصلاة',
            selected: notifMode == AdhanNotificationMode.silent,
            onTap: () => _setNotifMode(ref, AdhanNotificationMode.silent),
          ),
          _NotifTile(
            icon: Icons.notifications_off_outlined,
            title: 'معطّل',
            subtitle: 'لا يصلك أي إشعار',
            selected: notifMode == AdhanNotificationMode.disabled,
            onTap: () => _setNotifMode(ref, AdhanNotificationMode.disabled),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _testAdhan(context, isFajr: false),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('اختبر أذان الصلاة (ظهر/مغرب…)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.gold,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _testAdhan(context, isFajr: true),
                  icon: const Icon(Icons.wb_twilight_rounded),
                  label: const Text('اختبر أذان الفجر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.gold,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _selectMethod(WidgetRef ref, int id) async {
    ref.read(calculationMethodProvider.notifier).state = id;
    await SettingsService().saveMethodId(id);
    ref.invalidate(prayerTimesProvider);
  }

  Future<void> _testAdhan(BuildContext context, {required bool isFajr}) async {
    await AdhanNotificationService.initialize();
    await AdhanNotificationService.requestPermission();
    await AdhanNotificationService.testNow(delaySeconds: 5, isFajr: isFajr);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFajr
              ? 'سيصلك أذان الفجر خلال 5 ثوانٍ'
              : 'سيصلك أذان الصلاة خلال 5 ثوانٍ'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _setNotifMode(
      WidgetRef ref, AdhanNotificationMode mode) async {
    ref.read(notificationModeProvider.notifier).state = mode;
    await saveNotificationMode(mode);
    // Request permission on first sound enable
    if (mode == AdhanNotificationMode.fullSound) {
      await AdhanNotificationService.requestPermission();
    }
  }
}

// ── Notification option tile ──────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: selected
          ? AppColors.primaryGreen.withValues(alpha: 0.06)
          : null,
      leading: Icon(
        icon,
        color: selected ? AppColors.primaryGreen : AppColors.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? AppColors.primaryGreen : AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
          : const Icon(Icons.circle_outlined, color: AppColors.textMuted),
    );
  }
}
