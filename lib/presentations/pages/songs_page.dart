import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/services/sync_service.dart'; // Added SyncService
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageStateSongsPage();
}

class _SongsPageStateSongsPage extends State<SongsPage> {
  bool selectionMode = false;
  List<Song> songs = [];
  Set<Song> selectedSongs = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    try {
      final localSongs = await SongsService().getSongs();
      setState(() {
        songs = localSongs;
      });

      // If empty, suggest sync or auto-sync?
      // Let's just user helper manually sync for now or empty state handles it.
    } catch (e) {
      debugPrint("Error loading songs: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerSync() async {
    if (SyncService().isSyncing) return;

    // Show progress dialog or snackbar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    await SyncService().syncLibrary((status) {
      debugPrint("Sync: $status");
    });

    if (mounted) {
      Navigator.pop(context); // Close dialog
      _loadSongs(); // Reload from DB
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _triggerSync,
            tooltip: "Sync Library",
          ),
        ],
      ),
      body: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
          if (didPop) return;
          if (selectedSongs.isNotEmpty) {
            setState(() {
              selectedSongs.clear();
              selectionMode = false;
            });
            return;
          }
        },
        child: Stack(
          children: [
            if (songs.isEmpty && _isLoading)
              const Center(child: CircularProgressIndicator())
            else if (songs.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("No songs found locally."),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _triggerSync,
                      child: Text("Sync Library"),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  var song = songs[index];
                  var isSelected = selectedSongs.contains(song);

                  return SongTile(
                    song: song,
                    isSelect: isSelected,
                    onPress: () => onSongClick(song),
                    onSelection: () => onSongSelection(song),
                    selectionMode: selectionMode,
                    trailing: selectionMode
                        ? null
                        : IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () => _showSongOptions(context, song),
                          ),
                  );
                },
              ),

            if (selectionMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SelectionBottomBar(
                    selectionCount: selectedSongs.length,
                    onPlay: () {
                      if (selectedSongs.isNotEmpty) {
                        AudioPlayerService().setQueue(selectedSongs.toList());
                        Navigator.pushNamed(context, '/player');
                        _exitSelection();
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
                        _exitSelection();
                      }
                    },
                    onAddToPlaylist: () {
                      showAddToPlaylistDialog(context, selectedSongs.toList());
                      _exitSelection();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _exitSelection() {
    setState(() {
      selectedSongs.clear();
      selectionMode = false;
    });
  }

  void onSongClick(Song song) {
    // Open Player
    print("Playing ${song.name}");
    if (selectionMode) {
      onSongSelection(song);
    } else {
      _playAndOpenPlayer(song);
    }
  }

  void _playAndOpenPlayer(Song song) {
    // Find index
    int index = songs.indexOf(song);
    if (index == -1) index = 0;

    AudioPlayerService().setQueue(songs, initialIndex: index);
    Navigator.pushNamed(context, '/player');
  }

  void onSongSelection(Song song) {
    setState(() {
      if (!selectionMode) selectionMode = true;
      if (selectedSongs.contains(song)) {
        selectedSongs.remove(song);
      } else {
        selectedSongs.add(song);
      }
      if (selectedSongs.isEmpty) selectionMode = false;
    });
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text("Play"),
                onTap: () {
                  Navigator.pop(context);
                  _playAndOpenPlayer(song);
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text("Add to Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  showAddToPlaylistDialog(context, [song]);
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Go to Artist"),
                onTap: () {
                  Navigator.pop(context);
                  print("Go to Artist: ${song.artist}");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
