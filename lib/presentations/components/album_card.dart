import 'package:flutter/material.dart';

import '../../models/album.dart';

class AlbumCard extends StatelessWidget {
  final bool selectionMode;
  final bool isSelect;
  final VoidCallback onSelection;
  final VoidCallback onPress;
  final Album album;

  const AlbumCard({
    super.key,
    required this.album,
    required this.selectionMode,
    required this.isSelect,
    required this.onSelection,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4.0), // Padding between grid items
      child: InkWell(
        onTap: selectionMode ? onSelection : onPress,
        onLongPress: selectionMode ? null : onSelection,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isSelect
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: [
              if (!isSelect)
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Album Cover (Expanded)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.primary.withAlpha(100),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.album_rounded,
                          size: 64,
                          color: colorScheme.onPrimaryContainer.withAlpha(150),
                        ),
                      ),
                    ),
                  ),

                  // Info Section
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            album.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            album.artist,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha(180),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Selection Indicator or Menu
              Positioned(
                top: 8,
                right: 8,
                child: selectionMode
                    ? Checkbox(
                        value: isSelect,
                        onChanged: (v) => onSelection(),
                        activeColor: colorScheme.primary,
                        shape: const CircleBorder(),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showOptions(context),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.more_vert,
                              color: colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
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
