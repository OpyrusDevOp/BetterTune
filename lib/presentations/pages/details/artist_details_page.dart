import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/global_action_buttons.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:flutter/material.dart';
import 'package:bettertune/presentations/utils/song_options_helper.dart';
import 'package:bettertune/services/audio_player_service.dart';

class ArtistDetailsPage extends StatefulWidget {
  final Artist artist;

  const ArtistDetailsPage({super.key, required this.artist});

  @override
  State<ArtistDetailsPage> createState() => _ArtistDetailsPageState();
}

class _ArtistDetailsPageState extends State<ArtistDetailsPage> {
  // Mock Data: Map of Album Name -> List of Songs
  // Mock Data: Map of Album Name -> List of Songs
  Future<Map<String, List<Song>>>? _dataFuture;
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchArtistData();
  }

  Future<Map<String, List<Song>>> _fetchArtistData() async {
    final songs = await SongsService().getSongsByArtist(
      widget.artist.id,
      widget.artist.name,
    );
    // Group by album
    final Map<String, List<Song>> grouped = {};
    for (var song in songs) {
      if (!grouped.containsKey(song.album)) {
        grouped[song.album] = [];
      }
      grouped[song.album]!.add(song);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.artist.name),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Theme.of(context).primaryColorDark),
                      Container(color: Theme.of(context).primaryColorDark),
                      Image.network(
                        ApiClient().getImageUrl(widget.artist.id, width: 800),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: GlobalActionButtons(
                  onPlayAll: () async {
                    final songs = await SongsService().getSongsByArtist(
                      widget.artist.id,
                      widget.artist.name,
                    );
                    if (songs.isNotEmpty) {
                      AudioPlayerService().setQueue(songs);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/player');
                      }
                    }
                  },
                  onShuffle: () async {
                    final songs = await SongsService().getSongsByArtist(
                      widget.artist.id,
                      widget.artist.name,
                    );
                    if (songs.isNotEmpty) {
                      final shuffled = List<Song>.from(songs)..shuffle();
                      AudioPlayerService().setQueue(shuffled);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/player');
                      }
                    }
                  },
                  onAddToPlaylist: () async {
                    final songs = await SongsService().getSongsByArtist(
                      widget.artist.id,
                      widget.artist.name,
                    );
                    if (context.mounted) {
                      showAddToPlaylistDialog(context, songs);
                    }
                  },
                ),
              ),
              // Grouped List
              // Grouped List
              FutureBuilder<Map<String, List<Song>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  final albums = snapshot.data ?? {};
                  if (albums.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text("No songs found")),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final albumName = albums.keys.elementAt(index);
                      final albumSongs = albums[albumName]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Text(
                              albumName,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ),
                          ...albumSongs.map((song) {
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
                                  // Play this song within the context of its album
                                  // Find index of this song in the current album list
                                  final index = albumSongs.indexOf(song);
                                  AudioPlayerService().setQueue(
                                    albumSongs,
                                    initialIndex: index,
                                  );
                                  Navigator.of(context).pushNamed('/player');
                                }
                              },
                              trailing: selectionMode
                                  ? null
                                  : IconButton(
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () =>
                                          showSongOptions(context, song),
                                    ),
                            );
                          }),
                        ],
                      );
                    }, childCount: albums.length),
                  );
                },
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedSongs.length,
              onPlay: () => print("Play Selected"),
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
