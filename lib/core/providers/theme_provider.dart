import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final stored = storageService.read(_key);
    return stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    await setMode(current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state.valueOrNull == mode) return;
    await storageService.write(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    state = AsyncData(mode);
  }
}

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
