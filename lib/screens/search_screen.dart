import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/jellyfin_service.dart';
import '../services/player_service.dart';
import '../datas/song.dart';
import '../datas/artist.dart';
import '../datas/album.dart';
import '../components/song_list_item.dart';
import '../components/artist_card.dart';
import '../screens/albums_screen.dart'; // For AlbumCard
import '../components/song_details_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await JellyfinService.search(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _performSearch('');
            },
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        if (item is Song) {
          return SongListItem(
            song: item,
            onTap: () {
              context.read<PlayerService>().playSong(item);
            },
            onMorePressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => SongDetailsBottomSheet(song: item),
              );
            },
          );
        } else if (item is Artist) {
          // Wrap in a container to constrain height or use a list tile variant
          // ArtistCard is designed for Grid, might be too big for List.
          // Let's use a simple ListTile for now or wrap ArtistCard.
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(height: 200, child: ArtistCard(artist: item)),
          );
        } else if (item is Album) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(height: 250, child: AlbumCard(album: item)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
