import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';

// Web implementation — in-memory store (no SQLite on web).
// Data lives for the session; re-synced from Jellyfin on each reload.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final List<Song> _songs = [];
  final List<Album> _albums = [];
  final List<Artist> _artists = [];

  Future<void> clearAll() async {
    _songs.clear();
    _albums.clear();
    _artists.clear();
  }

  Future<void> insertSongs(List<Song> songs) async {
    for (final s in songs) {
      _songs.removeWhere((e) => e.id == s.id);
      _songs.add(s);
    }
    _songs.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> insertAlbums(List<Album> albums) async {
    for (final a in albums) {
      _albums.removeWhere((e) => e.id == a.id);
      _albums.add(a);
    }
    _albums.sort((a, b) => a.title.compareTo(b.title));
  }

  Future<void> insertArtists(List<Artist> artists) async {
    for (final a in artists) {
      _artists.removeWhere((e) => e.id == a.id);
      _artists.add(a);
    }
    _artists.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Song>> getAllSongs() async => List.unmodifiable(_songs);
  Future<List<Album>> getAllAlbums() async => List.unmodifiable(_albums);
  Future<List<Artist>> getAllArtists() async => List.unmodifiable(_artists);

  Future<List<Song>> searchSongs(String query) async {
    final q = query.toLowerCase();
    return _songs
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }

  Future<List<Album>> searchAlbums(String query) async {
    final q = query.toLowerCase();
    return _albums
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q))
        .toList();
  }

  Future<List<Artist>> searchArtists(String query) async {
    final q = query.toLowerCase();
    return _artists.where((a) => a.name.toLowerCase().contains(q)).toList();
  }
}
