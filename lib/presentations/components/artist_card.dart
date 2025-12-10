import 'package:flutter/material.dart';

import '../../models/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final bool selectionMode;
  final bool isSelect;
  final VoidCallback onSelection;
  final VoidCallback onPress;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.selectionMode,
    required this.isSelect,
    required this.onSelection,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selectionMode ? onSelection : onPress,
      onLongPress: selectionMode ? null : onSelection,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: CircleAvatar(
                    radius: 80,
                    child: Icon(Icons.person, size: 40),
                  ),
                ),
                Text(artist.name, style: TextTheme.of(context).titleLarge),
              ],
            ),
          ),
          if (selectionMode)
            Positioned(
              top: 0,
              right: 0,
              child: Checkbox(value: isSelect, onChanged: (v) => onSelection()),
            ),
          if (!selectionMode)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptions(context),
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
            ],
          ),
        );
      },
    );
  }
}
