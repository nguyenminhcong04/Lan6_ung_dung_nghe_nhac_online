import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/song.dart';

class AppProvider extends ChangeNotifier {
  bool isDarkMode = true;

  String? currentUserId;

  final List<Song> favoriteSongs = [];
  final List<Song> personalPlaylist = [];

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void clearUserData() {
    currentUserId = null;
    favoriteSongs.clear();
    personalPlaylist.clear();
    notifyListeners();
  }

  Future<void> loadUserData(String uid) async {
    currentUserId = uid;
    favoriteSongs.clear();
    personalPlaylist.clear();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();

    final List favoriteUrls = data?['favoriteUrls'] ?? [];
    final List playlistUrls = data?['playlistUrls'] ?? [];

    for (final url in favoriteUrls) {
      final song = findSongByUrl(url.toString());
      if (song != null) {
        favoriteSongs.add(song);
      }
    }

    for (final url in playlistUrls) {
      final song = findSongByUrl(url.toString());
      if (song != null) {
        personalPlaylist.add(song);
      }
    }

    notifyListeners();
  }

  Song? findSongByUrl(String url) {
    try {
      return myPlaylist.firstWhere((song) => song.url == url);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserMusicData() async {
    if (currentUserId == null) return;

    final favoriteUrls = favoriteSongs.map((song) => song.url).toList();
    final playlistUrls = personalPlaylist.map((song) => song.url).toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .set({
          'favoriteUrls': favoriteUrls,
          'playlistUrls': playlistUrls,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  bool isFavorite(Song song) {
    return favoriteSongs.any((item) => item.url == song.url);
  }

  Future<void> toggleFavorite(Song song) async {
    if (isFavorite(song)) {
      favoriteSongs.removeWhere((item) => item.url == song.url);
    } else {
      favoriteSongs.add(song);
    }

    notifyListeners();
    await saveUserMusicData();
  }

  bool isInPersonalPlaylist(Song song) {
    return personalPlaylist.any((item) => item.url == song.url);
  }

  Future<void> addToPersonalPlaylist(Song song) async {
    if (!isInPersonalPlaylist(song)) {
      personalPlaylist.add(song);
      notifyListeners();
      await saveUserMusicData();
    }
  }

  Future<void> removeFromPersonalPlaylist(Song song) async {
    personalPlaylist.removeWhere((item) => item.url == song.url);
    notifyListeners();
    await saveUserMusicData();
  }

  Future<void> reorderPersonalPlaylist(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final song = personalPlaylist.removeAt(oldIndex);
    personalPlaylist.insert(newIndex, song);

    notifyListeners();
    await saveUserMusicData();
  }
}
