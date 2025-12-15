import 'package:bettertune/services/api_client.dart'; // For image URL
import 'package:bettertune/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart'; // For PlayerState
import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// ...

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayerService _playerService = AudioPlayerService();

  // Queue State
  bool selectionMode = false;
  Set<Song> selectedQueueItems = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 40),
        ),
        title: const Text("Now Playing"),
        centerTitle: true,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: StreamBuilder<Song?>(
          stream: _playerService.currentSongStream,
          initialData: _playerService.currentSong,
          builder: (context, songSnapshot) {
            final song = songSnapshot.data;
            if (song == null) {
              return const Center(child: Text("No Song Playing"));
            }

            final imageUrl = ApiClient().getImageUrl(
              song.id,
              width: 500,
              height: 500,
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  // --- Album Art Card ---
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.music_note,
                                          size: 120,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface
                                              .withAlpha(50),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.music_note,
                                      size: 120,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface
                                          .withAlpha(50),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- Track Info ---
                  Column(
                    children: [
                      Text(
                        song.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- Progress ---
                  StreamBuilder<Duration>(
                    // Position Stream
                    stream: _playerService.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;

                      return StreamBuilder<Duration?>(
                        // Duration Stream
                        stream: _playerService.durationStream,
                        builder: (context, durSnapshot) {
                          final duration = durSnapshot.data ?? Duration.zero;

                          double sliderValue = position.inMilliseconds
                              .toDouble();
                          double max = duration.inMilliseconds.toDouble();
                          if (max <= 0) max = 1.0;
                          if (sliderValue > max) sliderValue = max;

                          return Column(
                            children: [
                              Slider(
                                value: sliderValue,
                                max: max,
                                onChanged: (v) {
                                  _playerService.seek(
                                    Duration(milliseconds: v.toInt()),
                                  );
                                },
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(30),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- Controls ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StreamBuilder<bool>(
                        stream: _playerService.shuffleModeEnabledStream,
                        builder: (context, snapshot) {
                          final shuffleEnabled = snapshot.data ?? false;
                          return IconButton(
                            onPressed: _playerService.toggleShuffle,
                            icon: const Icon(Icons.shuffle),
                            color: shuffleEnabled
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            iconSize: 28,
                          );
                        },
                      ),
                      IconButton(
                        onPressed: _playerService.skipToPrevious,
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                        iconSize: 42,
                      ),

                      // Play/Pause Button
                      StreamBuilder<PlayerState>(
                        stream: _playerService.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;

                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 72.0,
                              height: 72.0,
                              child: const CircularProgressIndicator(),
                            );
                          }

                          final isPlaying = playing ?? false;

                          return Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (isPlaying) {
                                  _playerService.pause();
                                } else {
                                  _playerService.play();
                                }
                              },
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              color: Theme.of(context).colorScheme.onPrimary,
                              iconSize: 42,
                            ),
                          );
                        },
                      ),

                      IconButton(
                        onPressed: _playerService.skipToNext,
                        icon: const Icon(Icons.skip_next_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                        iconSize: 42,
                      ),
                      StreamBuilder<LoopMode>(
                        stream: _playerService.loopModeStream,
                        builder: (context, snapshot) {
                          final loopMode = snapshot.data ?? LoopMode.off;
                          IconData icon;
                          Color color;

                          switch (loopMode) {
                            case LoopMode.one:
                              icon = Icons.repeat_one_rounded;
                              color = Theme.of(context).colorScheme.primary;
                              break;
                            case LoopMode.all:
                              icon = Icons.repeat_rounded;
                              color = Theme.of(context).colorScheme.primary;
                              break;
                            case LoopMode.off:
                            default:
                              icon = Icons.repeat_rounded;
                              color = Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant;
                              break;
                          }

                          return IconButton(
                            onPressed: _playerService.toggleRepeat,
                            icon: Icon(icon),
                            color: color,
                            iconSize: 28,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Bottom Actions ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _showQueueBottomSheet(context),
                        icon: const Icon(Icons.playlist_play_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton(
                        onPressed: () {}, // Favorite
                        icon: const Icon(Icons.favorite_border_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleSelection(Song song) {
    setState(() {
      if (!selectionMode) selectionMode = true;

      if (selectedQueueItems.contains(song)) {
        selectedQueueItems.remove(song);
      } else {
        selectedQueueItems.add(song);
      }

      if (selectedQueueItems.isEmpty) selectionMode = false;
    });
  }

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ), // Glass effect
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(200),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setStateSheet) {
                      // We must wrap the whole content in StreamBuilder to listen to queue updates
                      return StreamBuilder<List<Song>>(
                        stream: _playerService.queueStream,
                        builder: (context, snapshot) {
                          final queue = snapshot.data ?? [];
                          // Filter queue if selection mode active?
                          // For simplicity, selection operates on the displayed items.

                          void toggleSelectionInSheet(Song song) {
                            setStateSheet(() {
                              _toggleSelection(song);
                            });
                          }

                          return Column(
                            children: [
                              // Handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withAlpha(100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              // Actions Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectionMode
                                          ? "${selectedQueueItems.length} Selected"
                                          : "Up Next (${queue.length})",
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        if (selectionMode) ...[
                                          IconButton(
                                            icon: Icon(Icons.playlist_add),
                                            onPressed: () {
                                              // TODO: Implement Add to Playlist for Queue
                                              setStateSheet(() {
                                                setState(() {
                                                  selectionMode = false;
                                                  selectedQueueItems.clear();
                                                });
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline),
                                            onPressed: () {
                                              // TODO: Implement Remove from Queue in Service
                                            },
                                          ),
                                        ] else ...[
                                          TextButton(
                                            onPressed: () {
                                              // TODO: Clear Queue in Service
                                            },
                                            child: Text("Clear"),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Theme.of(context).dividerColor),

                              // Queue List
                              Expanded(
                                child: ReorderableListView.builder(
                                  buildDefaultDragHandles:
                                      false, // Important: We provide our own handle
                                  scrollController: scrollController,
                                  padding: EdgeInsets.only(bottom: 20),
                                  onReorder: (oldIndex, newIndex) {
                                    _playerService.reorder(oldIndex, newIndex);
                                  },
                                  itemCount: queue.length,
                                  itemBuilder: (context, index) {
                                    final song = queue[index];
                                    final isSelected = selectedQueueItems
                                        .contains(song);
                                    return Material(
                                      key: ValueKey(
                                        song.id,
                                      ), // Ensure unique Keys
                                      color: isSelected
                                          ? theme.colorScheme.primary.withAlpha(
                                              40,
                                            )
                                          : Colors.transparent,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 4,
                                        ),
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.music_note,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        title: Text(
                                          song.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          song.artist,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (selectionMode)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (_) =>
                                                    toggleSelectionInSheet(
                                                      song,
                                                    ),
                                              )
                                            else
                                              ReorderableDragStartListener(
                                                index: index,
                                                child: Icon(
                                                  Icons.drag_handle,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          if (selectionMode) {
                                            toggleSelectionInSheet(song);
                                          } else {
                                            // Jump to this song
                                            // We can't just jump to index bc of shuffle vs effective index
                                            // But since we are displaying effective sequence, calculating index might work?
                                            // Actually relying on original index might be safer but harder.
                                            // For now, let's just create a `jumpTo(index)` in service if needed.
                                            // Or reuse play for now.
                                          }
                                        },
                                        onLongPress: () =>
                                            toggleSelectionInSheet(song),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
