import 'package:flutter/material.dart';
import 'models/song.dart';

class AppProvider extends ChangeNotifier {
  bool isDarkMode = true;

  final List<Song> favoriteSongs = [];

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  bool isFavorite(Song song) {
    return favoriteSongs.any((item) => item.title == song.title);
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      favoriteSongs.removeWhere((item) => item.title == song.title);
    } else {
      favoriteSongs.add(song);
    }

    notifyListeners();
  }
}
