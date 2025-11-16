import 'package:flutter/material.dart';

import '../datas/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to album detail page
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Cover
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: album.color,
                child: const Center(
                  child: Icon(Icons.album, size: 60, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Album Title
          Text(
            album.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Artist Name
          Text(
            album.artist,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Year and Track Count
          Text(
            '${album.year} • ${album.trackCount} tracks',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AlbumsScreen extends StatelessWidget {
  AlbumsScreen({super.key});

  final List<Album> albums = [
    Album(
      title: 'Evolve',
      artist: 'Imagine Dragons',
      year: 2017,
      trackCount: 11,
      color: Colors.orange,
    ),
    Album(
      title: 'A Moment Apart',
      artist: 'ODESZA',
      year: 2017,
      trackCount: 16,
      color: Colors.blue,
    ),
    Album(
      title: 'Night Visions',
      artist: 'Imagine Dragons',
      year: 2012,
      trackCount: 13,
      color: Colors.purple,
    ),
    Album(
      title: 'Down in Heaven',
      artist: 'Twin Peaks',
      year: 2016,
      trackCount: 12,
      color: Colors.red,
    ),
    Album(
      title: 'Wilderness',
      artist: 'HVÖNNÅ',
      year: 2020,
      trackCount: 10,
      color: Colors.teal,
    ),
    Album(
      title: 'AM',
      artist: 'Arctic Monkeys',
      year: 2013,
      trackCount: 12,
      color: Colors.indigo,
    ),
    Album(
      title: 'After Hours',
      artist: 'The Weeknd',
      year: 2020,
      trackCount: 14,
      color: Colors.pink,
    ),
    Album(
      title: 'Currents',
      artist: 'Tame Impala',
      year: 2015,
      trackCount: 13,
      color: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Albums Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                '${albums.length} albums',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Albums Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return AlbumCard(album: album);
            },
          ),
        ),
      ],
    );
  }
}
