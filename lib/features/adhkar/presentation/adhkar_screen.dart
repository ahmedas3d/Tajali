import 'package:flutter/material.dart';
import 'package:tajali/app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تَجَلِّي',
            style: AppTextStyles.heading1.copyWith(color: AppColors.gold)),
      ),
      body: const Center(
        child: Text(
          'الأذكار',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
