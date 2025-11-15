import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              createDrawerOption('Songs', 1),
              createDrawerOption('Playlists', 2),
              createDrawerOption('Albums', 3),
              createDrawerOption('Artists', 4),
              createDrawerOption('Genres', 5),
            ],
          ),
        ),
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
      _onItemTapped(1);
      // Then close the drawer
      Navigator.pop(context);
    },
  );
}
