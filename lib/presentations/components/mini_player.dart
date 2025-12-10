import 'package:flutter/material.dart';
import 'package:bettertune/presentations/screens/player_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});
  @override
  State<MiniPlayer> createState() => MiniPlayerState();
}

class MiniPlayerState extends State<MiniPlayer> {
  void openPlayer() => Navigator.of(context).push(_createRoute());

  Route<void> _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: openPlayer,
    child: Row(
      children: [
        CircleAvatar(child: Icon(Icons.music_note)),
        const SizedBox(width: 10),
        Expanded(
          flex: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Solo",
                // style: TextStyle(color: Colors.white),
                textWidthBasis: TextWidthBasis.parent,
              ),
              Text(
                "Future",
                // style: TextStyle(color: Colors.white),
                textWidthBasis: TextWidthBasis.parent,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.skip_previous),
          // color: Colors.white,
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.play_arrow),
          // color: Colors.white,
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.skip_next),
          // color: Colors.white,
        ),
      ],
    ),
  );

  // ListTile(
  //   contentPadding: EdgeInsets.zero,
  //   minVerticalPadding: 0,
  //   leading: CircleAvatar(child: Icon(Icons.music_note)),
  //   title: Text("Solo"),
  //   subtitle: Text("Future"),
  //   // trailing: SizedBox.expand(
  //   //   child: Row(
  //   //     children: [
  //   //       IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous)),
  //   //       IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow)),
  //   //       IconButton(onPressed: () {}, icon: Icon(Icons.skip_next)),
  //   //     ],
  //   //   ),
  //   // ),
  // );
}
