import 'package:bettertune/presentations/components/mini_player.dart';
import 'package:bettertune/presentations/pages/albums_page.dart';
import 'package:bettertune/presentations/pages/artists_page.dart';
import 'package:bettertune/presentations/pages/favourites_page.dart';
import 'package:bettertune/presentations/pages/playlists_page.dart';
import 'package:bettertune/presentations/pages/songs_page.dart';
import 'package:bettertune/presentations/pages/settings_page.dart';

import 'package:bettertune/presentations/delegates/global_search_delegate.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/presentations/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  final pages = [
    SongsPage(),
    AlbumsPage(),
    ArtistsPage(),
    PlaylistsPage(),
    FavouritesPage(),
  ];

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
      body: Column(
        children: [
          // Expanded content page
          Expanded(child: pages[currentPage]),
          // Persistent Mini Player above the nav bar
          MiniPlayer(),
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
