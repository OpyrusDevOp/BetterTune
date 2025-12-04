import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageStateSongsPage();
}

class _SongsPageStateSongsPage extends State<SongsPage> {
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListView.builder(
        itemCount: songs.length,

        itemBuilder: (context, index) => SongTile(song: songs[index]),
      ),
    );
  }
}
