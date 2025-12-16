import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/api_client.dart';

class SearchResults {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  SearchResults({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
  });
}

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  Future<SearchResults> search(String query) async {
    if (query.isEmpty) return SearchResults();

    final client = ApiClient();
    if (client.userId == null) return SearchResults();

    final Future<List<Song>> songsFuture = _searchSongs(client, query);
    final Future<List<Album>> albumsFuture = _searchAlbums(client, query);
    final Future<List<Artist>> artistsFuture = _searchArtists(client, query);

    final results = await Future.wait([
      songsFuture,
      albumsFuture,
      artistsFuture,
    ]);

    return SearchResults(
      songs: results[0] as List<Song>,
      albums: results[1] as List<Album>,
      artists: results[2] as List<Artist>,
    );
  }

  Future<List<Song>> _searchSongs(ApiClient client, String query) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&SearchTerm=$query&Limit=20&Fields=MediaStreams,ParentId',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Song>((item) {
        return Song(
          id: item['Id'],
          name: item['Name'],
          album: item['Album'] ?? 'Unknown Album',
          artist: item['AlbumArtist'] ?? 'Unknown Artist',
          isFavorite: item['UserData']?['IsFavorite'] ?? false,
        );
      }).toList();
    }
    return [];
  }

  Future<List<Album>> _searchAlbums(ApiClient client, String query) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicAlbum&SearchTerm=$query&Limit=10',
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

  Future<List<Artist>> _searchArtists(ApiClient client, String query) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicArtist&SearchTerm=$query&Limit=10',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Artist>((item) {
        return Artist(id: item['Id'], name: item['Name']);
      }).toList();
    }
    return [];
  }
}
