import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/global_action_buttons.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bettertune/presentations/utils/song_options_helper.dart';
import 'package:bettertune/services/audio_player_service.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  Future<List<Song>>? _playlistSongsFuture;
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    _playlistSongsFuture = PlaylistService().getPlaylistItems(
      widget.playlist.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _renamePlaylist();
              } else if (value == 'delete') {
                _deletePlaylist();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              GlobalActionButtons(
                onPlayAll: () async {
                  if (_playlistSongsFuture != null) {
                    final songs = await _playlistSongsFuture!;
                    if (songs.isNotEmpty) {
                      await AudioPlayerService().setShuffleMode(false);
                      await AudioPlayerService().setQueue(songs);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/player');
                      }
                    }
                  }
                },
                onShuffle: () async {
                  if (_playlistSongsFuture != null) {
                    final songs = await _playlistSongsFuture!;
                    if (songs.isNotEmpty) {
                      await AudioPlayerService().setShuffleMode(true);
                      await AudioPlayerService().setQueue(songs);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/player');
                      }
                    }
                  }
                },
                onAddToPlaylist: () async {
                  if (_playlistSongsFuture != null) {
                    final songs = await _playlistSongsFuture!;
                    if (context.mounted) {
                      showAddToPlaylistDialog(context, songs);
                    }
                  }
                },
              ),
              Expanded(
                child: FutureBuilder<List<Song>>(
                  future: _playlistSongsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final songs = snapshot.data ?? [];

                    if (songs.isEmpty) {
                      return const Center(
                        child: Text("This playlist is empty."),
                      );
                    }

                    return ReorderableListView.builder(
                      itemCount: songs.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      onReorder: (oldIndex, newIndex) async {
                        // Optimistic update
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final song = songs.removeAt(oldIndex);
                        songs.insert(newIndex, song);
                        setState(() {}); // Rebuild UI immediately

                        // Call API
                        await PlaylistService().movePlaylistItem(
                          widget.playlist.id,
                          song.id,
                          newIndex,
                        );
                      },
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        final isSelected = selectedSongs.contains(song);
                        return KeyedSubtree(
                          key: ValueKey(song.id),
                          child: SongTile(
                            song: song,
                            isSelect: isSelected,
                            selectionMode: selectionMode,
                            onSelection: () => onSongSelection(song),
                            onPress: () {
                              if (selectionMode) {
                                onSongSelection(song);
                              } else {
                                // Play Playlist Context
                                AudioPlayerService().setShuffleMode(false);
                                AudioPlayerService().setQueue(
                                  songs,
                                  initialIndex: index,
                                );
                                Navigator.of(context).pushNamed('/player');
                              }
                            },
                            trailing: selectionMode
                                ? null
                                : ReorderableDragStartListener(
                                    index: index,
                                    child: IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () =>
                                          showSongOptions(context, song),
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedSongs.length,
              onPlay: () {
                if (selectedSongs.isNotEmpty) {
                  AudioPlayerService().setQueue(selectedSongs.toList());
                  Navigator.pushNamed(context, '/player');
                  setState(() {
                    selectedSongs.clear();
                    selectionMode = false;
                  });
                }
              },
              onAddToQueue: () async {
                if (selectedSongs.isNotEmpty) {
                  await AudioPlayerService().addToQueueList(
                    selectedSongs.toList(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Added ${selectedSongs.length} songs to queue",
                        ),
                      ),
                    );
                  }
                  setState(() {
                    selectedSongs.clear();
                    selectionMode = false;
                  });
                }
              },
              onAddToPlaylist: () {
                showAddToPlaylistDialog(context, selectedSongs.toList());
                setState(() {
                  selectedSongs.clear();
                  selectionMode = false;
                });
              },
              onDelete: () async {
                if (selectedSongs.isEmpty) return;

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Remove Songs?"),
                    content: Text(
                      "Remove ${selectedSongs.length} songs from this playlist?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Remove",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final ids = selectedSongs.map((s) => s.id).toList();
                  await PlaylistService().removeItemsFromPlaylist(
                    widget.playlist.id,
                    ids,
                  );

                  setState(() {
                    _playlistSongsFuture = PlaylistService().getPlaylistItems(
                      widget.playlist.id,
                    );
                    selectedSongs.clear();
                    selectionMode = false;
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Songs removed")));
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void onSongSelection(Song song) {
    if (!selectionMode) {
      setState(() => selectionMode = true);
    }
    setState(() {
      if (selectedSongs.contains(song)) {
        selectedSongs.remove(song);
      } else {
        selectedSongs.add(song);
      }
      if (selectedSongs.isEmpty) {
        selectionMode = false;
      }
    });
  }

  void _renamePlaylist() {
    final controller = TextEditingController(text: widget.playlist.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Playlist"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await PlaylistService().renamePlaylist(
                    widget.playlist.id,
                    controller.text,
                  );
                  Navigator.pop(context); // Close dialog
                  // Note: The parent page needs to refresh to show new name in title,
                  // or we can just pop this page too.
                  // For now, let's just updated the UI here if we could, but widget.playlist is final.
                  // Simplest is to pop back.
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlaylist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Playlist?"),
        content: Text("Delete '${widget.playlist.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PlaylistService().deletePlaylist(widget.playlist.id);
      if (mounted) {
        Navigator.pop(context); // Go back to playlists
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Playlist deleted")));
      }
    }
  }
}
