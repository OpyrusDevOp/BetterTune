import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datas/song.dart';
import '../datas/artist.dart';
import '../datas/album.dart';
import '../services/player_service.dart';
import '../screens/artist_detail_screen.dart';
import '../screens/album_detail_screen.dart';

class SongDetailsBottomSheet extends StatelessWidget {
  final Song song;

  const SongDetailsBottomSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Song Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Divider(color: Colors.white10),

            // Actions
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text(
                'Add to Queue',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                final player = Provider.of<PlayerService>(
                  context,
                  listen: false,
                );
                player.addToQueue(song);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to queue')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play, color: Colors.white),
              title: const Text(
                'Play Next',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                final player = Provider.of<PlayerService>(
                  context,
                  listen: false,
                );
                player.playNext(song);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Playing next')));
              },
            ),

            const Divider(color: Colors.white10),

            if (song.artistId != null)
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Go to Artist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // We need to create a dummy Artist object with just ID and name to navigate
                  // Ideally we should fetch the full artist, but for now ID and name might be enough
                  // if the detail screen fetches data by ID.
                  // Our ArtistDetailScreen takes an Artist object.
                  // Let's construct a minimal one.
                  final artist = Artist(
                    id: song.artistId!,
                    name: song.artist,
                    serverId: song.serverId,
                    imageTags:
                        {}, // We don't have image tags here, detail screen might fail to load image if it relies on this
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistDetailScreen(artist: artist),
                    ),
                  );
                },
              ),

            if (song.albumId.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.album, color: Colors.white),
                title: const Text(
                  'Go to Album',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final album = Album(
                    id: song.albumId,
                    title: song.album,
                    artist: song.artist,
                    artistId: song.artistId ?? '',
                    serverId: song.serverId,
                    year: 0, // Unknown
                    imageTags: {},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumDetailScreen(album: album),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
