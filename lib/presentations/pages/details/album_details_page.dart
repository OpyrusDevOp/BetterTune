import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/global_action_buttons.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bettertune/presentations/utils/song_options_helper.dart';
import 'package:bettertune/services/audio_player_service.dart';

class AlbumDetailsPage extends StatefulWidget {
  final Album album;

  const AlbumDetailsPage({super.key, required this.album});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  // Mock songs for this album
  // Mock songs for this album
  Future<List<Song>>? _songsFuture;
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    _songsFuture = SongsService().getSongsByAlbum(widget.album.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Sliver AppBar with Hero Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.album.title),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              ApiClient().getImageUrl(
                                widget.album.id,
                                width: 800,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.album,
                            size: 100,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Global Actions
              SliverToBoxAdapter(
                child: GlobalActionButtons(
                  onPlayAll: () async {
                    if (_songsFuture != null) {
                      final songs = await _songsFuture!;
                      if (songs.isNotEmpty) {
                        AudioPlayerService().setQueue(songs);
                        if (context.mounted) {
                          Navigator.of(context).pushNamed('/player');
                        }
                      }
                    }
                  },
                  onShuffle: () async {
                    if (_songsFuture != null) {
                      final songs = await _songsFuture!;
                      if (songs.isNotEmpty) {
                        final shuffled = List<Song>.from(songs)..shuffle();
                        AudioPlayerService().setQueue(shuffled);
                        if (context.mounted) {
                          Navigator.of(context).pushNamed('/player');
                        }
                      }
                    }
                  },
                  onAddToPlaylist: () async {
                    if (_songsFuture != null) {
                      final songs = await _songsFuture!;
                      if (context.mounted) {
                        showAddToPlaylistDialog(context, songs);
                      }
                    }
                  },
                ),
              ),

              // 3. Song List
              FutureBuilder<List<Song>>(
                future: _songsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  final songs = snapshot.data ?? [];
                  if (songs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: Text("No songs found")),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                            // Play context
                            AudioPlayerService().setQueue(
                              songs,
                              initialIndex: index,
                            );
                            Navigator.of(context).pushNamed('/player');
                          }
                        },
                        trailing: selectionMode
                            ? null
                            : IconButton(
                                icon: Icon(Icons.more_vert),
                                onPressed: () => showSongOptions(context, song),
                              ),
                      );
                    }, childCount: songs.length),
                  );
                },
              ),
              // Add padding at bottom for FAB or BottomBar
              SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),

          // 4. Selection Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedSongs.length,
              onPlay: () {
                if (selectedSongs.isNotEmpty) {
                  AudioPlayerService().setQueue(selectedSongs.toList());
                  Navigator.pushNamed(context, '/player');
                  setState(() {
                    selectedSongs.clear();
                    selectionMode = false;
                  });
                }
              },
              onAddToQueue: () async {
                if (selectedSongs.isNotEmpty) {
                  await AudioPlayerService().addToQueueList(
                    selectedSongs.toList(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Added ${selectedSongs.length} songs to queue",
                        ),
                      ),
                    );
                  }
                  setState(() {
                    selectedSongs.clear();
                    selectionMode = false;
                  });
                }
              },
              onAddToPlaylist: () {
                showAddToPlaylistDialog(context, selectedSongs.toList());
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
