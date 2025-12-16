import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/services/api_client.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: selectionMode ? onSelection : onPress,
        onLongPress: selectionMode ? null : onSelection,
        borderRadius: BorderRadius.circular(100), // Circular touch area roughly
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular Avatar Container
                Container(
                  width: 120, // Explicit size for consistency
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardTheme.color,
                    border: isSelect
                        ? Border.all(color: colorScheme.primary, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.secondaryContainer,
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      ApiClient().getImageUrl(
                        artist.id,
                        width: 200,
                        height: 200,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Selection / Menu Overlay
                if (selectionMode)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Checkbox(
                        value: isSelect,
                        onChanged: (v) => onSelection(),
                        shape: const CircleBorder(),
                        activeColor: colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 0,
                    bottom: 10,
                    child: Material(
                      color: theme.colorScheme.surfaceContainer,
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showOptions(context),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                artist.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
                onTap: () async {
                  Navigator.pop(context);
                  final songs = await SongsService().getSongsByArtist(
                    artist.id,
                    artist.name,
                  );
                  AudioPlayerService().setQueue(songs);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/player');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shuffle'),
                onTap: () async {
                  Navigator.pop(context);
                  final songs = await SongsService().getSongsByArtist(
                    artist.id,
                    artist.name,
                  );
                  songs.shuffle();
                  AudioPlayerService().setQueue(songs);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/player');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text('Add to Queue'),
                onTap: () async {
                  Navigator.pop(context);
                  final songs = await SongsService().getSongsByArtist(
                    artist.id,
                    artist.name,
                  );
                  await AudioPlayerService().addToQueueList(songs);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${artist.name} to queue')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
