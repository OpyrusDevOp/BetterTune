import 'package:bettertune/data/mock_data.dart';

import 'package:bettertune/presentations/components/song_tile.dart';
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

    final queryLower = query.toLowerCase();

    // Filter Data
    final matchedSongs = MockData.songs
        .where((s) => s.name.toLowerCase().contains(queryLower))
        .toList();
    final matchedAlbums = MockData.albums
        .where((a) => a.title.toLowerCase().contains(queryLower))
        .toList();
    final matchedArtists = MockData.artists
        .where((a) => a.name.toLowerCase().contains(queryLower))
        .toList();

    if (matchedSongs.isEmpty &&
        matchedAlbums.isEmpty &&
        matchedArtists.isEmpty) {
      return Center(child: Text("No results found"));
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Artists Section
        if (matchedArtists.isNotEmpty) ...[
          _buildSectionHeader(context, "Artists"),
          ...matchedArtists.map(
            (artist) => ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(artist.name),
              onTap: () {
                // Navigate to Artist Details (Not implemented in search flow for simplicity, just close)
                close(context, null);
                // In real app, you'd perform navigation here or return a result
              },
            ),
          ),
          SizedBox(height: 16),
        ],

        // Albums Section
        if (matchedAlbums.isNotEmpty) ...[
          _buildSectionHeader(context, "Albums"),
          ...matchedAlbums.map(
            (album) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.album),
              ),
              title: Text(album.title),
              subtitle: Text(album.artist),
              onTap: () => close(context, null),
            ),
          ),
          SizedBox(height: 16),
        ],

        // Songs Section
        if (matchedSongs.isNotEmpty) ...[
          _buildSectionHeader(context, "Songs"),
          ...matchedSongs.map(
            (song) => SongTile(
              song: song,
              onPress: () => close(context, null), // Simulate play
              isSelect: false, // Search doesn't support selection mode yet
              selectionMode: false,
              onSelection: () {}, // No-op for search
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
