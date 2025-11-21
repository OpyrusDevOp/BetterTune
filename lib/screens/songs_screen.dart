import 'package:flutter/material.dart';

import '../components/song_list_item.dart';
import '../datas/song.dart';
import '../services/jellyfin_service.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  String _sortBy = 'title'; // title, artist, album, duration
  bool _isAscending = true;
  List<Song> _songs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final songs = await JellyfinService.getSongs();
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Song> get _sortedSongs {
    final sorted = List<Song>.from(_songs);

    switch (_sortBy) {
      case 'title':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'artist':
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'album':
        sorted.sort((a, b) => a.album.compareTo(b.album));
        break;
      case 'duration':
        sorted.sort((a, b) => a.runTimeTicks.compareTo(b.runTimeTicks));
        break;
    }

    if (!_isAscending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_songs.length} songs',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _fetchSongs,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Songs List
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _songs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading songs',
              style: TextStyle(color: Colors.red[300], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchSongs, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_songs.isEmpty) {
      return Center(
        child: Text(
          'No songs found',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      itemCount: _sortedSongs.length,
      itemBuilder: (context, index) {
        final song = _sortedSongs[index];
        return SongListItem(
          song: song,
          onTap: () {
            // Navigate to player screen
          },
        );
      },
    );
  }
}
