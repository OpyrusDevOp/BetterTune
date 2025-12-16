import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';

class SongsService {
  static final SongsService _instance = SongsService._internal();
  factory SongsService() => _instance;
  SongsService._internal();

  /// Fetch all Songs (Audio items)
  Future<List<Song>> getSongs({int limit = 100, int startIndex = 0}) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&Fields=ParentId,DateCreated,MediaStreams&Limit=$limit&StartIndex=$startIndex&SortBy=SortName&SortOrder=Ascending',
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

  /// Get direct streaming URL for a song
  String getStreamUrl(String songId) {
    // Determine Container (mp3, aac, etc) or use universal endpoint
    // Universal: /Audio/{Id}/universal?UserId={UserId}&DeviceId={DeviceId}&MaxStreamingBitrate=140000000...
    final client = ApiClient();
    if (client.baseUrl == null) return "";

    return '${client.baseUrl}/Audio/$songId/universal?UserId=${client.userId}&DeviceId=${client.deviceId}&Container=mp3,aac,m4a,flac,webma,webm,wav&TranscodingContainer=ts&TranscodingProtocol=hls&AudioCodec=aac';
  }

  /// Fetch Albums
  Future<List<Album>> getAlbums({int limit = 50}) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicAlbum&SortBy=SortName&SortOrder=Ascending&Limit=$limit',
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

  /// Get songs for a specific Album
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?ParentId=$albumId&Recursive=true&IncludeItemTypes=Audio&Fields=MediaStreams&SortBy=SortName&SortOrder=Ascending',
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

  /// Fetch Artists
  Future<List<Artist>> getArtists({int limit = 50}) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicArtist&SortBy=SortName&SortOrder=Ascending&Limit=$limit',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Artist>((item) {
        return Artist(id: item['Id'], name: item['Name']);
      }).toList();
    }
    return [];
  }

  /// Get albums for a specific Artist
  Future<List<Album>> getAlbumsByArtist(String artistName) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    // Jellyfin often filters by Artist Name for albums
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicAlbum&SortBy=SortName&SortOrder=Ascending&Artist=$artistName',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Album>((item) {
        return Album(
          id: item['Id'],
          title: item['Name'],
          artist: item['AlbumArtist'] ?? artistName,
          year: item['ProductionYear'] ?? 0,
        );
      }).toList();
    }
    return [];
  }

  /// Get songs for a specific Artist
  Future<List<Song>> getSongsByArtist(
    String artistId,
    String artistName,
  ) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&Fields=MediaStreams&SortBy=SortName&SortOrder=Ascending&ArtistIds=$artistId',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Song>((item) {
        return Song(
          id: item['Id'],
          name: item['Name'],
          album: item['Album'] ?? 'Unknown Album',
          artist: item['AlbumArtist'] ?? artistName,
          isFavorite: item['UserData']?['IsFavorite'] ?? false,
        );
      }).toList();
    }
    return [];
  }

  /// Get favorite songs
  Future<List<Song>> getFavoriteSongs({int limit = 100}) async {
    final client = ApiClient();
    if (client.userId == null) return [];

    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&Fields=MediaStreams,ParentId,DateCreated&Filters=IsFavorite&SortBy=SortName&SortOrder=Ascending&Limit=$limit',
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
          isFavorite: true,
        );
      }).toList();
    }
    return [];
  }
}
