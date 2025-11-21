import 'package:flutter/material.dart';

import '../components/song_list_item.dart';
import '../components/song_details_bottom_sheet.dart';
import '../datas/song.dart';
import '../services/jellyfin_service.dart';

import 'package:provider/provider.dart';
import '../services/player_service.dart';

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

  // Selection state
  final Set<Song> _selectedSongs = {};
  bool _isSelectionMode = false;

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

  void _toggleSelection(Song song) {
    setState(() {
      if (_selectedSongs.contains(song)) {
        _selectedSongs.remove(song);
        if (_selectedSongs.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedSongs.add(song);
        _isSelectionMode = true;
      }
    });
  }

  void _addToQueue() {
    final playerService = context.read<PlayerService>();
    for (final song in _selectedSongs) {
      playerService.addToQueue(song);
    }
    _clearSelection();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to queue')));
  }

  void _playNext() {
    final playerService = context.read<PlayerService>();
    // Add in reverse order so they end up in correct order after current song
    final sortedSelection = _selectedSongs.toList();
    // Ideally we should sort them based on current list order if we want to maintain that
    // But for now just adding them.

    for (final song in sortedSelection.reversed) {
      playerService.addToQueueNext(song);
    }
    _clearSelection();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Playing next')));
  }

  void _clearSelection() {
    setState(() {
      _selectedSongs.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isSelectionMode)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.blue.withOpacity(0.2),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _clearSelection,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedSongs.length} selected',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.queue_music, color: Colors.white),
                  onPressed: _addToQueue,
                  tooltip: 'Add to Queue',
                ),
                IconButton(
                  icon: const Icon(Icons.playlist_play, color: Colors.white),
                  onPressed: _playNext,
                  tooltip: 'Play Next',
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_songs.length} songs',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
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
        final isSelected = _selectedSongs.contains(song);

        return SongListItem(
          song: song,
          isSelected: isSelected,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(song);
            } else {
              // Play song
              context.read<PlayerService>().playSong(
                song,
                newQueue: _sortedSongs,
              );
            }
          },
          onLongPress: () {
            _toggleSelection(song);
          },
          onMorePressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => SongDetailsBottomSheet(song: song),
            );
          },
        );
      },
    );
  }
}
