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
    return favoriteSongs.any((item) => item.url == song.url);
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      favoriteSongs.removeWhere((item) => item.url == song.url);
    } else {
      favoriteSongs.add(song);
    }

    notifyListeners();
  }
}
