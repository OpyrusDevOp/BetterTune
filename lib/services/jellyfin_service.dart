import 'dart:convert';
import '../datas/song.dart';
import '../datas/artist.dart';
import '../datas/album.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class JellyfinService {
  static Future<List<Song>> getSongs({
    String? userId,
    String? parentId,
    String? artistId,
  }) async {
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

  static Future<bool> markFavorite(String itemId, bool isFavorite) async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || userId == null || serverUrl == null) {
      throw Exception('Not authenticated');
    }

    final endpoint = '/Users/$userId/FavoriteItems/$itemId';

    try {
      final response = isFavorite
          ? await AuthService.authenticatedRequest(
              endpoint,
              token,
              method: 'POST',
            )
          : await AuthService.authenticatedRequest(
              endpoint,
              token,
              method: 'DELETE',
            );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to toggle favorite: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  static Future<List<dynamic>> search(String query) async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || userId == null || serverUrl == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = {
      'SearchTerm': query,
      'IncludeItemTypes': 'Audio,MusicArtist,MusicAlbum',
      'Recursive': 'true',
      'Fields':
          'UserData,Tags,AlbumArtist,ProductionYear,MediaSources,Chapters',
      'UserId': userId,
      'Limit': '20',
    };

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/Items?$queryString';

    try {
      final response = await AuthService.authenticatedRequest(endpoint, token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['Items'] as List;

        return items
            .map((item) {
              final type = item['Type'];
              if (type == 'Audio') {
                return Song.fromJson(item);
              } else if (type == 'MusicArtist') {
                return Artist.fromJson(item);
              } else if (type == 'MusicAlbum') {
                return Album.fromJson(item);
              }
              return null;
            })
            .where((element) => element != null)
            .toList();
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching: $e');
      rethrow;
    }
  }

  static Future<String?> getLyrics(String itemId) async {
    final token = await StorageService.getToken();
    final serverUrl = await StorageService.getServerUrl();

    if (token == null || serverUrl == null) {
      return null;
    }

    // Try to fetch from Lyrics plugin endpoint (common convention)
    // Or check for lyrics stream.
    // For now, let's try a direct lyrics endpoint if available, or just return null
    // as we don't have a guaranteed way without inspecting specific server setup.
    // However, we can try to fetch item details and look for lyric streams.

    final endpoint = '/Items/$itemId?Fields=MediaSources';
    try {
      final response = await AuthService.authenticatedRequest(endpoint, token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mediaSources = data['MediaSources'] as List?;
        if (mediaSources != null && mediaSources.isNotEmpty) {
          final mediaSource = mediaSources.first;
          final mediaStreams = mediaSource['MediaStreams'] as List?;
          if (mediaStreams != null) {
            for (final stream in mediaStreams) {
              if (stream['Type'] == 'Lyric') {
                // Found a lyric stream
                final index = stream['Index'];
                final mediaSourceId = mediaSource['Id'];
                // Construct subtitle URL
                // /Videos/{Id}/{MediaSourceId}/Subtitles/{Index}/Stream.{Format}
                // For audio, it's often the same structure or /Audio/...
                // Let's try the standard subtitle download URL
                final format = stream['Codec'] ?? 'srt';
                final lyricUrl =
                    '$serverUrl/Videos/$itemId/$mediaSourceId/Subtitles/$index/Stream.$format';

                // Fetch the content
                final lyricResponse = await AuthService.authenticatedRequest(
                  lyricUrl.replaceFirst(serverUrl, ''),
                  token,
                );
                if (lyricResponse.statusCode == 200) {
                  return lyricResponse.body;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
    }

    return null;
  }
}
