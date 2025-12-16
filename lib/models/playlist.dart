import 'package:bettertune/models/song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final String? image;

  const Playlist({
    required this.id,
    required this.name,
    this.songs = const [],
    this.image,
  });

  int get songCount => songs.length;
}
