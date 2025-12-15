import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';

class PlaylistRepository {
  // Singleton
  static final PlaylistRepository _instance = PlaylistRepository._internal();
  factory PlaylistRepository() => _instance;
  PlaylistRepository._internal();

  // Mock Storage
  final List<Playlist> _playlists = [
    Playlist(id: "p1", name: "Favorites", songs: [], image: ""),
    Playlist(id: "p2", name: "Road Trip", songs: [], image: ""),
  ];

  Future<List<Playlist>> getPlaylists() async {
    // Simulate delay
    await Future.delayed(Duration(milliseconds: 100));
    return _playlists;
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(
      id: "p${_playlists.length + 1}",
      name: name,
      songs: [],
      image: "",
    );
    _playlists.add(newPlaylist);
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      // Create a copy to trigger updates if we were using listeners (but here just mutating)
      // In real app, check for duplicates
      _playlists[index].songs.add(song);
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.remove(song);
    }
  }
}
