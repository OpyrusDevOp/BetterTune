import 'package:bettertune/models/enums.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  bool isplaying = true;
  bool isShuffled = false;
  PlayCycle repeatCycle = PlayCycle.noRepeat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.keyboard_arrow_down, size: 40),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.fromSize(
              size: Size.fromHeight(375),
              child: Card(color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text("Solo", style: TextTheme.of(context).headlineLarge),
            Text("Future", style: TextTheme.of(context).titleMedium),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.playlist_play_outlined),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              ],
            ),
            Slider(value: 10, min: 0, max: 60, onChanged: (value) {}),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("2:19"), Text("4:24")],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isShuffled = !isShuffled;
                    });
                  },

                  color: isShuffled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  icon: Icon(Icons.shuffle, size: 25),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.skip_previous, size: 35),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isplaying = !isplaying;
                    });
                  },
                  icon: Icon(
                    isplaying ? Icons.pause : Icons.play_arrow,
                    size: 35,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.skip_next, size: 35),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      switch (repeatCycle) {
                        case PlayCycle.noRepeat:
                          repeatCycle = PlayCycle.repeatAll;
                        case PlayCycle.repeatAll:
                          repeatCycle = PlayCycle.repeatOne;
                        default:
                          repeatCycle = PlayCycle.noRepeat;
                      }
                    });
                  },
                  color: repeatCycle != PlayCycle.noRepeat
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  icon: Icon(
                    repeatCycle == PlayCycle.repeatOne
                        ? Icons.repeat_one
                        : Icons.repeat,
                    size: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
