import 'package:flutter/material.dart';
import '../datas/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongListItem({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: song.albumColor,
                child: const Icon(Icons.album, color: Colors.white54, size: 28),
              ),
            ),
            const SizedBox(width: 12),

            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} • ${song.album}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              song.duration,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),

            // More Options
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.6)),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }
}
