import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_provider.dart';
import '../models/song.dart';
import 'player_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = "";
  int currentIndex = 0;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("search_history") ?? [];

    if (!mounted) return;

    setState(() {
      searchHistory = data;
    });
  }

  Future<void> saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("search_history", searchHistory);
  }

  Future<void> addSearchHistory(String value) async {
    final keyword = value.trim();

    if (keyword.isEmpty) return;

    setState(() {
      searchHistory.removeWhere(
        (item) => item.toLowerCase() == keyword.toLowerCase(),
      );

      searchHistory.insert(0, keyword);

      if (searchHistory.length > 10) {
        searchHistory = searchHistory.take(10).toList();
      }
    });

    await saveSearchHistory();
  }

  Future<void> deleteOneHistory(String value) async {
    setState(() {
      searchHistory.remove(value);
    });

    await saveSearchHistory();
  }

  Future<void> clearAllHistory() async {
    setState(() {
      searchHistory.clear();
    });

    await saveSearchHistory();
  }

  String removeVietnameseTones(String text) {
    String result = text.toLowerCase();

    result = result.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    result = result.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    result = result.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    result = result.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    result = result.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    result = result.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    result = result.replaceAll(RegExp(r'[đ]'), 'd');

    return result;
  }

  List<Song> getFilteredSongs(List<Song> songs) {
    final keyword = removeVietnameseTones(query.trim());

    if (keyword.isEmpty) {
      return songs;
    }

    return songs.where((song) {
      final title = removeVietnameseTones(song.title);
      final artist = removeVietnameseTones(song.artist);

      return title.contains(keyword) || artist.contains(keyword);
    }).toList();
  }

  void submitSearch(String value) {
    setState(() {
      query = value;
    });

    addSearchHistory(value);
    searchFocusNode.unfocus();
  }

  void useHistoryKeyword(String value) {
    searchController.text = value;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );

    setState(() {
      query = value;
    });

    addSearchHistory(value);
    searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final appProv = Provider.of<AppProvider>(context);

    final pages = [
      buildHomePage(),
      buildPersonalPlaylistPage(appProv),
      buildFavoritePage(appProv),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zing MP3 Online"),
        actions: [
          IconButton(
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 500),
              turns: appProv.isDarkMode ? 1 : 0,
              child: Icon(
                appProv.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            onPressed: () {
              appProv.toggleTheme();
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music),
            label: "Danh sách",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Yêu thích",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final listShow = getFilteredSongs(myPlaylist);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            onSubmitted: submitSearch,
            decoration: InputDecoration(
              hintText: "Tìm bài hát hoặc nghệ sĩ...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();

                        setState(() {
                          query = "";
                        });

                        searchFocusNode.requestFocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        if (query.trim().isEmpty && searchHistory.isNotEmpty)
          buildSearchHistory(),
        if (query.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Kết quả tìm kiếm: $query",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    addSearchHistory(query);
                    searchFocusNode.unfocus();
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text("Lưu"),
                ),
              ],
            ),
          ),
        Expanded(
          child: listShow.isEmpty
              ? const Center(
                  child: Text(
                    "Không tìm thấy bài hát",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: listShow.length,
                  itemBuilder: (context, index) {
                    final song = listShow[index];

                    return SongItem(
                      song: song,
                      playlist: myPlaylist,
                      index: myPlaylist.indexOf(song),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildSearchHistory() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Lịch sử tìm kiếm",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: clearAllHistory,
                child: const Text("Xóa tất cả"),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...searchHistory.map((item) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.search, size: 20),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  deleteOneHistory(item);
                },
              ),
              onTap: () {
                useHistoryKeyword(item);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget buildPersonalPlaylistPage(AppProvider appProv) {
    final playlist = appProv.personalPlaylist;

    if (playlist.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có bài trong danh sách phát\nHãy bấm nút + ở Trang chủ để thêm bài",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Giữ và kéo bài hát để tự sắp xếp thứ tự phát",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: playlist.length,
            onReorder: (oldIndex, newIndex) {
              appProv.reorderPersonalPlaylist(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final song = playlist[index];

              return Card(
                key: ValueKey(song.url),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      song.coverUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 58,
                          height: 58,
                          color: Colors.grey,
                          child: const Icon(Icons.music_note),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(song.artist),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      appProv.removeFromPersonalPlaylist(song);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          playlist: playlist,
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFavoritePage(AppProvider appProv) {
    final favoriteList = appProv.favoriteSongs;

    if (favoriteList.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có bài hát yêu thích",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: favoriteList.length,
      itemBuilder: (context, index) {
        final song = favoriteList[index];

        return SongItem(song: song, playlist: favoriteList, index: index);
      },
    );
  }
}

class SongItem extends StatelessWidget {
  final Song song;
  final List<Song> playlist;
  final int index;

  const SongItem({
    super.key,
    required this.song,
    required this.playlist,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final appProv = Provider.of<AppProvider>(context);
    final isFavorite = appProv.isFavorite(song);
    final isInPlaylist = appProv.isInPersonalPlaylist(song);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            song.coverUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey,
                child: const Icon(Icons.music_note),
              );
            },
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(song.artist),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isInPlaylist ? Icons.playlist_add_check : Icons.playlist_add,
                color: isInPlaylist ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: () async {
                await appProv.addToPersonalPlaylist(song);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInPlaylist
                          ? "${song.title} đã có trong danh sách phát"
                          : "Đã thêm ${song.title} vào danh sách phát",
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                appProv.toggleFavorite(song);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PlayerScreen(playlist: playlist, currentIndex: index),
            ),
          );
        },
      ),
    );
  }
}
