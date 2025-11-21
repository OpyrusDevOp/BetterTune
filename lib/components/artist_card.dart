import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/jellyfin_service.dart';
import '../services/player_service.dart';
import '../datas/artist.dart';
import '../services/storage_service.dart';
import '../screens/artist_detail_screen.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailScreen(artist: artist),
          ),
        );
      },
      onLongPress: () {
        _showOptions(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Artist Image (circular)
          Expanded(
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: FutureBuilder<String?>(
                      future: StorageService.getServerUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final serverUrl = snapshot.data!;
                          final imageTag = artist.imageTags['Primary'];

                          if (imageTag != null) {
                            final imageUrl =
                                '$serverUrl/Items/${artist.id}/Images/Primary?tag=$imageTag&quality=90';
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            );
                          }
                        }
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _showOptions(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Artist Name
          Text(
            artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text(
                  'Play',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _playArtistSongs(context, shuffle: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shuffle, color: Colors.white),
                title: const Text(
                  'Shuffle',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _playArtistSongs(context, shuffle: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _addArtistToQueue(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playArtistSongs(
    BuildContext context, {
    required bool shuffle,
  }) async {
    try {
      final songs = await JellyfinService.getSongs(artistId: artist.id);
      if (context.mounted) {
        final player = Provider.of<PlayerService>(context, listen: false);
        await player.playSongs(songs, shuffle: shuffle);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing artist: $e')));
      }
    }
  }

  Future<void> _addArtistToQueue(BuildContext context) async {
    try {
      final songs = await JellyfinService.getSongs(artistId: artist.id);
      if (context.mounted) {
        final player = Provider.of<PlayerService>(context, listen: false);
        await player.addSongsToQueue(songs);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to queue')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding to queue: $e')));
      }
    }
  }
}
