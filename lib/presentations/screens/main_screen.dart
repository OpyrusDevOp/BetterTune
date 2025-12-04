import 'package:bettertune/presentations/components/mini_player.dart';
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
      bottomNavigationBar: Container(
        height: 70,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(24),
        transformAlignment: AlignmentGeometry.topLeft,
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadiusGeometry.circular(20),
          backgroundBlendMode: BlendMode.darken,
          boxShadow: [
            BoxShadow(
              color: Colors.black54.withAlpha(76),
              offset: Offset(0, 20),
              blurRadius: 20,
            ),
          ],
        ),
        child: Container(
          alignment: AlignmentGeometry.topLeft,
          child: MiniPlayer(),
        ),
      ),
    );
  }
}
