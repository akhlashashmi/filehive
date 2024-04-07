import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final favoriteFileProvider =
    StateNotifierProvider<FavoriteFileNotifier, List<String>>(
  (ref) => FavoriteFileNotifier()..loadFavorites(),
);

class FavoriteFileNotifier extends StateNotifier<List<String>> {
  FavoriteFileNotifier() : super([]);

  Future<void> loadFavorites() async {
    try {
      final box = await Hive.openBox('favorites');
      state = box.values.toList().cast<String>();
    } on HiveError catch (error) {
      debugPrint('Hive error loading favorites: ${error.message}');
      log('Hive error loading favorites: ${error.message}');
    } catch (error) {
      debugPrint('Generic error loading favorites: $error');
      log('Generic error loading favorites: $error');
    }
  }

  Future<void> addFavorite(String filePath) async {
    if (state.contains(filePath)) return; // Prevent duplicates

    try {
      state = [...state, filePath];
      final box = await Hive.openBox('favorites');
      await box.put(filePath, filePath);
    } on HiveError catch (error) {
      debugPrint('Hive error adding favorite: ${error.message}');
      log('Hive error adding favorite: ${error.message}');
    } catch (error) {
      debugPrint('Generic error adding favorite: $error');
      log('Generic error adding favorite: $error');
    }
  }

  Future<void> removeFavorite(String filePath) async {
    state = state.where((file) => file != filePath).toList();
    final box = await Hive.openBox('favorites');

    try {
      box.delete(filePath);
    } on HiveError catch (error) {
      debugPrint('Hive error removing favorite: ${error.message}');
      log('Hive error removing favorite: ${error.message}');
    } catch (error) {
      debugPrint('Generic error removing favorite: $error');
      log('Generic error removing favorite: $error');
    }
  }

  bool isFavorite(String filePath) {
    return state.contains(filePath);
  }
}
