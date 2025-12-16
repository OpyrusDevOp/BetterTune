import 'package:bettertune/models/album.dart';
import 'package:bettertune/presentations/components/album_card.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/pages/details/album_details_page.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => AlbumsPageState();
}

class AlbumsPageState extends State<AlbumsPage> {
  bool selectionMode = false;
  Set<Album> selectedAlbums = {};
  late Future<List<Album>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = SongsService().getAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedAlbums.isNotEmpty || selectionMode) {
          setState(() {
            selectedAlbums.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },

      child: FutureBuilder<List<Album>>(
        future: _albumsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final albums = snapshot.data ?? [];

          if (albums.isEmpty) {
            return const Center(child: Text("No albums found."));
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: albums.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return AlbumCard(
                      album: album,
                      selectionMode: selectionMode,
                      isSelect: selectedAlbums.contains(album),
                      onSelection: () => onAlbumSelection(album),
                      onPress: () {
                        if (selectionMode) {
                          onAlbumSelection(album);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AlbumDetailsPage(album: album),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SelectionBottomBar(
                  selectionCount: selectedAlbums.length,
                  onPlay: () async {
                    if (selectedAlbums.isNotEmpty) {
                      List<Song> allSongs = [];
                      for (var album in selectedAlbums) {
                        final songs = await SongsService().getSongsByAlbum(
                          album.id,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        AudioPlayerService().setQueue(allSongs);
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/player');
                        }
                        setState(() {
                          selectedAlbums.clear();
                          selectionMode = false;
                        });
                      }
                    }
                  },
                  onAddToQueue: () async {
                    if (selectedAlbums.isNotEmpty) {
                      List<Song> allSongs = [];
                      for (var album in selectedAlbums) {
                        final songs = await SongsService().getSongsByAlbum(
                          album.id,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        await AudioPlayerService().addToQueueList(allSongs);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Added albums to queue")),
                          );
                        }
                        setState(() {
                          selectedAlbums.clear();
                          selectionMode = false;
                        });
                      }
                    }
                  },
                  onAddToPlaylist: () async {
                    List<Song> allSongs = [];
                    for (var album in selectedAlbums) {
                      final songs = await SongsService().getSongsByAlbum(
                        album.id,
                      );
                      allSongs.addAll(songs);
                    }
                    if (context.mounted) {
                      showAddToPlaylistDialog(context, allSongs);
                    }
                    setState(() {
                      selectedAlbums.clear();
                      selectionMode = false;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onAlbumSelection(Album album) {
    if (!selectionMode) {
      selectedAlbums.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedAlbums.contains(album)) {
        selectedAlbums.remove(album);
      } else {
        selectedAlbums.add(album);
      }
      // Optional: Exit selection mode if all deselected?
      if (selectedAlbums.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
