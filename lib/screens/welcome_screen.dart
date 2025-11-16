import 'package:bettertune/components/mini_player.dart';
import 'package:bettertune/screens/artists_screen.dart';
import 'package:bettertune/screens/home_screen.dart';
import 'package:bettertune/screens/playlists_screen.dart';
import 'package:bettertune/screens/songs_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  static List<Widget> pages = [
    HomeScreen(),
    SongsScreen(),
    SongsScreen(),
    ArtistsScreen(),
    PlaylistsScreen(),
  ];
  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Add search functionality here
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsetsDirectional.only(top: 20),
            child: pages[_selectedIndex],
          ),
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF1A2332),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(),

                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,

                    children: [
                      Icon(
                        Icons.music_note,
                        size: 36,
                        color: Colors.lightBlueAccent,
                      ),
                      Text(
                        'BetterTune',

                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              createDrawerOption('Accueil', 0, Icons.home),
              createDrawerOption('Songs', 1, Icons.music_note),
              createDrawerOption('Albums', 2, Icons.album),
              createDrawerOption('Artists', 3, Icons.person),
              createDrawerOption('Playlists', 4, Icons.playlist_play),
            ],
          ),
        ),
        bottomNavigationBar: MiniPlayer(),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  ListTile createDrawerOption(String title, int itemIndex, IconData icon) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        selected: _selectedIndex == itemIndex,
        onTap: () {
          // Update the state of the app
          _onItemTapped(itemIndex);
          // Then close the drawer
          Navigator.pop(context);
        },
      );
}
