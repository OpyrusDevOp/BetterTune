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
        ),
        body: Builder(builder: (context) => pages[0]),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              createDrawerOption('Songs', 0),
              createDrawerOption('Playlists', 1),
              createDrawerOption('Albums', 2),
              createDrawerOption('Artists', 3),
              createDrawerOption('Genres', 4),
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

  ListTile createDrawerOption(String title, int itemIndex) => ListTile(
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
