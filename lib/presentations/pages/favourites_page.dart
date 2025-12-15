import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/data/playlist_repository.dart';
import 'package:bettertune/models/playlist.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => FavouritesPageState();
}

class FavouritesPageState extends State<FavouritesPage> {
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  final songs = List<Song>.generate(
    20,
    (index) => Song(
      id: "fav_$index",
      name: 'Favorite Song $index',
      album: 'Favorite Album',
      artist: 'Favorite Artist',
      isFavorite: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedSongs.isNotEmpty || selectionMode) {
          setState(() {
            selectedSongs.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: selectionMode ? 100 : 20),
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
                padding: const EdgeInsets.only(bottom: 80.0),
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
    if (selectionMode) {
      onSongSelection(song);
    } else {
      // Play logic
      print("Play ${song.name}");
    }
  }

  void onSongSelection(Song song) {
    if (selectionMode == false) {
      selectedSongs.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(
      () => selectedSongs.contains(song)
          ? selectedSongs.remove(song)
          : selectedSongs.add(song),
    );

    if (selectedSongs.isEmpty) {
      setState(() {
        selectionMode = false;
      });
    }
  }

  void _showAddToPlaylistDialog(BuildContext context, List<Song> songsToAdd) {
    final repo = PlaylistRepository();
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
                  itemCount: playlists.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.add),
                        title: Text("New Playlist"),
                        onTap: () {
                          Navigator.pop(context);
                          // create playlist logic
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
            ],
          ),
        );
      },
    );
  }
}
