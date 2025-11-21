import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datas/artist.dart';
import '../datas/album.dart';
import '../services/jellyfin_service.dart';
import '../services/storage_service.dart';
import '../services/player_service.dart';
import '../screens/album_detail_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  List<Album> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final albums = await JellyfinService.getAlbums(
        artistId: widget.artist.id,
      );
      setState(() {
        _albums = albums;
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
              title: Text(widget.artist.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<String?>(
                    future: StorageService.getServerUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final serverUrl = snapshot.data!;
                        final imageTag = widget.artist.imageTags['Primary'];

                        if (imageTag != null) {
                          final imageUrl =
                              '$serverUrl/Items/${widget.artist.id}/Images/Primary?tag=$imageTag&quality=90';
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
                      onPressed: () => _playArtistSongs(shuffle: false),
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
                      onPressed: () => _playArtistSongs(shuffle: true),
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
                      onPressed: _addArtistToQueue,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Albums',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          else if (_albums.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No albums found',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final album = _albums[index];
                  return _buildAlbumCard(album);
                }, childCount: _albums.length),
              ),
            ),
          // Add some bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(Album album) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(album: album),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<String?>(
                future: StorageService.getServerUrl(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final serverUrl = snapshot.data!;
                    final imageTag = album.imageTags['Primary'];

                    if (imageTag != null) {
                      final imageUrl =
                          '$serverUrl/Items/${album.id}/Images/Primary?tag=$imageTag&quality=90';
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.album,
                                size: 50,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.album, size: 50, color: Colors.white54),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${album.year}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playArtistSongs({required bool shuffle}) async {
    try {
      final songs = await JellyfinService.getSongs(artistId: widget.artist.id);
      if (mounted) {
        final player = Provider.of<PlayerService>(context, listen: false);
        await player.playSongs(songs, shuffle: shuffle);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing artist: $e')));
      }
    }
  }

  Future<void> _addArtistToQueue() async {
    try {
      final songs = await JellyfinService.getSongs(artistId: widget.artist.id);
      if (mounted) {
        final player = Provider.of<PlayerService>(context, listen: false);
        await player.addSongsToQueue(songs);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to queue')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding to queue: $e')));
      }
    }
  }
}
