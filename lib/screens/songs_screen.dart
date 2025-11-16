import 'package:flutter/material.dart';

import '../components/song_list_item.dart';
import '../datas/song.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  String _sortBy = 'title'; // title, artist, album, duration
  bool _isAscending = true;

  final List<Song> _songs = [
    Song(
      title: 'Believer',
      artist: 'Imagine Dragons',
      album: 'Evolve',
      duration: '3:24',
      albumColor: Colors.orange,
    ),
    Song(
      title: 'Shortwave',
      artist: 'Twin Peaks',
      album: 'Down in Heaven',
      duration: '4:12',
      albumColor: Colors.red,
    ),
    Song(
      title: 'Chaff & Dust',
      artist: 'HVÖNNÅ',
      album: 'Wilderness',
      duration: '3:45',
      albumColor: Colors.blue,
    ),
    Song(
      title: 'Monsters Go Bump',
      artist: 'Erika Recinos',
      album: 'Singles',
      duration: '2:58',
      albumColor: Colors.deepOrange,
    ),
    Song(
      title: 'Thunder',
      artist: 'Imagine Dragons',
      album: 'Evolve',
      duration: '3:07',
      albumColor: Colors.orange,
    ),
    Song(
      title: 'Radioactive',
      artist: 'Imagine Dragons',
      album: 'Night Visions',
      duration: '3:06',
      albumColor: Colors.purple,
    ),
    Song(
      title: 'Say My Name',
      artist: 'ODESZA',
      album: 'A Moment Apart',
      duration: '4:35',
      albumColor: Colors.blue,
    ),
    Song(
      title: 'Line of Sight',
      artist: 'ODESZA',
      album: 'A Moment Apart',
      duration: '4:42',
      albumColor: Colors.blue,
    ),
    Song(
      title: 'Demons',
      artist: 'Imagine Dragons',
      album: 'Night Visions',
      duration: '2:57',
      albumColor: Colors.purple,
    ),
    Song(
      title: 'Late Night',
      artist: 'ODESZA',
      album: 'A Moment Apart',
      duration: '3:52',
      albumColor: Colors.blue,
    ),
  ];

  List<Song> get _sortedSongs {
    final sorted = List<Song>.from(_songs);

    switch (_sortBy) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'artist':
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'album':
        sorted.sort((a, b) => a.album.compareTo(b.album));
        break;
      case 'duration':
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }

    if (!_isAscending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Sort by',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSortOption('Title', 'title'),
            _buildSortOption('Artist', 'artist'),
            _buildSortOption('Album', 'album'),
            _buildSortOption('Duration', 'duration'),
            const Divider(color: Colors.white24, height: 32),
            ListTile(
              leading: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
              title: Text(
                _isAscending ? 'Ascending' : 'Descending',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _isAscending = !_isAscending;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      leading: RadioGroup<String>(
        groupValue: _sortBy,
        onChanged: (val) {
          setState(() {
            _sortBy = val!;
          });
          Navigator.pop(context);
        },
        child: Text(value),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_songs.length} songs',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Songs List
            Expanded(
              child: ListView.builder(
                itemCount: _sortedSongs.length,
                itemBuilder: (context, index) {
                  final song = _sortedSongs[index];
                  return SongListItem(
                    song: song,
                    onTap: () {
                      // Navigate to player screen
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
