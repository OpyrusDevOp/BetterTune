import 'package:bettertune/models/album.dart';
import 'package:bettertune/presentations/components/album_card.dart';
import 'package:flutter/material.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => AlbumsPageState();
}

class AlbumsPageState extends State<AlbumsPage> {
  bool selectionMode = false;
  Set<Album> selectedAlbums = {};

  final albums = List<Album>.generate(
    20,
    (index) => Album(
      id: index.toString(),
      title: 'Album $index',
      year: 2025,
      artist: 'Futur',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedAlbums.isNotEmpty || selectionMode) {
          setState(() {
            selectedAlbums.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          children: List.generate(albums.length, (index) {
            final album = albums[index];
            return AlbumCard(
              album: album,
              selectionMode: selectionMode,
              isSelect: selectedAlbums.contains(album),
              onSelection: () => onAlbumSelection(album),
              onPress: () {},
            );
          }),
        ),
      ),
    );
  }

  void onAlbumSelection(Album album) {
    if (!selectionMode) {
      selectedAlbums.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedAlbums.contains(album)) {
        selectedAlbums.remove(album);
      } else {
        selectedAlbums.add(album);
      }
      // Optional: Exit selection mode if all deselected?
      if (selectedAlbums.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
