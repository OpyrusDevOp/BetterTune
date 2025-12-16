import 'package:flutter/material.dart';

class GlobalActionButtons extends StatelessWidget {
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;
  final VoidCallback onAddToPlaylist;

  const GlobalActionButtons({
    super.key,
    required this.onPlayAll,
    required this.onShuffle,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Play All Button (Prominent)
          Expanded(
            child: FilledButton.icon(
              onPressed: onPlayAll,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                "Play All",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Shuffle Button (Secondary)
          IconButton.filledTonal(
            onPressed: onShuffle,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: "Shuffle",
          ),
          const SizedBox(width: 12),
          // Add to Playlist Button (Secondary)
          IconButton.filledTonal(
            onPressed: onAddToPlaylist,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: "Add to Playlist",
          ),
        ],
      ),
    );
  }
}
