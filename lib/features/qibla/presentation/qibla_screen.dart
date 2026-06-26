import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تَجَلِّي'),
      ),
      body: const Center(
        child: Text(
          'القبلة',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
