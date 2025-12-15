import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageStateSongsPage();
}

class _SongsPageStateSongsPage extends State<SongsPage> {
  bool selectionMode = false;
  late Future<List<Song>>
  _songsFuture; // Removed in favor of manual list management
  List<Song> songs = [];
  Set<Song> selectedSongs = {};

  // Pagination State
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _startIndex = 0;
  final int _limit = 50; // Fetch 50 at a time

  @override
  void initState() {
    super.initState();
    _fetchSongs(); // Initial fetch
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchSongs();
    }
  }

  Future<void> _fetchSongs({bool isRefresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (isRefresh) {
      _startIndex = 0;
      _hasMore = true;
      songs.clear();
    }

    try {
      final newSongs = await SongsService().getSongs(
        limit: _limit,
        startIndex: _startIndex,
      );

      setState(() {
        if (isRefresh) {
          songs = newSongs;
        } else {
          songs.addAll(newSongs);
        }

        _startIndex += newSongs.length;
        if (newSongs.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint("Error fetching songs: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedSongs.isNotEmpty) {
          setState(() {
            selectedSongs.clear();
            selectionMode = false;
          });
          return;
        }
      },
      child: RefreshIndicator(
        onRefresh: () async => await _fetchSongs(isRefresh: true),
        child: Stack(
          children: [
            if (songs.isEmpty && _isLoading)
              const Center(child: CircularProgressIndicator())
            else if (songs.isEmpty)
              const Center(child: Text("No songs found."))
            else
              ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: songs.length + (_hasMore ? 1 : 0),
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  if (index == songs.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  var song = songs[index];
                  var isSelected = selectedSongs.contains(song);

                  return SongTile(
                    song: song,
                    isSelect: isSelected,
                    onPress: () => onSongClick(song),
                    onSelection: () => onSongSelection(song),
                    selectionMode: selectionMode,
                    trailing: selectionMode
                        ? null
                        : IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () => _showSongOptions(context, song),
                          ),
                  );
                },
              ),

            if (selectionMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SelectionBottomBar(
                    selectionCount: selectedSongs.length,
                    onPlay: () {
                      print("Play ${selectedSongs.length} items");
                      _exitSelection();
                    },
                    onAddToPlaylist: () {
                      showAddToPlaylistDialog(context, selectedSongs.toList());
                      _exitSelection();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _exitSelection() {
    setState(() {
      selectedSongs.clear();
      selectionMode = false;
    });
  }

  void onSongClick(Song song) {
    // Open Player
    print("Playing ${song.name}");
    if (selectionMode) {
      onSongSelection(song);
    } else {
      _playAndOpenPlayer(song);
    }
  }

  void _playAndOpenPlayer(Song song) {
    AudioPlayerService().playSong(song);
    Navigator.pushNamed(context, '/player');
  }

  void onSongSelection(Song song) {
    setState(() {
      if (!selectionMode) selectionMode = true;
      if (selectedSongs.contains(song)) {
        selectedSongs.remove(song);
      } else {
        selectedSongs.add(song);
      }
      if (selectedSongs.isEmpty) selectionMode = false;
    });
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text("Play"),
                onTap: () {
                  Navigator.pop(context);
                  _playAndOpenPlayer(song);
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text("Add to Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  showAddToPlaylistDialog(context, [song]);
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Go to Artist"),
                onTap: () {
                  Navigator.pop(context);
                  print("Go to Artist: ${song.artist}");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
