import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../providers/quran_providers.dart';

class QuranSearchBar extends ConsumerStatefulWidget {
  const QuranSearchBar({super.key});

  @override
  ConsumerState<QuranSearchBar> createState() => _QuranSearchBarState();
}

class _QuranSearchBarState extends ConsumerState<QuranSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.goldDark, width: 0.8),
      ),
      child: TextField(
        controller: _controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 15,
          color: AppColors.textOnDark,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث باسم السورة...',
          hintStyle: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 14,
            color: AppColors.navInactive,
          ),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.goldLight, size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColors.goldLight, size: 18),
                  onPressed: () {
                    _controller.clear();
                    ref.read(quranSearchProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          ref.read(quranSearchProvider.notifier).state = value;
          setState(() {});
        },
      ),
    );
  }
}
