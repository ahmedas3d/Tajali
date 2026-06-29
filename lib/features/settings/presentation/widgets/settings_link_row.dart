import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';

class SettingsLinkRow extends StatelessWidget {
  const SettingsLinkRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textMuted, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 15,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: AppColors.textMuted, size: 16),
    );
  }
}
