import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:provider/provider.dart';
import '../services/player_service.dart';
import '../services/storage_service.dart';
import '../datas/song.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  void _showPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<PlayerService>(
          builder: (context, player, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Queue (${player.queue.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: player.queue.length,
                    itemBuilder: (context, index) {
                      final song = player.queue[index];
                      final isCurrent = index == player.currentIndex;
                      return ListTile(
                        leading: isCurrent
                            ? const Icon(Icons.play_arrow, color: Colors.blue)
                            : null,
                        title: Text(
                          song.name,
                          style: TextStyle(
                            color: isCurrent ? Colors.blue : Colors.white,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.blue.withOpacity(0.7)
                                : Colors.white54,
                          ),
                        ),
                        onTap: () {
                          player.playSong(
                            song,
                            newQueue: player.queue,
                          ); // Or just jump to index if we had that method
                          // For now playSong with same queue works as it finds index.
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, player, child) {
        final song = player.currentSong;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text('Now Playing'),
          ),
          backgroundColor: const Color(0xFF1A2332),
          body: SafeArea(
            child: song == null
                ? const Center(
                    child: Text(
                      'No song playing',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Top Bar
                        const Spacer(),

                        const SizedBox(height: 20),
                        SizedBox(
                          height: 320,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder<String?>(
                                future: StorageService.getServerUrl(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    final serverUrl = snapshot.data!;
                                    final imageTag = song.imageTags['Primary'];

                                    if (imageTag != null) {
                                      final imageUrl =
                                          '$serverUrl/Items/${song.id}/Images/Primary?tag=$imageTag&quality=90';
                                      return Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.blue.shade900,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.music_note,
                                                    color: Colors.white,
                                                    size: 80,
                                                  ),
                                                ),
                                              );
                                            },
                                      );
                                    }
                                  }
                                  return Container(
                                    color: Colors.blue.shade900,
                                    child: const Center(
                                      child: Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Song Title and Artist
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song.artist,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                song.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: song.isFavorite
                                    ? Colors.red
                                    : Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                // Toggle favorite (not implemented in service yet)
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Additional Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.repeat,
                                color: player.loopMode != LoopMode.off
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.6),
                                size: 24,
                              ),
                              onPressed: player.toggleRepeat,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color: player.isShuffle
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.6),
                                size: 24,
                              ),
                              onPressed: player.toggleShuffle,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.playlist_play,
                                color: Colors.white.withOpacity(0.6),
                                size: 24,
                              ),
                              onPressed: () => _showPlaylist(context),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Progress Bar
                        StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = player.duration;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 7,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white
                                        .withOpacity(0.2),
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: position.inSeconds.toDouble().clamp(
                                      0,
                                      duration.inSeconds.toDouble(),
                                    ),
                                    min: 0,
                                    max: duration.inSeconds.toDouble(),
                                    onChanged: (value) {
                                      player.seek(
                                        Duration(seconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: player.previous,
                            ),
                            const SizedBox(width: 24),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  player.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: player.isPlaying
                                    ? player.pause
                                    : player.play,
                              ),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: player.next,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
