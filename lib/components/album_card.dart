import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final Color color;
  final void Function()? onTap;

  const AlbumCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 160,
                  height: 160,
                  color: color,
                  child: const Center(
                    child: Icon(Icons.album, size: 60, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Artist
              if (artist.isNotEmpty)
                Text(
                  artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
