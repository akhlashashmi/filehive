import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final widthControllerProvider =
StateNotifierProvider<FileContainerWidthProvider, bool>((ref) {
  return FileContainerWidthProvider();
});

class FileContainerWidthProvider extends StateNotifier<bool> {
  FileContainerWidthProvider() : super(false) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final hive = await Hive.openBox('settings');
      final isDarkMode = hive.get('filesContainerWidth', defaultValue: false);
      state = isDarkMode;
    } catch (error) {
      // Handle Hive errors gracefully, e.g., log the error and notify the user
      print('Error loading theme mode from Hive: $error');
      // Consider showing an error message or using a default value
    }
  }

  Future<void> set(bool filesContainerWidth) async {
    try {
      final hive = await Hive.openBox('settings');
      state = filesContainerWidth;
      await hive.put('filesContainerWidth', state); // Use await for async operation
    } catch (error) {
      // Handle Hive errors, e.g., log the error and notify the user
      print('Error saving theme mode to Hive: $error');
      // Consider reverting the state change or retrying
    }
  }
}
