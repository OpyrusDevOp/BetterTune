import 'package:bettertune/models/album.dart';
import 'package:bettertune/presentations/components/album_card.dart';
import 'package:flutter/material.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => AlbumsPageState();
}

class AlbumsPageState extends State<AlbumsPage> {
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(15.0),
    child: GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      children: List<AlbumCard>.generate(
        albums.length,
        (index) => AlbumCard(album: albums[index]),
      ),
    ),
  );
}
