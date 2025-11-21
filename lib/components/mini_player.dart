import 'package:flutter/material.dart';

import '../screens/player_screen.dart';

import 'package:provider/provider.dart';
import '../services/player_service.dart';
import '../services/storage_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  Route<void> _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, player, child) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = player.duration;
                  double value = 0.0;
                  if (duration.inMilliseconds > 0) {
                    value = position.inMilliseconds / duration.inMilliseconds;
                    if (value > 1.0) value = 1.0;
                  }

                  return SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 0,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: value,
                      onChanged: (v) {
                        final newPosition = duration * v;
                        player.seek(newPosition);
                      },
                    ),
                  );
                },
              ),

              // Player Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    // Album Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<String?>(
                        future: StorageService.getServerUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final serverUrl = snapshot.data!;
                            final imageTag = song.imageTags['Primary'];

                            if (imageTag != null) {
                              final imageUrl =
                                  '$serverUrl/Items/${song.id}/Images/Primary?tag=$imageTag&quality=90';
                              return Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.blue.shade900,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              );
                            }
                          }
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.blue.shade900,
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Song Info
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(_createRoute());
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Playback Controls
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed: player.previous,
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: player.isPlaying ? player.pause : player.play,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: player.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
