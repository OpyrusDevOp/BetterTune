import 'package:bettertune/services/search_service.dart';
import 'package:bettertune/presentations/delegates/search_results_view.dart';
import 'package:flutter/material.dart';

class GlobalSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Search for songs, albums, or artists",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return FutureBuilder<SearchResults>(
      future: SearchService().search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final results = snapshot.data;
        if (results == null ||
            (results.songs.isEmpty &&
                results.albums.isEmpty &&
                results.artists.isEmpty)) {
          return Center(child: Text("No results found"));
        }

        return SearchResultsView(
          songs: results.songs,
          albums: results.albums,
          artists: results.artists,
          onClose: (ctx) => close(ctx, null),
        );
      },
    );
  }
}
