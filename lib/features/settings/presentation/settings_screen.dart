import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/adhan_audio_service.dart';
import '../../../core/services/adhan_notification_service.dart';
import '../../prayer_times/providers/prayer_times_providers.dart';
import '../../quran/data/models/reciter_model.dart';
import '../../quran/providers/reader_providers.dart';
import 'about_screen.dart';
import 'widgets/settings_link_row.dart';
import 'widgets/settings_permission_banner.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_toggle_row.dart';
import 'widgets/settings_value_row.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(calculationMethodProvider);
    final school = ref.watch(fiqhSchoolProvider);
    final adhanSound = ref.watch(adhanSoundProvider);
    final fajrOn = ref.watch(prayerNotifFajrProvider);
    final dhuhrOn = ref.watch(prayerNotifDhuhrProvider);
    final asrOn = ref.watch(prayerNotifAsrProvider);
    final maghribOn = ref.watch(prayerNotifMaghribProvider);
    final ishaOn = ref.watch(prayerNotifIshaProvider);
    final selectedReciter = ref.watch(selectedReciterProvider);

    final methodName = CalculationMethodConfig.all
        .firstWhere((m) => m.id == selectedMethod,
            orElse: () => CalculationMethodConfig.all.first)
        .nameAr;
    final schoolName = school == FiqhSchool.hanafi ? 'الحنفي' : 'الشافعي';
    final soundName = adhanSound == AdhanSoundSource.egypt
        ? 'إذاعة القرآن المصرية'
        : 'المسجد الحرام';
    final reciterName = ReciterModel.byIdentifier(selectedReciter).nameAr;

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
          // ── الصلاة والمواقيت ───────────────────────────────────────────
          const SettingsSectionHeader(title: 'الصلاة والمواقيت'),

          SettingsValueRow(
            label: 'طريقة حساب المواقيت',
            value: methodName,
            onTap: () => _showMethodPicker(context, ref, selectedMethod),
          ),
          const Divider(height: 1, indent: 16),

          SettingsValueRow(
            label: 'المذهب الفقهي',
            value: schoolName,
            onTap: () => _showSchoolPicker(context, ref, school),
          ),
          const Divider(height: 1, indent: 16),

          SettingsValueRow(
            label: 'صوت الأذان',
            value: soundName,
            onTap: () => _showSoundPicker(context, ref, adhanSound),
          ),

          // ── Test buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testAdhan(context, ref, isFajr: false),
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('اختبر الأذان'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testAdhan(context, ref, isFajr: true),
                    icon: const Icon(Icons.wb_twilight_rounded, size: 18),
                    label: const Text('اختبر الفجر'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── تنبيهات الأذان ─────────────────────────────────────────────
          const SettingsSectionHeader(title: 'تنبيهات الأذان'),
          const SettingsPermissionBanner(),

          SettingsToggleRow(
            label: 'الفجر',
            value: fajrOn,
            onChanged: (v) => _setNotif(ref, 'fajr', prayerNotifFajrProvider,
                AdhanNotificationService.cancelPrayer, 100, v),
          ),
          const Divider(height: 1, indent: 16),
          SettingsToggleRow(
            label: 'الظهر',
            value: dhuhrOn,
            onChanged: (v) => _setNotif(ref, 'dhuhr', prayerNotifDhuhrProvider,
                AdhanNotificationService.cancelPrayer, 102, v),
          ),
          const Divider(height: 1, indent: 16),
          SettingsToggleRow(
            label: 'العصر',
            value: asrOn,
            onChanged: (v) => _setNotif(ref, 'asr', prayerNotifAsrProvider,
                AdhanNotificationService.cancelPrayer, 103, v),
          ),
          const Divider(height: 1, indent: 16),
          SettingsToggleRow(
            label: 'المغرب',
            value: maghribOn,
            onChanged: (v) => _setNotif(
                ref,
                'maghrib',
                prayerNotifMaghribProvider,
                AdhanNotificationService.cancelPrayer,
                104,
                v),
          ),
          const Divider(height: 1, indent: 16),
          SettingsToggleRow(
            label: 'العشاء',
            value: ishaOn,
            onChanged: (v) => _setNotif(ref, 'isha', prayerNotifIshaProvider,
                AdhanNotificationService.cancelPrayer, 105, v),
          ),

          // ── القرآن الكريم ──────────────────────────────────────────────
          const SettingsSectionHeader(title: 'القرآن الكريم'),

          SettingsValueRow(
            label: 'القارئ المفضل',
            value: reciterName,
            onTap: () => _showReciterPicker(context, ref, selectedReciter),
          ),

          // ── عام ────────────────────────────────────────────────────────
          const SettingsSectionHeader(title: 'عام'),

          SettingsLinkRow(
            icon: Icons.star_outline_rounded,
            label: 'تقييم التطبيق',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, indent: 16),
          SettingsLinkRow(
            icon: Icons.share_outlined,
            label: 'مشاركة التطبيق',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, indent: 16),
          SettingsLinkRow(
            icon: Icons.privacy_tip_outlined,
            label: 'سياسة الخصوصية',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1, indent: 16),
          SettingsLinkRow(
            icon: Icons.info_outline_rounded,
            label: 'من نحن',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),

          // ── Footer ─────────────────────────────────────────────────────
          FutureBuilder<String>(
            future: () async {
              try {
                final info = await PackageInfo.fromPlatform();
                return info.version;
              } catch (_) {
                return '1.0.0';
              }
            }(),
            builder: (context, snap) {
              final version = snap.data ?? '1.0.0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'تجلّي v$version',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  void _showMethodPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RadioSheet<int>(
        title: 'طريقة حساب المواقيت',
        items: CalculationMethodConfig.all
            .map((m) => (value: m.id, label: m.nameAr))
            .toList(),
        current: current,
        onSelected: (id) async {
          ref.read(calculationMethodProvider.notifier).state = id;
          await saveMethodId(id);
          ref.invalidate(prayerTimesProvider);
        },
      ),
    );
  }

  void _showSchoolPicker(
      BuildContext context, WidgetRef ref, FiqhSchool current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RadioSheet<FiqhSchool>(
        title: 'المذهب الفقهي',
        items: const [
          (value: FiqhSchool.shafii, label: 'الشافعي'),
          (value: FiqhSchool.hanafi, label: 'الحنفي'),
        ],
        current: current,
        onSelected: (school) async {
          ref.read(fiqhSchoolProvider.notifier).state = school;
          await saveFiqhSchool(school);
          ref.invalidate(prayerTimesProvider);
        },
      ),
    );
  }

  void _showSoundPicker(
      BuildContext context, WidgetRef ref, AdhanSoundSource current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RadioSheet<AdhanSoundSource>(
        title: 'صوت الأذان',
        items: const [
          (
            value: AdhanSoundSource.makkah,
            label: 'المسجد الحرام — مكة المكرمة'
          ),
          (value: AdhanSoundSource.egypt, label: 'إذاعة القرآن الكريم المصرية'),
        ],
        current: current,
        onSelected: (source) async {
          ref.read(adhanSoundProvider.notifier).state = source;
          await saveAdhanSound(source);
        },
      ),
    );
  }

  void _showReciterPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RadioSheet<String>(
        title: 'القارئ المفضل',
        items: ReciterModel.reciters
            .map((r) => (value: r.identifier, label: r.nameAr))
            .toList(),
        current: current,
        onSelected: (id) async {
          ref.read(selectedReciterProvider.notifier).state = id;
          await persistReciter(id);
        },
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _testAdhan(BuildContext context, WidgetRef ref,
      {required bool isFajr}) async {
    final sound = ref.read(adhanSoundProvider);
    final audioSound =
        sound == AdhanSoundSource.egypt ? AdhanSound.egypt : AdhanSound.makkah;

    await AdhanAudioService.instance.play(isFajr: isFajr, sound: audioSound);
    await AdhanNotificationService.initialize();
    await AdhanNotificationService.requestPermission();
    await AdhanNotificationService.testNow(
      delaySeconds: 10,
      isFajr: isFajr,
      source: sound,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFajr
              ? 'يعزف أذان الفجر الآن • إشعار خلال 10 ثوانٍ'
              : 'يعزف أذان الصلاة الآن • إشعار خلال 10 ثوانٍ'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _setNotif(
    WidgetRef ref,
    String key,
    StateProvider<bool> provider,
    Future<void> Function(int) cancelFn,
    int todayId,
    bool value,
  ) {
    ref.read(provider.notifier).state = value;
    savePrayerNotif(key, value);
    if (!value) {
      cancelFn(todayId);
    } else {
      ref.invalidate(prayerTimesProvider);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً')),
    );
  }
}

// ── Generic radio bottom sheet ───────────────────────────────────────────────

typedef _SheetItem<T> = ({T value, String label});

class _RadioSheet<T> extends StatelessWidget {
  const _RadioSheet({
    super.key,
    required this.title,
    required this.items,
    required this.current,
    required this.onSelected,
  });

  final String title;
  final List<_SheetItem<T>> items;
  final T current;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: AppColors.goldText),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          ...items.map(
            (item) => ListTile(
              title: Text(
                item.label,
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 15,
                  color: item.value == current
                      ? AppColors.primaryGreen
                      : AppColors.textDark,
                  fontWeight: item.value == current
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: item.value == current
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primaryGreen)
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelected(item.value);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
