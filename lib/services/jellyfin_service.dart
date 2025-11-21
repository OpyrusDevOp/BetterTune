import 'dart:convert';
import '../datas/song.dart';
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
}
