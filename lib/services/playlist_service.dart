import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  Future<List<Playlist>> getPlaylists() async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Playlist&SortBy=SortName&SortOrder=Ascending',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Playlist>((item) {
        return Playlist(
          id: item['Id'],
          name: item['Name'],
          songs: [], // Playlists usually don't return songs in the list view
        );
      }).toList();
    }
    return [];
  }

  Future<String?> createPlaylist(String name) async {
    // API: /Playlists?Name={Name}&UserId={UserId} (POST)
    final client = ApiClient();
    if (client.userId == null) return null;

    // Use query parameters to handle special characters in name
    final queryParams = {'Name': name, 'UserId': client.userId};

    // Construct URI safely
    // Note: We need to manually construct string for ApiClient since it expects endpoint string
    // But better to let ApiClient handle it or construct fully encoded string here.
    // ApiClient uses Uri.parse('$baseUrl$endpoint'), so we need to pass a string that is safe.

    // The safest way is to use Uri to encode query params
    final uri = Uri(path: '/Playlists', queryParameters: queryParams);

    final result = await client.post(uri.toString());
    if (result != null && result['Id'] != null) {
      return result['Id'];
    }
    return null;
  }

  Future<void> addToPlaylist(String playlistId, List<String> itemIds) async {
    // API: /Playlists/{PlaylistId}/Items?Ids={Ids}&UserId={UserId} (POST)
    final client = ApiClient();
    if (client.userId == null) return;

    final queryParams = {'Ids': itemIds.join(','), 'UserId': client.userId};

    final uri = Uri(
      path: '/Playlists/$playlistId/Items',
      queryParameters: queryParams,
    );

    await client.post(uri.toString());
  }

  Future<void> removeItemsFromPlaylist(
    String playlistId,
    List<String> itemIds,
  ) async {
    // API: DELETE /Playlists/{Id}/Items?Ids={Ids}&UserId={UserId}
    // Alternatively: /Playlists/{Id}/Items?EntryIds={EntryIds} if we had them.
    // Using Ids is safer for "remove this song" intent.
    final client = ApiClient();
    if (client.userId == null) return;

    final queryParams = {'Ids': itemIds.join(','), 'UserId': client.userId};

    final uri = Uri(
      path: '/Playlists/$playlistId/Items',
      queryParameters: queryParams,
    );

    await client.delete(uri.toString());
  }

  Future<void> deletePlaylist(String playlistId) async {
    // API: DELETE /Items/{Id}
    final client = ApiClient();
    if (client.userId == null) return;

    await client.delete('/Items/$playlistId');
  }

  Future<List<Song>> getPlaylistItems(String playlistId) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?ParentId=$playlistId&Recursive=true&IncludeItemTypes=Audio&Fields=MediaStreams,DateCreated&SortBy=SortName&SortOrder=Ascending',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Song>((item) {
        return Song(
          id: item['Id'],
          name: item['Name'],
          album: item['Album'] ?? 'Unknown Album',
          artist:
              item['AlbumArtist'] ??
              item['Artists'].firstWhere(
                (_) => true,
                orElse: () => 'Unknown Artist',
              ),
          isFavorite: item['UserData']?['IsFavorite'] ?? false,
        );
      }).toList();
    }
    return [];
  }
}
