import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/pages/details/playlist_details_page.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {
  bool selectionMode = false;
  Set<Playlist> selectedPlaylists = {};
  late Future<List<Playlist>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = PlaylistService().getPlaylists();
  }

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
      child: FutureBuilder<List<Playlist>>(
        future: _playlistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final playlists = snapshot.data ?? [];

          if (playlists.isEmpty) {
            return const Center(child: Text("No playlists found"));
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: playlists.length,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final isSelected = selectedPlaylists.contains(playlist);
                  return ListTile(
                    leading: const Icon(Icons.queue_music, size: 30),
                    title: Text(playlist.name),
                    selected: isSelected,
                    trailing: selectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (v) => onPlaylistSelection(playlist),
                          )
                        : IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
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
                  onAddToPlaylist: () async {
                    List<Song> allSongs = [];
                    for (var playlist in selectedPlaylists) {
                      final songs = await PlaylistService().getPlaylistItems(
                        playlist.id,
                      );
                      allSongs.addAll(songs);
                    }
                    if (context.mounted) {
                      showAddToPlaylistDialog(context, allSongs);
                    }
                    setState(() {
                      selectedPlaylists.clear();
                      selectionMode = false;
                    });
                  },
                  onDelete: () => print("Delete Selected Playlists"),
                ),
              ),
            ],
          );
        },
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
