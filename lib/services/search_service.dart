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

  Future<SearchResults> search(
    String query, {
    int limit = 20,
    int startIndex = 0,
    bool includeSongs = true,
    bool includeAlbums = true,
    bool includeArtists = true,
  }) async {
    if (query.isEmpty) return SearchResults();

    final client = ApiClient();
    if (client.userId == null) return SearchResults();

    final futures = <Future<dynamic>>[];

    // We can conditionally add futures based on what we want to fetch
    // Use indices to map results back, or just use separate calls if simpler.
    // For simplicity, let's keep running parallel but respect flags.

    // Actually, to make it clean, let's just await conditionally.

    List<Song> songs = [];
    List<Album> albums = [];
    List<Artist> artists = [];

    if (includeSongs) {
      futures.add(
        _searchSongs(
          client,
          query,
          limit,
          startIndex,
        ).then((val) => songs = val),
      );
    }
    if (includeAlbums) {
      // Albums usually don't need deep pagination in mixed view, but let's support it
      // If we are paging, we might only want to page songs after the first load.
      // But let's allow paging everything if needed.
      futures.add(
        _searchAlbums(
          client,
          query,
          limit,
          startIndex,
        ).then((val) => albums = val),
      );
    }
    if (includeArtists) {
      futures.add(
        _searchArtists(
          client,
          query,
          limit,
          startIndex,
        ).then((val) => artists = val),
      );
    }

    await Future.wait(futures);

    return SearchResults(songs: songs, albums: albums, artists: artists);
  }

  Future<List<Song>> _searchSongs(
    ApiClient client,
    String query,
    int limit,
    int startIndex,
  ) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=Audio&SearchTerm=$query&Limit=$limit&StartIndex=$startIndex&Fields=MediaStreams,ParentId',
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

  Future<List<Album>> _searchAlbums(
    ApiClient client,
    String query,
    int limit,
    int startIndex,
  ) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicAlbum&SearchTerm=$query&Limit=$limit&StartIndex=$startIndex',
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

  Future<List<Artist>> _searchArtists(
    ApiClient client,
    String query,
    int limit,
    int startIndex,
  ) async {
    final result = await client.get(
      '/Users/${client.userId}/Items?Recursive=true&IncludeItemTypes=MusicArtist&SearchTerm=$query&Limit=$limit&StartIndex=$startIndex',
    );

    if (result != null && result['Items'] != null) {
      return (result['Items'] as List).map<Artist>((item) {
        return Artist(id: item['Id'], name: item['Name']);
      }).toList();
    }
    return [];
  }
}
