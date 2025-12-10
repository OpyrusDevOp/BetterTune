import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView.builder(
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
            );
          },
        ),
      ),
    );
  }

  void onSongClick(Song song) {
    if (selectionMode) {
      onSongSelection(song);
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
}
