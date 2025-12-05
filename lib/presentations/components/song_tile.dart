import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool selectionMode;
  final bool isSelect;
  final VoidCallback onSelection;
  final VoidCallback onPress;
  const SongTile({
    super.key,
    required this.song,
    required this.onPress,
    required this.onSelection,
    required this.isSelect,
    this.selectionMode = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: selectionMode ? onSelection : onPress,
    onLongPress: selectionMode ? null : onSelection,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (selectionMode)
            Checkbox(value: isSelect, tristate: true, onChanged: null),
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
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // More Options
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    ),
  );

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
