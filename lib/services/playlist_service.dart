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

  Future<void> createPlaylist(String name) async {
    // API: /Playlists?Name={Name}&UserId={UserId} (POST)
    final client = ApiClient();
    if (client.userId == null) return;

    await client.post('/Playlists?Name=$name&UserId=${client.userId}');
  }

  Future<void> addToPlaylist(String playlistId, List<String> itemIds) async {
    // API: /Playlists/{PlaylistId}/Items?Ids={Ids}&UserId={UserId} (POST)
    final client = ApiClient();
    if (client.userId == null) return;

    final idsParam = itemIds.join(',');
    await client.post(
      '/Playlists/$playlistId/Items?Ids=$idsParam&UserId=${client.userId}',
    );
  }
}
