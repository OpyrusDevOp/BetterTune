import 'package:flutter/material.dart';

class SelectionBottomBar extends StatelessWidget {
  final int selectionCount;
  final VoidCallback onPlay;
  final VoidCallback onAddToPlaylist;
  final VoidCallback? onDelete; // Optional, mainly for playlists

  const SelectionBottomBar({
    super.key,
    required this.selectionCount,
    required this.onPlay,
    required this.onAddToPlaylist,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (selectionCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Count Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$selectionCount Selected",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Actions
          IconButton(
            onPressed: onPlay,
            tooltip: "Play Selection",
            icon: Icon(Icons.play_arrow_rounded, color: colorScheme.primary),
          ),
          IconButton(
            onPressed: onAddToPlaylist,
            tooltip: "Add to Playlist",
            icon: Icon(Icons.playlist_add_rounded, color: colorScheme.primary),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              tooltip: "Remove/Delete",
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}
