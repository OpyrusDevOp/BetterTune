import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/pages/details/playlist_details_page.dart';
import 'package:flutter/material.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {
  bool selectionMode = false;
  Set<Playlist> selectedPlaylists = {};

  final playlists = List<Playlist>.generate(
    20,
    (index) => Playlist(id: "pl_$index", name: 'Playlist $index'),
  );

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
      child: Stack(
        children: [
          ListView.builder(
            itemCount: playlists.length,
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final isSelected = selectedPlaylists.contains(playlist);
              return ListTile(
                leading: Icon(Icons.queue_music),
                title: Text(playlist.name),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistDetailsPage(playlist: playlist),
                      ),
                    );
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedPlaylists.length,
              onPlay: () => print("Play Selected Playlists"),
              onAddToPlaylist: () => print("Merge Select Playlists"),
              onDelete: () => print("Delete Selected Playlists"),
            ),
          ),
        ],
      ),
    );
  }

  void onPlaylistSelection(Playlist playlist) {
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
