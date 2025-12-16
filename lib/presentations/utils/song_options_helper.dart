import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/presentations/dialogs/add_to_playlist_dialog.dart';
import 'package:flutter/material.dart';

void showSongOptions(BuildContext context, Song song) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text("Play"),
              onTap: () {
                Navigator.pop(context);
                AudioPlayerService().playSong(song);
                // Optionally navigate to player or show mini player
                Navigator.pushNamed(context, '/player');
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music), // or playlist_play
              title: const Text("Add to Queue"),
              onTap: () {
                Navigator.pop(context);
                AudioPlayerService().addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added ${song.name} to queue")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text("Add to Playlist"),
              onTap: () {
                Navigator.pop(context);
                showAddToPlaylistDialog(context, [song]);
              },
            ),
            // Potential future options:
            // ListTile(leading: Icon(Icons.person), title: Text("Go to Artist"), ...),
            // ListTile(leading: Icon(Icons.album), title: Text("Go to Album"), ...),
          ],
        ),
      );
    },
  );
}
