import 'package:flutter/material.dart';

import '../datas/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to artist detail page
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist Image (circular)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: artist.color,
              ),
              child: const Center(
                child: Icon(Icons.person, size: 60, color: Colors.white54),
              ),
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
          ),
          const SizedBox(height: 4),

          // Album Count
          Text(
            '${artist.albumCount} album${artist.albumCount != 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
