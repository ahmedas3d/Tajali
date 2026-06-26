import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/quran_providers.dart';
import 'widgets/bookmarks_view.dart';
import 'widgets/juz_list_view.dart';
import 'widgets/last_read_banner.dart';
import 'widgets/quran_search_bar.dart';
import 'widgets/surah_list_view.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    final newIndex = _tabController.index;
    ref.read(quranTabProvider.notifier).state = newIndex;
    if (newIndex != 0) {
      ref.read(quranSearchProvider.notifier).state = '';
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(quranTabProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          'القرآن الكريم',
          style: AppTextStyles.heading2.copyWith(color: AppColors.gold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.navInactive,
          labelStyle: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
            Tab(text: 'المفضلة'),
          ],
        ),
      ),
      body: Column(
        children: [
          const LastReadBanner(),
          if (activeTab == 0) const QuranSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              // Disable swipe so only taps update quranTabProvider and clear search
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SurahListView(),
                JuzListView(),
                BookmarksView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
