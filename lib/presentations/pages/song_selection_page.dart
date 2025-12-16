import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:bettertune/presentations/components/song_tile.dart';
import 'package:flutter/material.dart';

class SongSelectionPage extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const SongSelectionPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<SongSelectionPage> createState() => _SongSelectionPageState();
}

class _SongSelectionPageState extends State<SongSelectionPage> {
  // Reuse similar logic from SongsPage but with selection enforced
  final ScrollController _scrollController = ScrollController();
  List<Song> songs = [];
  Set<Song> selectedSongs = {};
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSongs() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newSongs = await SongsService().getSongs();

      if (mounted) {
        setState(() {
          songs = newSongs;
          // No pagination needed
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching songs: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addSelectedSongs() async {
    if (selectedSongs.isEmpty) return;

    try {
      final ids = selectedSongs.map((s) => s.id).toList();
      await PlaylistService().addToPlaylist(widget.playlistId, ids);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added ${selectedSongs.length} songs to ${widget.playlistName}",
            ),
          ),
        );
        Navigator.pop(context); // Go back to playlists page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add songs: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add to ${widget.playlistName}"),
        actions: [
          if (selectedSongs.isNotEmpty)
            TextButton(
              onPressed: _addSelectedSongs,
              child: Text(
                "Add (${selectedSongs.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: songs.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: songs.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == songs.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final song = songs[index];
                final isSelected = selectedSongs.contains(song);

                return SongTile(
                  song: song,
                  isSelect: isSelected, // Always show selection state visually
                  selectionMode: true, // Force selection mode visual
                  onPress: () {
                    setState(() {
                      if (isSelected) {
                        selectedSongs.remove(song);
                      } else {
                        selectedSongs.add(song);
                      }
                    });
                  },
                  onSelection: () {
                    // Same as onPress
                    setState(() {
                      if (isSelected) {
                        selectedSongs.remove(song);
                      } else {
                        selectedSongs.add(song);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}
