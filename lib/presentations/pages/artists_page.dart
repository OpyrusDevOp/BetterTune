import 'package:bettertune/models/artist.dart';
import 'package:bettertune/presentations/components/artist_card.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/pages/details/artist_details_page.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/models/song.dart';
import 'package:flutter/material.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => ArtistsPageState();
}

class ArtistsPageState extends State<ArtistsPage> {
  bool selectionMode = false;
  Set<Artist> selectedArtists = {};
  late Future<List<Artist>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = SongsService().getArtists();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedArtists.isNotEmpty || selectionMode) {
          setState(() {
            selectedArtists.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: FutureBuilder<List<Artist>>(
        future: _artistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final artists = snapshot.data ?? [];

          if (artists.isEmpty) {
            return const Center(child: Text("No artists found."));
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: artists.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return ArtistCard(
                      artist: artist,
                      selectionMode: selectionMode,
                      isSelect: selectedArtists.contains(artist),
                      onSelection: () => onArtistSelection(artist),
                      onPress: () {
                        if (selectionMode) {
                          onArtistSelection(artist);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArtistDetailsPage(artist: artist),
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
                  selectionCount: selectedArtists.length,
                  onPlay: () async {
                    if (selectedArtists.isNotEmpty) {
                      List<Song> allSongs = [];
                      for (var artist in selectedArtists) {
                        final songs = await SongsService().getSongsByArtist(
                          artist.id,
                          artist.name,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        AudioPlayerService().setQueue(allSongs);
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/player');
                        }
                        setState(() {
                          selectedArtists.clear();
                          selectionMode = false;
                        });
                      }
                    }
                  },
                  onAddToQueue: () async {
                    if (selectedArtists.isNotEmpty) {
                      List<Song> allSongs = [];
                      for (var artist in selectedArtists) {
                        final songs = await SongsService().getSongsByArtist(
                          artist.id,
                          artist.name,
                        );
                        allSongs.addAll(songs);
                      }
                      if (allSongs.isNotEmpty) {
                        await AudioPlayerService().addToQueueList(allSongs);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Added artists to queue")),
                          );
                        }
                        setState(() {
                          selectedArtists.clear();
                          selectionMode = false;
                        });
                      }
                    }
                  },
                  onAddToPlaylist: () async {
                    List<Song> allSongs = [];
                    for (var artist in selectedArtists) {
                      final songs = await SongsService().getSongsByArtist(
                        artist.id,
                        artist.name,
                      );
                      allSongs.addAll(songs);
                    }
                    if (context.mounted) {
                      showAddToPlaylistDialog(context, allSongs);
                    }
                    setState(() {
                      selectedArtists.clear();
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

  void onArtistSelection(Artist artist) {
    if (!selectionMode) {
      selectedArtists.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedArtists.contains(artist)) {
        selectedArtists.remove(artist);
      } else {
        selectedArtists.add(artist);
      }
      if (selectedArtists.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
