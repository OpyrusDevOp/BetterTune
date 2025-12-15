import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/global_action_buttons.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:flutter/material.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  Future<List<Song>>? _playlistSongsFuture;
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    _playlistSongsFuture = PlaylistService().getPlaylistItems(
      widget.playlist.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.name)),
      body: Stack(
        children: [
          Column(
            children: [
              GlobalActionButtons(
                onPlayAll: () => print("Play Playlist"),
                onShuffle: () => print("Shuffle Playlist"),
                onAddToPlaylist: () => print("Add Playlist to another"),
              ),
              Expanded(
                child: FutureBuilder<List<Song>>(
                  future: _playlistSongsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final songs = snapshot.data ?? [];

                    if (songs.isEmpty) {
                      return const Center(
                        child: Text("This playlist is empty."),
                      );
                    }

                    return ListView.builder(
                      itemCount: songs.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        final isSelected = selectedSongs.contains(song);
                        return SongTile(
                          song: song,
                          isSelect: isSelected,
                          selectionMode: selectionMode,
                          onSelection: () => onSongSelection(song),
                          onPress: () {
                            if (selectionMode) {
                              onSongSelection(song);
                            } else {
                              print("Play ${song.name}");
                              Navigator.of(context).pushNamed('/player');
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedSongs.length,
              onPlay: () => print("Play Selected"),
              onAddToPlaylist: () => print("Add to Playlist"),
              onDelete: () {
                // Remove functionality
                print("Remove from playlist");
                setState(() {
                  selectedSongs.clear();
                  selectionMode = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void onSongSelection(Song song) {
    if (!selectionMode) {
      setState(() => selectionMode = true);
    }
    setState(() {
      if (selectedSongs.contains(song)) {
        selectedSongs.remove(song);
      } else {
        selectedSongs.add(song);
      }
      if (selectedSongs.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
