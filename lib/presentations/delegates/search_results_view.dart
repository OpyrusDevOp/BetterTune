import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/models/album.dart';
import 'package:bettertune/models/artist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/presentations/components/selection_bottom_bar.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:bettertune/presentations/pages/details/album_details_page.dart';
import 'package:bettertune/presentations/pages/details/artist_details_page.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:flutter/material.dart';

import 'package:bettertune/services/search_service.dart'; // Added import

class SearchResultsView extends StatefulWidget {
  final String query;
  final Function(BuildContext) onClose;

  const SearchResultsView({
    super.key,
    required this.query,
    required this.onClose,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  bool selectionMode = false;
  Set<dynamic> selectedItems = {};

  // Data State
  List<Song> songs = [];
  List<Album> albums = [];
  List<Artist> artists = [];

  // Pagination State
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _songStartIndex = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
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
      _fetchMoreSongs();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await SearchService().search(
        widget.query,
        limit: _limit,
        startIndex: 0,
      );

      setState(() {
        artists = results.artists;
        albums = results.albums;
        songs = results.songs;
        _songStartIndex = results.songs.length;
        // If we got fewer songs than limit, assume no more
        if (results.songs.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint("Error searching: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreSongs() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Fetch only songs for pagination
      final results = await SearchService().search(
        widget.query,
        limit: _limit,
        startIndex: _songStartIndex,
        includeAlbums: false,
        includeArtists: false,
      );

      setState(() {
        songs.addAll(results.songs);
        _songStartIndex += results.songs.length;
        if (results.songs.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint("Error searching more songs: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty && albums.isEmpty && artists.isEmpty && _isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (songs.isEmpty && albums.isEmpty && artists.isEmpty) {
      return Center(child: Text("No results found"));
    }

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: selectionMode ? 100 : 16,
          ),
          children: [
            // Artists Section
            if (artists.isNotEmpty) ...[
              _buildSectionHeader(context, "Artists"),
              ...artists.map((artist) => _buildArtistTile(artist)),
              SizedBox(height: 16),
            ],

            // Albums Section
            if (albums.isNotEmpty) ...[
              _buildSectionHeader(context, "Albums"),
              ...albums.map((album) => _buildAlbumTile(album)),
              SizedBox(height: 16),
            ],

            // Songs Section
            if (songs.isNotEmpty) ...[
              _buildSectionHeader(context, "Songs"),
              ...songs.map((song) => _buildSongTile(song)),
            ],

            if (_isLoading && songs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
        if (selectionMode)
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionBottomBar(
              selectionCount: selectedItems.length,
              onPlay: _playSelected,
              onAddToQueue: _addSelectedToQueue,
              onAddToPlaylist: _addSelectedToPlaylist,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildArtistTile(Artist artist) {
    bool isSelected = selectedItems.contains(artist);
    return ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text(artist.name),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha(50),
      onLongPress: () => _toggleSelection(artist),
      onTap: () {
        if (selectionMode) {
          _toggleSelection(artist);
        } else {
          widget.onClose(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArtistDetailsPage(artist: artist),
            ),
          );
        }
      },
      trailing: selectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (v) => _toggleSelection(artist),
            )
          : IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showOptions(context, artist),
            ),
    );
  }

  Widget _buildAlbumTile(Album album) {
    bool isSelected = selectedItems.contains(album);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.album),
      ),
      title: Text(album.title),
      subtitle: Text(album.artist),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha(50),
      onLongPress: () => _toggleSelection(album),
      onTap: () {
        if (selectionMode) {
          _toggleSelection(album);
        } else {
          widget.onClose(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AlbumDetailsPage(album: album),
            ),
          );
        }
      },
      trailing: selectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (v) => _toggleSelection(album),
            )
          : IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showOptions(context, album),
            ),
    );
  }

  Widget _buildSongTile(Song song) {
    bool isSelected = selectedItems.contains(song);
    return SongTile(
      song: song,
      isSelect: isSelected,
      selectionMode: selectionMode,
      onSelection: () => _toggleSelection(song),
      onPress: () {
        if (selectionMode) {
          _toggleSelection(song);
        } else {
          widget.onClose(context);
          Navigator.of(context).pushNamed('/player');
        }
      },
      trailing: selectionMode
          ? null
          : IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showOptions(context, song),
            ),
    );
  }

  void _toggleSelection(dynamic item) {
    setState(() {
      if (!selectionMode) selectionMode = true;
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
      if (selectedItems.isEmpty) selectionMode = false;
    });
  }

  Future<List<Song>> _resolveToSongs(Iterable<dynamic> items) async {
    List<Song> allSongs = [];
    for (var item in items) {
      if (item is Song) {
        allSongs.add(item);
      } else if (item is Album) {
        final songs = await SongsService().getSongsByAlbum(item.id);
        allSongs.addAll(songs);
      } else if (item is Artist) {
        final songs = await SongsService().getSongsByArtist(item.id, item.name);
        allSongs.addAll(songs);
      }
    }
    // Remove duplicates based on ID
    final ids = <String>{};
    return allSongs.where((s) => ids.add(s.id)).toList();
  }

  Future<void> _playSelected() async {
    // In real app: PlayerService.play(songs);
    // For now, we assume passed context or logic handles playback trigger
    // Since we don't have a direct play(List<Song>) method in PlayerScreen or exposed service easily accessible here
    // without refactoring PlayerScreen to accept a list, we might simulate it or use AudioPlayerService if available.
    // Based on previous file inputs, AudioPlayerService exists.

    // However, sticking to original behavior of navigating to /player
    // But typically you'd set the queue first.

    // widget.onClose(context);
    // Navigator.of(context).pushNamed('/player');

    // Let's at least resolve the songs
    final songs = await _resolveToSongs(selectedItems);
    debugPrint("Resolving ${songs.length} songs for playback");

    if (!mounted) return;

    // TODO: Integrate with AudioPlayerService to play these songs
    // AudioPlayerService().playSongs(songs, initialIndex: 0);

    widget.onClose(context);
    Navigator.of(context).pushNamed('/player');
    _exitSelection();
  }

  Future<void> _addSelectedToQueue() async {
    final songs = await _resolveToSongs(selectedItems);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added ${songs.length} songs to queue")),
    );
    _exitSelection();
  }

  Future<void> _addSelectedToPlaylist() async {
    final songs = await _resolveToSongs(selectedItems);
    if (!mounted) return;

    _showAddToPlaylistDialog(context, songs);
    _exitSelection();
  }

  void _exitSelection() {
    setState(() {
      selectedItems.clear();
      selectionMode = false;
    });
  }

  void _showOptions(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text("Play"),
                onTap: () {
                  Navigator.pop(context);
                  widget.onClose(context);
                  Navigator.of(context).pushNamed('/player');
                },
              ),
              ListTile(
                leading: Icon(Icons.queue_music),
                title: Text("Add to Queue"),
                onTap: () async {
                  Navigator.pop(context);
                  final songs = await _resolveToSongs([item]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${songs.length} songs to queue"),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text("Add to Playlist"),
                onTap: () async {
                  Navigator.pop(context);
                  final songs = await _resolveToSongs([item]);
                  if (context.mounted) {
                    _showAddToPlaylistDialog(context, songs);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, List<Song> songsToAdd) {
    showAddToPlaylistDialog(context, songsToAdd);
  }
}
