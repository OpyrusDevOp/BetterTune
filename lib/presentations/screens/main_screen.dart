import 'package:bettertune/presentations/components/mini_player.dart';
import 'package:bettertune/presentations/pages/albums_page.dart';
import 'package:bettertune/presentations/pages/artists_page.dart';
import 'package:bettertune/presentations/pages/favourites_page.dart';
import 'package:bettertune/presentations/pages/playlists_page.dart';
import 'package:bettertune/presentations/pages/songs_page.dart';

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
  void drawerOptionClick(int pageIndex) {
    setState(() {
      currentPage = pageIndex;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Better Tune"),
        forceMaterialTransparency: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(
            onPressed: () => _showOptions(context),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Center(child: Text("Better Tune"))),
            ListTile(
              title: Text("Songs"),
              selected: currentPage == 0,
              onTap: () => drawerOptionClick(0),
            ),
            ListTile(
              title: Text("Albums"),
              selected: currentPage == 1,
              onTap: () => drawerOptionClick(1),
            ),
            ListTile(
              title: Text("Artists"),
              selected: currentPage == 2,
              onTap: () => drawerOptionClick(2),
            ),
            ListTile(
              title: Text("Playlists"),
              selected: currentPage == 3,
              onTap: () => drawerOptionClick(3),
            ),
            ListTile(
              title: Text("Favourites"),
              selected: currentPage == 4,
              onTap: () => drawerOptionClick(4),
            ),
          ],
        ),
      ),
      body: pages[currentPage],
      bottomNavigationBar: Container(
        height: 70,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        transformAlignment: AlignmentGeometry.topLeft,
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadiusGeometry.circular(20),
          // backgroundBlendMode: BlendMode.darken,
        ),
        child: Container(
          alignment: AlignmentGeometry.topLeft,
          child: MiniPlayer(),
        ),
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
                onTap: () async {},
              ),
            ],
          ),
        );
      },
    );
  }
}
