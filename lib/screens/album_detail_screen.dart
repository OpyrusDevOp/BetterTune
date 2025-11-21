import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datas/album.dart';
import '../datas/song.dart';
import '../services/jellyfin_service.dart';
import '../services/storage_service.dart';
import '../services/player_service.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
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
      final songs = await JellyfinService.getSongs(parentId: widget.album.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A2332),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.album.title),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<String?>(
                    future: StorageService.getServerUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final serverUrl = snapshot.data!;
                        final imageTag = widget.album.imageTags['Primary'];

                        if (imageTag != null) {
                          final imageUrl =
                              '$serverUrl/Items/${widget.album.id}/Images/Primary?tag=$imageTag&quality=90';
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey[800]);
                            },
                          );
                        }
                      }
                      return Container(color: Colors.grey[800]);
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF1A2332)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _playAlbum(shuffle: false),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _playAlbum(shuffle: true),
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addAlbumToQueue,
                      icon: const Icon(Icons.queue_music),
                      label: const Text('Queue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (_songs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No songs found',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _songs[index];
                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  title: Text(
                    song.name,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDuration(song.runTimeTicks),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    // Play the album starting from this song
                    final player = Provider.of<PlayerService>(
                      context,
                      listen: false,
                    );
                    player.playSong(song, newQueue: _songs);
                  },
                );
              }, childCount: _songs.length),
            ),
          // Add some bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _formatDuration(int? ticks) {
    if (ticks == null) return '';
    final duration = Duration(microseconds: ticks ~/ 10);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Future<void> _playAlbum({required bool shuffle}) async {
    if (_songs.isEmpty) return;

    try {
      final player = Provider.of<PlayerService>(context, listen: false);
      await player.playSongs(_songs, shuffle: shuffle);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing album: $e')));
      }
    }
  }

  Future<void> _addAlbumToQueue() async {
    if (_songs.isEmpty) return;

    try {
      final player = Provider.of<PlayerService>(context, listen: false);
      await player.addSongsToQueue(_songs);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to queue')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding to queue: $e')));
      }
    }
  }
}
