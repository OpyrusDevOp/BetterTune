import 'package:flutter/material.dart';

import '../components/playlist_card.dart';
import '../datas/playlist.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaylistsContent();
  }
}

class PlaylistsContent extends StatelessWidget {
  PlaylistsContent({super.key});

  final List<Playlist> playlists = [
    Playlist(
      name: 'Favorites',
      songCount: 45,
      description: 'Your liked songs',
      color: Colors.pink,
      icon: Icons.favorite,
    ),
    Playlist(
      name: 'Workout Mix',
      songCount: 32,
      description: 'High energy tracks',
      color: Colors.orange,
      icon: Icons.fitness_center,
    ),
    Playlist(
      name: 'Chill Vibes',
      songCount: 28,
      description: 'Relaxing music',
      color: Colors.blue,
      icon: Icons.spa,
    ),
    Playlist(
      name: 'Road Trip',
      songCount: 56,
      description: 'Perfect for long drives',
      color: Colors.green,
      icon: Icons.directions_car,
    ),
    Playlist(
      name: 'Focus',
      songCount: 41,
      description: 'Concentration music',
      color: Colors.purple,
      icon: Icons.headphones,
    ),
    Playlist(
      name: 'Party Hits',
      songCount: 38,
      description: 'Dance all night',
      color: Colors.red,
      icon: Icons.celebration,
    ),
    Playlist(
      name: 'Acoustic',
      songCount: 24,
      description: 'Unplugged favorites',
      color: Colors.brown,
      icon: Icons.music_note,
    ),
    Playlist(
      name: 'Throwback',
      songCount: 67,
      description: 'Classic hits',
      color: Colors.deepOrange,
      icon: Icons.history,
    ),
    Playlist(
      name: 'Sleep',
      songCount: 19,
      description: 'Peaceful sounds',
      color: Colors.indigo,
      icon: Icons.nightlight,
    ),
    Playlist(
      name: 'Discover Weekly',
      songCount: 30,
      description: 'New recommendations',
      color: Colors.teal,
      icon: Icons.explore,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Playlists',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Playlist Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${playlists.length} playlists',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Create Playlist Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showCreatePlaylistDialog(context);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Playlist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Playlists Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return PlaylistCard(playlist: playlist);
            },
          ),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Create Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle playlist creation
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playlist "${nameController.text}" created!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
