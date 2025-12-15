import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => FavouritesPageState();
}

class FavouritesPageState extends State<FavouritesPage> {
  bool selectionMode = false;
  Set<Song> selectedSongs = {};
  late Future<List<Song>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = SongsService().getFavoriteSongs();
  }

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
      child: FutureBuilder<List<Song>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return const Center(child: Text("No favorites found."));
          }

          return Stack(
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
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showSongOptions(context, song),
                          ),
                  );
                },
              ),
              if (selectionMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0.0,
                    ), // Fixed padding
                    child: SelectionBottomBar(
                      selectionCount: selectedSongs.length,
                      onPlay: () {
                        print("Play ${selectedSongs.length} items");
                        _exitSelection();
                      },
                      onAddToPlaylist: () {
                        _showAddToPlaylistDialog(
                          context,
                          selectedSongs.toList(),
                        );
                        _exitSelection();
                      },
                    ),
                  ),
                ),
            ],
          );
        },
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
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Playlist>>(
          future: PlaylistService().getPlaylists(),
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
                          // create playlist logic - similar to SongsPage if needed, or just show not implemented for now
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Create Playlist WIP")),
                          );
                        },
                      );
                    }
                    final p = playlists[index - 1];
                    return ListTile(
                      leading: Icon(Icons.playlist_play),
                      title: Text(p.name),
                      // subtitle: Text("${p.songs.length} songs"), // No song count in simple model
                      onTap: () async {
                        List<String> ids = songsToAdd.map((s) => s.id).toList();
                        await PlaylistService().addToPlaylist(p.id, ids);

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
