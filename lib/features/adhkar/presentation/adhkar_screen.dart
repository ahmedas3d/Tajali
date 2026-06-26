import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تَجَلِّي'),
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
