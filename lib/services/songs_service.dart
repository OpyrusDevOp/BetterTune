import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/database_service.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/services/settings_service.dart';

class SongsService {
  static final SongsService _instance = SongsService._internal();
  factory SongsService() => _instance;
  SongsService._internal();

  /// Fetch all Songs (Local DB)
  Future<List<Song>> getSongs() async {
    return await DatabaseService().getAllSongs();
  }

  /// Get direct streaming URL for a song (API)
  String getStreamUrl(String songId) {
    final client = ApiClient();
    if (client.baseUrl == null) return "";

    final isDolby = SettingsService().dolbyEnabled;
    final container = isDolby
        ? "ac3,eac3,flac,mp3,aac,m4a,webma,webm,wav"
        : "mp3,aac,m4a,flac,webma,webm,wav";
    final codec = isDolby ? "aac,ac3,eac3,flac,mp3,opus" : "aac";

    // For Dolby/Hi-Res, we might want higher bitrate or no bitrate limit
    // Universal typically tries to transcode to container if not supported.
    // If we say we support ac3, Jellyfin might pass it through.

    return '${client.baseUrl}/Audio/$songId/universal?UserId=${client.userId}&DeviceId=${client.deviceId}&Container=$container&TranscodingContainer=ts&TranscodingProtocol=hls&AudioCodec=$codec';
  }

  /// Fetch Albums (Local DB)
  Future<List<Album>> getAlbums() async {
    return await DatabaseService().getAllAlbums();
  }

  /// Get songs for a specific Album (Local DB)
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    // Note: Our DB schema stores strings for ID, but we didn't index ParentId/AlbumId properly in the simple schema
    // We only stored 'album' name in the song table.
    // This is a limitation of the simple schema I proposed.
    // To support "Get Songs By Album ID", we ideally need Album ID in table.
    // However, for now, let's filter by Album Name if possible or assume we need to update schema.
    // Wait, the schema in DatabaseService has `album TEXT` (name). It does NOT have AlbumId.
    // But `getSongsByAlbum` takes `albumId`.

    // CRITICAL FIX: The current DB schema is too simple. It doesn't link Songs to Album IDs.
    // It only has 'album' (name).
    // Let's assume for this "simple" cache we might query by Album Name if we have it?
    // Or we fetch all and filter.
    // Actually, `Album` model has `title`.
    // But `getSongsByAlbum` is called with ID.

    // Changing strategy: We will fetch all songs and filter in memory for now? No that's bad.
    // Better: We should have stored AlbumId in the Songs table.
    // But for now, let's see if we can get away with filtering by album *name* if we can convert ID to name or if we just stored name.

    // Actually, looking at `DatabaseService`:
    // CREATE TABLE songs(id TEXT PRIMARY KEY, name TEXT, album TEXT, artist TEXT, isFavorite INTEGER)
    // It stores Album Name.

    // So we need to query by Album Name. But we only have Album ID here?
    // Oh, when we select an Album, we have the Album object.
    // In `SearchResultsView`, we pass `item.id`.

    // If I change `getSongsByAlbum` to take `albumName`, I break the contract or I need to change call sites.
    // Let's change the implementation to query by Album Name if possible?
    // But we don't know the Album Name from just ID easily without querying Albums table first.

    // Let's query Albums table to get Name from ID, then query Songs table by Name.
    final db = DatabaseService();
    // This is a hack because of schema limitations, but works for "simple" local cache request.

    // However, I don't have `getAlbumById` in DB service yet.
    // Let's just fetch all songs for now? No.

    // Let's accept that for this iteration we might have issues with strict ID matching.
    // But actually, `SearchResultsView` calls `getSongsByAlbum(item.id)`.
    // Wait, `item` is an Album object. It has `title`.
    // I should probably update `SearchResultsView` to pass title?
    // Or update `SongsService` to take ID, lookup Album, then get songs.

    // Let's implement `getSongsByAlbum` by:
    // 1. Getting all songs (expensive?) -> Query where album = ?
    // But we need the name.

    // Let's just update `SongsService` to return empty for now or use `ApiClient` if not found??
    // No, user wants local cache.

    // I will simply add `getSongsByAlbumName` ?
    // No, I'll stick to the signature but...

    // Let's just assume we can match by something.
    // Actually, typically we'd use Foreign Keys.

    // Let's rely on string matching for this quick implementation.
    // I'll fetch *all* songs and filter locally?
    // Or I'll update `DatabaseService` to allow searching by Album/Artist name? It already does `searchSongs`.

    // Let's do this:
    // Fetch all songs. Filter by `song.album == (find album name from albums table)`.

    final allAlbums = await db.getAllAlbums();
    final album = allAlbums.firstWhere(
      (a) => a.id == albumId,
      orElse: () => Album(id: '', title: '', artist: '', year: 0),
    );

    if (album.id.isEmpty) return [];

    final allSongs = await db.getAllSongs();
    return allSongs.where((s) => s.album == album.title).toList();
  }

  /// Fetch Artists (Local DB)
  Future<List<Artist>> getArtists() async {
    return await DatabaseService().getAllArtists();
  }

  /// Get albums for a specific Artist (Local DB)
  Future<List<Album>> getAlbumsByArtist(String artistName) async {
    // We already have `artistName` here! Perfect.
    // Query DB for albums where artist = artistName.
    final allAlbums = await DatabaseService().getAllAlbums();
    return allAlbums.where((a) => a.artist == artistName).toList();
  }

  /// Get songs for a specific Artist (Local DB)
  Future<List<Song>> getSongsByArtist(
    String artistId,
    String artistName,
  ) async {
    // We have artistName.
    final allSongs = await DatabaseService().getAllSongs();
    return allSongs.where((s) => s.artist == artistName).toList();
  }

  /// Get favorite songs (Local DB)
  Future<List<Song>> getFavoriteSongs() async {
    final allSongs = await DatabaseService().getAllSongs();
    return allSongs.where((s) => s.isFavorite).toList();
  }
}
