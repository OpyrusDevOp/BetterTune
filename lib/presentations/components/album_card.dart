import 'package:flutter/material.dart';

import '../../models/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onLongPress: () {
        _showOptions(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Cover
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 160,
                  height: 160,
                  color: Colors.pink.shade200,
                  child: const Center(
                    child: Icon(Icons.album, size: 60, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Album Title
          Center(
            child: Text(
              album.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),

          // Artist Name
          Center(
            child: Text(
              album.artist,
              style: TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Play'),
                onTap: () async {},
              ),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shuffle'),
                onTap: () async {},
              ),
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text('Add to Queue'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
