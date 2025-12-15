import 'package:bettertune/models/song.dart';
import 'package:bettertune/data/playlist_repository.dart';
import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageStateSongsPage();
}

class _SongsPageStateSongsPage extends State<SongsPage> {
  bool selectionMode = false;

  // Mock data for now
  final songs = List<Song>.generate(
    20,
    (index) => Song(
      id: index.toString(),
      name: 'Song Title $index',
      album: 'Album Name $index',
      artist: 'Artist Name',
      isFavorite: false,
    ),
  );

  Set<Song> selectedSongs = {};

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
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
        // Don't pop main screen
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: songs.length,
            padding: const EdgeInsets.only(bottom: 100), // Space for MiniPlayer
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
                    print("Play ${selectedSongs.length} items");
                    _exitSelection();
                  },
                  onAddToPlaylist: () {
                    _showAddToPlaylistDialog(context, selectedSongs.toList());
                    _exitSelection();
                  },
                ),
              ),
            ),
        ],
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
    Navigator.of(context).pushNamed('/player'); // Start player
    // Note: Actual navigation needs route setup or direct push
    // Since PlayerScreen is a modal in standard flow, we might need a GlobalKey or just Push
    // Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen()));
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

  void _showAddToPlaylistDialog(BuildContext context, List<Song> songsToAdd) {
    // Fetch playlists (mock)
    final repo = PlaylistRepository();
    // In real app use FutureBuilder or state management
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Playlist>>(
          future: repo.getPlaylists(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            final playlists = snapshot.data!;

            return AlertDialog(
              title: Text("Add to Playlist"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length + 1, // +1 for "New Playlist"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.add),
                        title: Text("New Playlist"),
                        onTap: () {
                          Navigator.pop(context);
                          _createNewPlaylist(context, songsToAdd);
                        },
                      );
                    }
                    final p = playlists[index - 1];
                    return ListTile(
                      leading: Icon(Icons.playlist_play),
                      title: Text(p.name),
                      subtitle: Text("${p.songs.length} songs"),
                      onTap: () async {
                        for (var s in songsToAdd) {
                          await repo.addSongToPlaylist(p.id, s);
                        }
                        if (context.mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to ${p.name}")),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createNewPlaylist(BuildContext context, List<Song> songsToAdd) {
    print("Create Playlist Logic here");
    // Dialog to get name, then create and add
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
                leading: Icon(Icons.play_arrow),
                title: Text("Play Next"),
                onTap: () {
                  Navigator.pop(context);
                  print("Play Next: ${song.name}");
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text("Add to Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog(context, [song]);
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
