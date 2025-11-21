import 'dart:convert';
import '../datas/song.dart';
import '../datas/artist.dart';
import '../datas/album.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class JellyfinService {
  static Future<List<Song>> getSongs({String? userId, String? parentId}) async {
    final token = await StorageService.getToken();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || serverUrl == null) {
      throw Exception('Not authenticated');
    }

    // Ensure AuthService has the server URL set, as it might be needed for other calls
    AuthService.setServerUrl = serverUrl;

    // Construct the query parameters
    final queryParams = {
      'IncludeItemTypes': 'Audio',
      'Recursive': 'true',
      'Fields': 'MediaSources,Chapters,UserData',
      'SortBy': 'SortName',
      'SortOrder': 'Ascending',
    };

    if (userId != null) {
      queryParams['UserId'] = userId;
    } else {
      final storedUserId = await StorageService.getUserId();
      if (storedUserId != null) {
        queryParams['UserId'] = storedUserId;
      }
    }

    if (parentId != null) {
      queryParams['ParentId'] = parentId;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/Items?$queryString';

    try {
      final response = await AuthService.authenticatedRequest(endpoint, token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['Items'] as List;
        return items.map((item) => Song.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching songs: $e');
      rethrow;
    }
  }

  static Future<List<Artist>> getArtists({String? userId}) async {
    final token = await StorageService.getToken();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || serverUrl == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = {
      'IncludeItemTypes': 'MusicArtist',
      'Recursive': 'true',
      'Fields': 'UserData,Tags',
      'SortBy': 'SortName',
      'SortOrder': 'Ascending',
    };

    if (userId != null) {
      queryParams['UserId'] = userId;
    } else {
      final storedUserId = await StorageService.getUserId();
      if (storedUserId != null) {
        queryParams['UserId'] = storedUserId;
      }
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/Items?$queryString';

    try {
      final response = await AuthService.authenticatedRequest(endpoint, token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['Items'] as List;
        return items.map((item) => Artist.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load artists: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching artists: $e');
      rethrow;
    }
  }

  static Future<List<Album>> getAlbums({
    String? userId,
    String? artistId,
  }) async {
    final token = await StorageService.getToken();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || serverUrl == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = {
      'IncludeItemTypes': 'MusicAlbum',
      'Recursive': 'true',
      'Fields': 'UserData,Tags,AlbumArtist,ProductionYear',
      'SortBy': 'SortName',
      'SortOrder': 'Ascending',
    };

    if (userId != null) {
      queryParams['UserId'] = userId;
    } else {
      final storedUserId = await StorageService.getUserId();
      if (storedUserId != null) {
        queryParams['UserId'] = storedUserId;
      }
    }

    if (artistId != null) {
      queryParams['ArtistIds'] = artistId;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/Items?$queryString';

    try {
      final response = await AuthService.authenticatedRequest(endpoint, token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['Items'] as List;
        return items.map((item) => Album.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching albums: $e');
      rethrow;
    }
  }
}
