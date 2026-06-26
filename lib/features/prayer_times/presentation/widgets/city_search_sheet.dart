import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/cities_data.dart';
import '../../providers/prayer_times_providers.dart';

class CitySearchSheet extends ConsumerStatefulWidget {
  const CitySearchSheet({super.key});

  @override
  ConsumerState<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<CitySearchSheet> {
  final _controller = TextEditingController();
  List<ManualCityEntry> _filtered = kCities;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    final lower = q.trim().toLowerCase();
    setState(() {
      _filtered = lower.isEmpty
          ? kCities
          : kCities
              .where((c) => c.nameAr.toLowerCase().contains(lower))
              .toList();
    });
  }

  Future<void> _select(ManualCityEntry city) async {
    ref.read(manualCityProvider.notifier).state = city;
    await saveCity(city);
    ref.invalidate(locationProvider);
    ref.invalidate(prayerTimesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onQuery,
              autofocus: true,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة...',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.textMuted),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surfaceCard,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 56),
              itemBuilder: (_, i) {
                final city = _filtered[i];
                return ListTile(
                  leading:
                      const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
                  title: Text(city.nameAr, style: AppTextStyles.body),
                  onTap: () => _select(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showCitySearchSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundParchment,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const CitySearchSheet(),
  );
}
