import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة'),
      ),
      body: const Center(
        child: Text(
          'المسبحة',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
