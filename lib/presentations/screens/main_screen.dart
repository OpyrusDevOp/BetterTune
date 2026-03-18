import 'package:bettertune/presentations/components/mini_player.dart';
import 'package:bettertune/presentations/pages/albums_page.dart';
import 'package:bettertune/presentations/pages/artists_page.dart';
import 'package:bettertune/presentations/pages/favourites_page.dart';
import 'package:bettertune/presentations/pages/playlists_page.dart';
import 'package:bettertune/presentations/pages/songs_page.dart';
import 'package:bettertune/presentations/pages/settings_page.dart';

import 'package:bettertune/presentations/delegates/global_search_delegate.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/services/sync_service.dart';
import 'package:bettertune/presentations/screens/onboarding_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  bool _syncing = false;
  String _syncStatus = '';
  // Incremented after auto-sync so pages rebuild and reload from the now-filled DB
  int _syncVersion = 0;

  List<Widget> get pages => [
    SongsPage(key: ValueKey('songs_$_syncVersion')),
    AlbumsPage(key: ValueKey('albums_$_syncVersion')),
    ArtistsPage(key: ValueKey('artists_$_syncVersion')),
    PlaylistsPage(key: ValueKey('playlists_$_syncVersion')),
    FavouritesPage(key: ValueKey('favourites_$_syncVersion')),
  ];

  @override
  void initState() {
    super.initState();
    // On web the DB is in-memory and empty after every reload — auto-sync.
    if (kIsWeb) _autoSyncIfEmpty();
  }

  Future<void> _autoSyncIfEmpty() async {
    final songs = await SongsService().getSongs();
    if (songs.isNotEmpty || !mounted) return;
    setState(() { _syncing = true; _syncStatus = 'Syncing library…'; });
    await SyncService().syncLibrary((status) {
      if (mounted) setState(() => _syncStatus = status);
    });
    if (!mounted) return;
    setState(() { _syncing = false; _syncVersion++; });
  }

  void _onTabTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Better Tune"),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: GlobalSearchDelegate());
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => _showOptions(context),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: pages[currentPage]),
              MiniPlayer(),
            ],
          ),
          if (_syncing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_syncStatus,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Songs"),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: "Albums"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Artists"),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: "Playlists",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
