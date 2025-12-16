import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/pages/details/playlist_details_page.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/pages/song_selection_page.dart';
import 'package:flutter/material.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {
  bool selectionMode = false;
  Set<Playlist> selectedPlaylists = {};
  late Future<List<Playlist>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = PlaylistService().getPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !selectionMode,
        child: FloatingActionButton(
          onPressed: () => _createNewPlaylist(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
          if (didPop) return;
          if (selectedPlaylists.isNotEmpty || selectionMode) {
            setState(() {
              selectedPlaylists.clear();
              selectionMode = false;
            });
            return;
          }
          if (context.mounted) Navigator.pop(context);
        },
        child: FutureBuilder<List<Playlist>>(
          future: _playlistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final playlists = snapshot.data ?? [];

            if (playlists.isEmpty) {
              return const Center(child: Text("No playlists found"));
            }

            return Stack(
              children: [
                ListView.builder(
                  itemCount: playlists.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isSelected = selectedPlaylists.contains(playlist);
                    return ListTile(
                      leading: const Icon(Icons.queue_music, size: 30),
                      title: Text(playlist.name),
                      selected: isSelected,
                      trailing: selectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (v) => onPlaylistSelection(playlist),
                            )
                          : IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () =>
                                  _showPlaylistOptions(context, playlist),
                            ),
                      onTap: () {
                        if (selectionMode) {
                          onPlaylistSelection(playlist);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlaylistDetailsPage(playlist: playlist),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!selectionMode) {
                          onPlaylistSelection(playlist);
                        }
                      },
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SelectionBottomBar(
                    selectionCount: selectedPlaylists.length,
                    onPlay: () async {
                      List<Song> allSongs = [];
                      for (var playlist in selectedPlaylists) {
                        final songs = await PlaylistService().getPlaylistItems(
                          playlist.id,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        // Play Selection: Sequential
                        await AudioPlayerService().setShuffleMode(false);
                        await AudioPlayerService().setQueue(allSongs);
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/player');
                          setState(() {
                            selectedPlaylists.clear();
                            selectionMode = false;
                          });
                        }
                      }
                    },
                    onAddToQueue: () async {
                      List<Song> allSongs = [];
                      for (var playlist in selectedPlaylists) {
                        final songs = await PlaylistService().getPlaylistItems(
                          playlist.id,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        await AudioPlayerService().addToQueueList(allSongs);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Added playlists to queue"),
                            ),
                          );
                          setState(() {
                            selectedPlaylists.clear();
                            selectionMode = false;
                          });
                        }
                      }
                    },
                    onAddToPlaylist: () async {
                      List<Song> allSongs = [];
                      for (var playlist in selectedPlaylists) {
                        final songs = await PlaylistService().getPlaylistItems(
                          playlist.id,
                        );
                        allSongs.addAll(songs);
                      }
                      if (context.mounted) {
                        showAddToPlaylistDialog(context, allSongs);
                      }
                      setState(() {
                        selectedPlaylists.clear();
                        selectionMode = false;
                      });
                    },
                    onDelete: () => _deleteSelectedPlaylists(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _createNewPlaylist(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Playlist Name"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "My Playlist"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    final name = controller.text;
                    final newId = await PlaylistService().createPlaylist(name);

                    if (context.mounted) {
                      Navigator.pop(context); // Close create dialog

                      if (newId != null) {
                        // Refresh list
                        setState(() {
                          _playlistsFuture = PlaylistService().getPlaylists();
                        });

                        // Ask to add songs
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Add Songs?"),
                            content: Text(
                              "Playlist '$name' created. Do you want to add songs to it now?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Navigate to Song Selection
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongSelectionPage(
                                        playlistId: newId,
                                        playlistName: name,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint("Failed to create playlist: $e");
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void onPlaylistSelection(Playlist playlist) {
    if (!selectionMode) {
      selectedPlaylists.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedPlaylists.contains(playlist)) {
        selectedPlaylists.remove(playlist);
      } else {
        selectedPlaylists.add(playlist);
      }
      if (selectedPlaylists.isEmpty) {
        selectionMode = false;
      }
    });
  }

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                _playPlaylist(playlist, shuffle: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Shuffle'),
              onTap: () {
                Navigator.pop(context);
                _playPlaylist(playlist, shuffle: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add to Queue'),
              onTap: () {
                Navigator.pop(context);
                _addToQueue(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                _addToPlaylist(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renamePlaylist(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteSinglePlaylist(playlist);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _playPlaylist(Playlist playlist, {required bool shuffle}) async {
    final songs = await PlaylistService().getPlaylistItems(playlist.id);
    if (songs.isNotEmpty) {
      await AudioPlayerService().setShuffleMode(shuffle);
      await AudioPlayerService().setQueue(songs);
      if (mounted) {
        Navigator.pushNamed(context, '/player');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Playlist is empty")));
      }
    }
  }

  Future<void> _addToQueue(Playlist playlist) async {
    final songs = await PlaylistService().getPlaylistItems(playlist.id);
    if (songs.isNotEmpty) {
      await AudioPlayerService().addToQueueList(songs);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to queue")));
      }
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    final songs = await PlaylistService().getPlaylistItems(playlist.id);
    if (mounted) {
      showAddToPlaylistDialog(context, songs);
    }
  }

  void _renamePlaylist(Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
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
                    playlist.id,
                    controller.text,
                  );
                  setState(() {
                    _playlistsFuture = PlaylistService().getPlaylists();
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSinglePlaylist(Playlist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Playlist?"),
        content: Text("Delete '${playlist.name}'?"),
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
      await PlaylistService().deletePlaylist(playlist.id);
      setState(() {
        _playlistsFuture = PlaylistService().getPlaylists();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Playlist deleted")));
      }
    }
  }

  Future<void> _deleteSelectedPlaylists() async {
    if (selectedPlaylists.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Playlists?"),
        content: Text(
          "Are you sure you want to delete ${selectedPlaylists.length} playlists?",
        ),
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
      for (var p in selectedPlaylists) {
        await PlaylistService().deletePlaylist(p.id);
      }
      setState(() {
        _playlistsFuture = PlaylistService().getPlaylists();
        selectedPlaylists.clear();
        selectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Playlists deleted")));
      }
    }
  }
}
