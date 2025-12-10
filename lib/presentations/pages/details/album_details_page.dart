import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/global_action_buttons.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:flutter/material.dart';

class AlbumDetailsPage extends StatefulWidget {
  final Album album;

  const AlbumDetailsPage({super.key, required this.album});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  // Mock songs for this album
  late List<Song> songs;
  bool selectionMode = false;
  Set<Song> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    songs = List.generate(
      12,
      (index) => Song(
        id: "${widget.album.id}_$index",
        name: "Track ${index + 1}",
        album: widget.album.title,
        artist: widget.album.artist,
        isFavorite: false,
      ),
    );
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
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
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
                  onPlayAll: () {
                    print("Play All from Album");
                  },
                  onShuffle: () {
                    print("Shuffle Album");
                  },
                  onAddToPlaylist: () {
                    print("Add Album to Playlist");
                  },
                ),
              ),

              // 3. Song List
              SliverList(
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
                        print("Play ${song.name}");
                      }
                    },
                  );
                }, childCount: songs.length),
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
              onPlay: () => print("Play Selected"),
              onAddToPlaylist: () => print("Add Selected to Playlist"),
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
