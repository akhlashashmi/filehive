import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../utilities/open_file.dart';

final directoryProvider = StateNotifierProvider<DirectoryNotifier, String>(
  (ref) => DirectoryNotifier(),
);

class DirectoryNotifier extends StateNotifier<String> {
  DirectoryNotifier() : super('') {
    savedDirectory();
  }

  Future<void> savedDirectory() async {
    try {
      final box = await Hive.openBox('settings');
      String? directoryPath = box.get('mainDirectory');

      if (directoryPath != null) {
        state = directoryPath;
        box.put('mainDirectory', directoryPath);
      } else {
        directoryPath = await set();
        if (directoryPath != null) {
          state = directoryPath;
          box.put('mainDirectory', directoryPath);
        } else {
          log('No directory selected');
        }
      }
    } catch (error) {
      log('Hive error: $error');
    }
  }

  Future<String?> set() async {
    try {
      final directoryPath =
          await FilePicker.platform.getDirectoryPath(lockParentWindow: true);
      if (directoryPath != null) {
        try {
          state = directoryPath;
          final box = await Hive.openBox('settings');
          await box.put('mainDirectory', directoryPath);
          return directoryPath;
        } catch (error) {
          // Handle Hive errors appropriately, e.g., log or display a user message
          log('Hive error: $error');
          return null;
        }
      } else {
        return null;
      }
    } catch (error) {
      // Handle FilePicker errors appropriately, e.g., log or display a user message
      log('File picker error: $error');
      return null; // Rethrow to allow further handling by the caller
    }
  }

  Future<bool> setThis(String directoryPath) async {
    if (await hasReadPermission(directoryPath)) {
      try {
        final box = await Hive.openBox('settings');
        await box.put('mainDirectory', directoryPath);
        state = directoryPath;
        return true;
      } catch (e) {
        log('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }
}
