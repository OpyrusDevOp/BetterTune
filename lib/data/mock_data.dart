import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';

class MockData {
  const MockData._();

  static final List<Song> songs = List.generate(
    50,
    (index) => Song(
      id: "s_$index",
      name: 'Song $index',
      album: 'Album ${index % 10}',
      artist: 'Artist ${index % 5}',
      isFavorite: index % 3 == 0,
    ),
  );

  static final List<Album> albums = List.generate(
    10,
    (index) => Album(
      id: "al_$index",
      title: 'Album $index',
      year: 2020 + (index % 5),
      artist: 'Artist ${index % 5}',
    ),
  );

  static final List<Artist> artists = List.generate(
    5,
    (index) => Artist(id: "ar_$index", name: 'Artist $index'),
  );

  static final List<Playlist> playlists = List.generate(
    8,
    (index) => Playlist(
      id: "pl_$index",
      name: 'Playlist $index',
      songs: songs.take((index + 1) * 2).toList(),
    ),
  );

  static List<Song> getSongsForAlbum(String albumName) {
    return songs.where((s) => s.album == albumName).toList();
  }

  static List<Song> getSongsForArtist(String artistName) {
    return songs.where((s) => s.artist == artistName).toList();
  }
}
