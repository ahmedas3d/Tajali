import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';

class SettingsPermissionBanner extends StatefulWidget {
  const SettingsPermissionBanner({super.key});

  @override
  State<SettingsPermissionBanner> createState() =>
      _SettingsPermissionBannerState();
}

class _SettingsPermissionBannerState extends State<SettingsPermissionBanner> {
  late final AppLifecycleListener _lifecycleListener;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _lifecycleListener = AppLifecycleListener(onResume: _checkPermission);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() => _denied = !status.isGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_denied) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFD166)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_outlined,
              color: Color(0xFF856404), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'الإشعارات معطّلة',
              style: TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 14,
                color: Color(0xFF856404),
              ),
            ),
          ),
          TextButton(
            onPressed: openAppSettings,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'افتح الإعدادات',
              style: TextStyle(fontFamily: AppFonts.amiri, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
