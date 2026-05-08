import 'dart:async';

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
  late final AudioPlayer audioPlayer;
  late int currentIndex;

  StreamSubscription<PlayerState>? playerStateSubscription;

  bool isLoading = false;
  bool isChangingSong = false;
  double volume = 0.55;

  Song get currentSong => widget.playlist[currentIndex];

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    currentIndex = widget.currentIndex;

    audioPlayer.setVolume(volume);

    playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      final completed = state.processingState == ProcessingState.completed;

      if (completed && mounted && !isChangingSong) {
        nextSong();
      }
    });

    playSong();
  }

  Future<void> playSong() async {
    if (isChangingSong) return;

    try {
      isChangingSong = true;

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Dừng sạch bài cũ để tránh âm thanh bị chồng lên nhau
      await audioPlayer.pause();
      await audioPlayer.stop();
      await audioPlayer.seek(Duration.zero);

      // Giảm âm lượng mặc định để hạn chế rè trên emulator
      await audioPlayer.setVolume(volume);

      // Load bài hiện tại từ URL
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(currentSong.url)),
        preload: true,
      );

      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể phát bài: ${currentSong.title}")),
      );
    } finally {
      isChangingSong = false;
    }
  }

  Future<void> nextSong() async {
    if (widget.playlist.isEmpty || isChangingSong) return;

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
    if (widget.playlist.isEmpty || isChangingSong) return;

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

  Future<void> togglePlayPause(bool playing) async {
    if (isChangingSong) return;

    if (playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> changeVolume(double value) async {
    setState(() {
      volume = value;
    });

    await audioPlayer.setVolume(volume);
  }

  @override
  void dispose() {
    playerStateSubscription?.cancel();
    audioPlayer.stop();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  currentSong.coverUrl,
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 230,
                      height: 230,
                      color: Colors.grey.shade700,
                      child: const Icon(Icons.music_note, size: 70),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Text(
                currentSong.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                currentSong.artist,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 10),

              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(isFavorite),
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 40,
                  ),
                ),
                onPressed: () async {
                  await appProv.toggleFavorite(currentSong);
                },
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 8),
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
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
                      .clamp(
                        0,
                        duration.inSeconds == 0 ? 1 : duration.inSeconds,
                      )
                      .toDouble();

                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        max: maxSeconds,
                        value: currentSeconds,
                        onChanged: duration.inSeconds == 0
                            ? null
                            : (value) {
                                audioPlayer.seek(
                                  Duration(seconds: value.toInt()),
                                );
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

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.volume_down, size: 22),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 1,
                      value: volume,
                      onChanged: changeVolume,
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 22),
                ],
              ),

              const SizedBox(height: 8),

              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 44,
                        onPressed: isChangingSong ? null : previousSong,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        iconSize: 66,
                        onPressed: isChangingSong
                            ? null
                            : () {
                                togglePlayPause(playing);
                              },
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        iconSize: 44,
                        onPressed: isChangingSong ? null : nextSong,
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
