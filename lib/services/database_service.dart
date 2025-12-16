import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bettertune.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE songs(
            id TEXT PRIMARY KEY,
            name TEXT,
            album TEXT,
            artist TEXT,
            isFavorite INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE albums(
            id TEXT PRIMARY KEY,
            title TEXT,
            artist TEXT,
            year INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE artists(
            id TEXT PRIMARY KEY,
            name TEXT
          )
        ''');
      },
    );
  }

  // --- Insertions (Sync) ---

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('songs');
    await db.delete('albums');
    await db.delete('artists');
  }

  Future<void> insertSongs(List<Song> songs) async {
    final db = await database;
    final batch = db.batch();
    for (var song in songs) {
      batch.insert('songs', {
        'id': song.id,
        'name': song.name,
        'album': song.album,
        'artist': song.artist,
        'isFavorite': song.isFavorite ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertAlbums(List<Album> albums) async {
    final db = await database;
    final batch = db.batch();
    for (var album in albums) {
      batch.insert('albums', {
        'id': album.id,
        'title': album.title,
        'artist': album.artist,
        'year': album.year,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertArtists(List<Artist> artists) async {
    final db = await database;
    final batch = db.batch();
    for (var artist in artists) {
      batch.insert('artists', {
        'id': artist.id,
        'name': artist.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // --- Queries ---

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final maps = await db.query('songs', orderBy: 'name ASC');
    return maps.map((m) => _songFromMap(m)).toList();
  }

  Future<List<Album>> getAllAlbums() async {
    final db = await database;
    final maps = await db.query('albums', orderBy: 'title ASC');
    return maps.map((m) => _albumFromMap(m)).toList();
  }

  Future<List<Artist>> getAllArtists() async {
    final db = await database;
    final maps = await db.query('artists', orderBy: 'name ASC');
    return maps.map((m) => _artistFromMap(m)).toList();
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await database;
    final maps = await db.query(
      'songs',
      where: 'name LIKE ? OR artist LIKE ? OR album LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => _songFromMap(m)).toList();
  }

  Future<List<Album>> searchAlbums(String query) async {
    final db = await database;
    final maps = await db.query(
      'albums',
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((m) => _albumFromMap(m)).toList();
  }

  Future<List<Artist>> searchArtists(String query) async {
    final db = await database;
    final maps = await db.query(
      'artists',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => _artistFromMap(m)).toList();
  }

  // Helpers

  Song _songFromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      name: map['name'],
      album: map['album'],
      artist: map['artist'],
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  Album _albumFromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      year: map['year'],
    );
  }

  Artist _artistFromMap(Map<String, dynamic> map) {
    return Artist(id: map['id'], name: map['name']);
  }
}
