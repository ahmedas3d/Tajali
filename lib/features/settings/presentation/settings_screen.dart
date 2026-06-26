import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../prayer_times/providers/prayer_times_providers.dart';
import '../data/services/settings_service.dart';
import 'widgets/calculation_method_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(calculationMethodProvider);

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
}
