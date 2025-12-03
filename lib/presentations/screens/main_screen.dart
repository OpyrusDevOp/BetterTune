import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  void drawerOptionClick() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Better Tune"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Center(child: Text("Better Tune"))),
            ListTile(title: Text("Songs"), onTap: drawerOptionClick),
            ListTile(title: Text("Albums"), onTap: drawerOptionClick),
            ListTile(title: Text("Artists"), onTap: drawerOptionClick),
            ListTile(title: Text("Playlists"), onTap: drawerOptionClick),
            ListTile(title: Text("Favourites"), onTap: drawerOptionClick),
          ],
        ),
      ),
    );
  }
}
