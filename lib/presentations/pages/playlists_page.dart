import 'package:flutter/material.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {
  bool selectionMode = false;
  Set<String> selectedPlaylists = {};

  final playlists = List<String>.generate(20, (index) => 'Playlist $index');

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedPlaylists.isNotEmpty || selectionMode) {
          setState(() {
            selectedPlaylists.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          final isSelected = selectedPlaylists.contains(playlist);
          return ListTile(
            leading: Icon(Icons.queue_music),
            title: Text(playlist),
            selected: isSelected,
            trailing: selectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (v) => onPlaylistSelection(playlist),
                  )
                : IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
            onTap: () {
              if (selectionMode) {
                onPlaylistSelection(playlist);
              } else {
                // Open playlist
              }
            },
            onLongPress: () {
              if (!selectionMode) {
                onPlaylistSelection(playlist);
              }
            },
          );
        },
      ),
    );
  }

  void onPlaylistSelection(String playlist) {
    if (!selectionMode) {
      selectedPlaylists.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedPlaylists.contains(playlist)) {
        selectedPlaylists.remove(playlist);
      } else {
        selectedPlaylists.add(playlist);
      }
      if (selectedPlaylists.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
