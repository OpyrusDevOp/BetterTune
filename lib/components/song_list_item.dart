import 'package:flutter/material.dart';
import '../datas/song.dart';
import '../services/storage_service.dart';

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
              child: FutureBuilder<String?>(
                future: StorageService.getServerUrl(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final serverUrl = snapshot.data!;
                    final imageTag = song.imageTags['Primary'];

                    if (imageTag != null) {
                      final imageUrl =
                          '$serverUrl/Items/${song.id}/Images/Primary?tag=$imageTag&quality=90';
                      return Image.network(
                        imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 28,
                            ),
                          );
                        },
                      );
                    }
                  }

                  return Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 28,
                    ),
                  );
                },
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
              _formatDuration(song.duration),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
}
