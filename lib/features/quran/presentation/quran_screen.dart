import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تَجَلِّي'),
      ),
      body: const Center(
        child: Text(
          'القرآن الكريم',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
