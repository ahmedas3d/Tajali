import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/permission_models.dart';

class PermissionCardWidget extends StatelessWidget {
  const PermissionCardWidget({
    super.key,
    required this.type,
    required this.state,
    required this.onTap,
  });

  final PermissionType type;
  final PermissionCardState state;
  final VoidCallback onTap;

  static const _gold = Color(0xFFC9A84C);

  String get _title => switch (type) {
        PermissionType.location => 'الموقع',
        PermissionType.notification => 'الإشعارات',
      };

  String get _subtitle => switch (type) {
        PermissionType.location => 'لتحديد أوقات الصلاة والقبلة بدقة',
        PermissionType.notification => 'لتذكيرك بمواقيت الصلاة',
      };

  IconData get _icon => switch (type) {
        PermissionType.location => Icons.location_on_outlined,
        PermissionType.notification => Icons.notifications_outlined,
      };

  Color get _borderColor => switch (state) {
        PermissionCardState.pending => const Color(0x4DC9A84C),
        PermissionCardState.granted => _gold,
        PermissionCardState.denied => const Color(0x26FFF1E8),
      };

  Color get _fillColor => switch (state) {
        PermissionCardState.pending => const Color(0x14FFF1E8),
        PermissionCardState.granted => const Color(0x14FFF1E8),
        PermissionCardState.denied => const Color(0x0AFFF1E8),
      };

  @override
  Widget build(BuildContext context) {
    final isDenied = state == PermissionCardState.denied;

    return GestureDetector(
      onTap: isDenied ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  _icon,
                  color: isDenied
                      ? const Color(0x66FFF1E8)
                      : const Color(0xBFFFF1E8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDenied
                              ? const Color(0x66FFF1E8)
                              : const Color(0xFFFFF1E8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          color: isDenied
                              ? const Color(0x4DFFF1E8)
                              : const Color(0x99FFF1E8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _TrailingIcon(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailingIcon extends StatelessWidget {
  const _TrailingIcon({required this.state});
  final PermissionCardState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PermissionCardState.pending => const Icon(
          Icons.chevron_left,
          color: Color(0x99FFF1E8),
          size: 20,
        ),
      PermissionCardState.granted => const Icon(
          Icons.check_circle,
          color: Color(0xFFC9A84C),
          size: 20,
        ),
      PermissionCardState.denied => const Icon(
          Icons.warning_amber_rounded,
          color: Color(0x66FFF1E8),
          size: 20,
        ),
    };
  }
}
