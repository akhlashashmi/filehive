import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, String>((ref) {
  return ThemeProvider();
});

// system | dark | light

class ThemeProvider extends StateNotifier<String> {
  ThemeProvider() : super('system') {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final hive = await Hive.openBox('settings');
    // Load the theme mode from Hive
    final isDarkMode = hive.get('themeMode', defaultValue: 'system');
    state = isDarkMode;
  }

  // Future<void> toggleTheme() async {
  //   final hive = await Hive.openBox('settings');
  //   state = !state;
  //   // Save the theme mode to Hive
  //   hive.put('themeMode', state);
  // }

  Future<void> set(String themeMode) async {
    final hive = await Hive.openBox('settings');
    state = themeMode;
    // Save the theme mode to Hive
    hive.put('themeMode', state);
  }
}
