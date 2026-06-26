import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quran_providers.dart';

class LastReadBanner extends ConsumerWidget {
  const LastReadBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadProvider);
    return lastReadAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (position) {
        if (position == null) return const SizedBox.shrink();
        // Phase 3 will render the banner content here
        return const SizedBox.shrink();
      },
    );
  }
}
