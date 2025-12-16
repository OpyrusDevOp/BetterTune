import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/models/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:bettertune/presentations/screens/player_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});
  @override
  State<MiniPlayer> createState() => MiniPlayerState();
}

class MiniPlayerState extends State<MiniPlayer> {
  final AudioPlayerService _playerService = AudioPlayerService();

  void openPlayer() => Navigator.of(context).push(_createRoute());

  Route<void> _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Song?>(
      stream: _playerService.currentSongStream,
      initialData: _playerService.currentSong,
      builder: (context, songSnapshot) {
        final song = songSnapshot.data;
        if (song == null) {
          // Hide mini player if no song is playing
          return const SizedBox.shrink();
        }

        final imageUrl = ApiClient().getImageUrl(
          song.id,
          width: 100,
          height: 100,
        );

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: InkWell(
            onTap: openPlayer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.music_note,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.music_note,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Meta Data
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  // Previous
                  IconButton(
                    onPressed: _playerService.skipToPrevious,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),

                  // Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: _playerService.playerStateStream,
                    builder: (context, stateSnapshot) {
                      final playerState = stateSnapshot.data;
                      final playing = playerState?.playing ?? false;
                      final processingState = playerState?.processingState;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      return IconButton(
                        onPressed: () {
                          if (playing) {
                            _playerService.pause();
                          } else {
                            _playerService.play();
                          }
                        },
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        iconSize: 32,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),

                  // Next
                  IconButton(
                    onPressed: _playerService.skipToNext,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
