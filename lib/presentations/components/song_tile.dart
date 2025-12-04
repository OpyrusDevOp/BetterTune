import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) => InkWell(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: const TextStyle(
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
                    color: Colors.black.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // More Options
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black.withValues(alpha: 0.6),
            ),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}
