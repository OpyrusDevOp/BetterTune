import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/database_service.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool isSyncing = false;

  Future<void> syncLibrary(Function(String) onProgress) async {
    if (isSyncing) return;
    isSyncing = true;
    onProgress("Starting sync...");

    try {
      final client = ApiClient();
      final db = DatabaseService();

      if (client.userId == null) {
        throw Exception("User not logged in");
      }

      // 1. Fetch Artists
      onProgress("Fetching Artists...");
      final artists = await _fetchAllArtists(client);
      await db.insertArtists(artists);
      onProgress("Synced ${artists.length} Artists");

      // 2. Fetch Albums
      onProgress("Fetching Albums...");
      final albums = await _fetchAllAlbums(client);
      await db.insertAlbums(albums);
      onProgress("Synced ${albums.length} Albums");

      // 3. Fetch Songs
      onProgress("Fetching Songs...");
      final songs = await _fetchAllSongs(client);
      await db.insertSongs(songs);
      onProgress("Synced ${songs.length} Songs");

      onProgress("Sync Complete!");
    } catch (e) {
      debugPrint("Sync Error: $e");
      onProgress("Sync Failed: $e");
    } finally {
      isSyncing = false;
    }
  }

  Future<List<Artist>> _fetchAllArtists(ApiClient client) async {
    // Fetch all artists (no limit, or high limit)
    // Jellyfin might require paging if library is huge, but for "all",
    // a very high limit usually works for typical libraries unless huge.
    // Let's assume < 10000 artists for now.
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicArtist&SortBy=SortName&SortOrder=Ascending&Limit=50000',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Artist>((item) {
        return Artist(id: item['Id'], name: item['Name']);
      }).toList();
    }
    return [];
  }

  Future<List<Album>> _fetchAllAlbums(ApiClient client) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicAlbum&SortBy=SortName&SortOrder=Ascending&Limit=50000',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Album>((item) {
        return Album(
          id: item['Id'],
          title: item['Name'],
          artist: item['AlbumArtist'] ?? 'Unknown Artist',
          year: item['ProductionYear'] ?? 0,
        );
      }).toList();
    }
    return [];
  }

  Future<List<Song>> _fetchAllSongs(ApiClient client) async {
    // Fetch critical fields ONLY to keep payload small
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&Fields=ParentId&SortBy=SortName&SortOrder=Ascending&Limit=100000',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Song>((item) {
        return Song(
          id: item['Id'],
          name: item['Name'],
          album: item['Album'] ?? 'Unknown Album',
          artist:
              item['AlbumArtist'] ??
              (item['Artists'] != null && (item['Artists'] as List).isNotEmpty
                  ? item['Artists'][0]['Name']
                  : 'Unknown Artist'),
          isFavorite: item['UserData']?['IsFavorite'] ?? false,
        );
      }).toList();
    }
    return [];
  }
}
