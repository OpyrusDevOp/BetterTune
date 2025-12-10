import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageStateSongsPage();
}

class _SongsPageStateSongsPage extends State<SongsPage> {
  bool selectionMode = false;

  final songs = List<Song>.generate(
    20,
    (index) => Song(
      id: index.toString(),
      name: 'Song $index',
      album: 'album $index',
      artist: 'Future',
      isFavorite: false,
    ),
  );

  Set<Song> selectedSongs = {};

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) {
          return;
        }
        if (selectedSongs.isNotEmpty) {
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView.builder(
              itemCount: songs.length,
              // Add bottom padding to avoid obstruction by bottom bar
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                var song = songs[index];
                var isSelected = selectedSongs.contains(song);
                return SongTile(
                  song: song,
                  isSelect: isSelected,
                  onPress: () => onSongClick(song),
                  onSelection: () => onSongSelection(song),
                  selectionMode: selectionMode,
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedSongs.length,
              onPlay: () => print("Play Selected Songs"),
              onAddToPlaylist: () => print("Add Selected to Playlist"),
            ),
          ),
        ],
      ),
    );
  }

  void onSongClick(Song song) {}

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

    if (kDebugMode) {
      print("Select ${song.name}");
      print("Selection count : ${selectedSongs.length}");
    }
  }
}
