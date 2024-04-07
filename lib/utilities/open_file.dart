import 'dart:developer';
import 'dart:io';

Future<bool> hasReadPermission(String directoryPath) async {
  try {
    if (!await Directory(directoryPath).exists()) {
      return false;
    }
    try {
      Directory(directoryPath)
          .listSync(recursive: true); // Implicitly checks read permission.
      return true;
    } catch (e) {
      return false; // Handle other errors appropriately.
    }
  } catch (e) {
    log('Error checking read permission: $e');
    return false;
  }
}

extension StringExtensions on String {
  String capitalizeFirstLetter() {
    return this[0].toUpperCase() + substring(1);
  }
}

String snackBarText = '';
