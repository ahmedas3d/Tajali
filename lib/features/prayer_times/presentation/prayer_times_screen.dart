import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تَجَلِّي'),
      ),
      body: const Center(
        child: Text(
          'مواقيت الصلاة',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
