import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final filesVisibilityProvider =
    StateNotifierProvider<FilesVisibilityProvider, bool>((ref) {
  return FilesVisibilityProvider();
});

class FilesVisibilityProvider extends StateNotifier<bool> {
  FilesVisibilityProvider() : super(true) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final hive = await Hive.openBox('settings');
      final isDarkMode = hive.get('showFiles', defaultValue: true);
      state = isDarkMode;
    } catch (error) {
      // Handle Hive errors gracefully, e.g., log the error and notify the user
      print('Error loading theme mode from Hive: $error');
      // Consider showing an error message or using a default value
    }
  }

  Future<void> toggle() async {
    try {
      final hive = await Hive.openBox('settings');
      state = !state;
      await hive.put('showFiles', state); // Use await for async operation
    } catch (error) {
      // Handle Hive errors, e.g., log the error and notify the user
      print('Error saving theme mode to Hive: $error');
      // Consider reverting the state change or retrying
    }
  }
}
