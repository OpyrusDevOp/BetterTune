import 'package:bettertune/screens/home_screen.dart';
import 'package:bettertune/screens/player_screen.dart';
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

  static List<Widget> pages = [HomeScreen()];
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
            child: pages[0],
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
              createDrawerOption('Songs', 0, Icons.music_note),
              createDrawerOption('Playlists', 1, Icons.playlist_play),
              createDrawerOption('Albums', 2, Icons.album),
              createDrawerOption('Artists', 3, Icons.person),
              createDrawerOption('Genres', 4, Icons.music_note),
            ],
          ),
        ),
        bottomNavigationBar: bottomPlayer(),
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

  Route<void> _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Widget bottomPlayer() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A2332),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress Bar
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
          ),
          child: Slider(value: 0.3, onChanged: (value) {}),
        ),

        // Player Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.blue.shade900,
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chaff & Dust',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'HVÖNNÅ',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Playback Controls
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.white, size: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
