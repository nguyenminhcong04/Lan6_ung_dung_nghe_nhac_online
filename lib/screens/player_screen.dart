import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../app_provider.dart';
import '../models/song.dart';

class PlayerScreen extends StatefulWidget {
  final List<Song> playlist;
  final int currentIndex;

  const PlayerScreen({
    super.key,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer audioPlayer;
  late int currentIndex;
  bool isLoading = false;

  Song get currentSong => widget.playlist[currentIndex];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    currentIndex = widget.currentIndex;
    playSong();
  }

  Future<void> playSong() async {
    try {
      setState(() {
        isLoading = true;
      });

      await audioPlayer.stop();
      await audioPlayer.setUrl(currentSong.url);
      await audioPlayer.play();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể phát bài: ${currentSong.title}")),
        );
      }
    }
  }

  Future<void> nextSong() async {
    if (widget.playlist.isEmpty) return;

    if (currentIndex < widget.playlist.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        currentIndex = 0;
      });
    }

    await playSong();
  }

  Future<void> previousSong() async {
    if (widget.playlist.isEmpty) return;

    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else {
      setState(() {
        currentIndex = widget.playlist.length - 1;
      });
    }

    await playSong();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final appProv = Provider.of<AppProvider>(context);
    final isFavorite = appProv.isFavorite(currentSong);

    return Scaffold(
      appBar: AppBar(title: const Text("Đang phát")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                currentSong.coverUrl,
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 280,
                    height: 280,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note, size: 80),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            Text(
              currentSong.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              currentSong.artist,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 42,
                ),
              ),
              onPressed: () {
                appProv.toggleFavorite(currentSong);
              },
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: CircularProgressIndicator(),
              ),
            StreamBuilder<Duration>(
              stream: audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = audioPlayer.duration ?? Duration.zero;

                final maxSeconds = duration.inSeconds == 0
                    ? 1.0
                    : duration.inSeconds.toDouble();

                final currentSeconds = position.inSeconds
                    .clamp(0, duration.inSeconds == 0 ? 1 : duration.inSeconds)
                    .toDouble();

                return Column(
                  children: [
                    Slider(
                      min: 0,
                      max: maxSeconds,
                      value: currentSeconds,
                      onChanged: (value) {
                        audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(position)),
                        Text(formatTime(duration)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final playing = state?.playing ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 48,
                      onPressed: previousSong,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      iconSize: 76,
                      onPressed: () async {
                        if (playing) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play();
                        }
                      },
                      icon: Icon(
                        playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: nextSong,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
