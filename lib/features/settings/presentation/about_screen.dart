import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text('من نحن',
            style: AppTextStyles.heading2.copyWith(color: AppColors.gold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<(String, String)>(
        future: () async {
          try {
            final info = await PackageInfo.fromPlatform();
            return (info.version, info.buildNumber);
          } catch (_) {
            return ('1.0.0', '');
          }
        }(),
        builder: (context, snap) {
          final version = snap.data?.$1 ?? '1.0.0';
          final build = snap.data?.$2 ?? '';
          final versionLabel = build.isNotEmpty ? '$version ($build)' : version;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: AppColors.gold,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تَجَلِّي',
                    style: TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الإصدار $versionLabel',
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'رفيقك الإسلامي اليومي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 16,
                      color: AppColors.textMedium,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    '© ٢٠٢٦ — صُنع بمحبة',
                    style: TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
