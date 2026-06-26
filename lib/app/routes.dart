import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tajali/app/theme/app_colors.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/quran/presentation/quran_screen.dart';
import '../features/adhkar/presentation/adhkar_screen.dart';
import '../features/qibla/presentation/qibla_screen.dart';
import '../features/prayer_times/presentation/prayer_times_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    QuranScreen(),
    AdhkarScreen(),
    QiblaScreen(),
    PrayerTimesScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primaryGreen,
          currentIndex: selectedIndex,
          onTap: (index) =>
              ref.read(selectedTabProvider.notifier).state = index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'القرآن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome_rounded),
              label: 'الأذكار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'القبلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.synagogue_outlined),
              activeIcon: Icon(Icons.synagogue_rounded),
              label: 'الصلاة',
            ),
          ],
        ),
      ),
    );
  }
}
