import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.gold,
      thickness: 0.8,
    );
  }
}
