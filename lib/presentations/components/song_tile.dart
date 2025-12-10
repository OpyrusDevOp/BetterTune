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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: selectionMode ? onSelection : onPress,
        onLongPress: selectionMode ? null : onSelection,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelect
                ? colorScheme.primaryContainer.withAlpha(50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelect
                ? Border.all(color: colorScheme.primary, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (selectionMode) ...[
                Checkbox(
                  value: isSelect,
                  onChanged: (v) => onSelection(),
                  activeColor: colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],

              // Album Art
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withAlpha(100),
                      colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.artist} • ${song.album}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(180),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // More Options
              if (!selectionMode)
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _showOptions(context),
                  splashRadius: 20,
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
