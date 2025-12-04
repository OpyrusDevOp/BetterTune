import 'package:flutter/material.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});
  @override
  State<MiniPlayer> createState() => MiniPlayerState();
}

class MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(child: Icon(Icons.music_note)),
      Spacer(flex: 1),
      Expanded(
        flex: 20,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Solo", style: TextStyle(color: Colors.white)),
              Text("Future", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.skip_previous),
        color: Colors.white,
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.play_arrow),
        color: Colors.white,
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.skip_next),
        color: Colors.white,
      ),
    ],
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
