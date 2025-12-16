import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/database_service.dart';

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

    final db = DatabaseService();

    // Perform parallel searches
    final songsFuture = db.searchSongs(query);
    final albumsFuture = db.searchAlbums(query);
    final artistsFuture = db.searchArtists(query);

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
}
