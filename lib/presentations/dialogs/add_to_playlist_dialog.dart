import 'package:bettertune/models/playlist.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/playlist_service.dart';
import 'package:flutter/material.dart';

void showAddToPlaylistDialog(BuildContext context, List<Song> songsToAdd) {
  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<List<Playlist>>(
        future: PlaylistService().getPlaylists(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final playlists = snapshot.data!;

          return AlertDialog(
            title: const Text("Add to Playlist"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("New Playlist"),
                      onTap: () {
                        Navigator.pop(context);
                        _createNewPlaylist(context, songsToAdd);
                      },
                    );
                  }
                  final p = playlists[index - 1];
                  return ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(p.name),
                    onTap: () async {
                      try {
                        List<String> ids = songsToAdd.map((s) => s.id).toList();
                        await PlaylistService().addToPlaylist(p.id, ids);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Added to ${p.name}")),
                          );
                        }
                      } catch (e) {
                        debugPrint("Failed to add to playlist: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}

void _createNewPlaylist(BuildContext context, List<Song> songsToAdd) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("New Playlist Name"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "My Playlist"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await PlaylistService().createPlaylist(controller.text);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Playlist Created")),
                    );

                    // Ideally, we'd add songs here too if we got the ID back
                    // For now, let's just create it and maybe the user will add it again
                  }
                } catch (e) {
                  debugPrint("Failed to create playlist: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to create: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}
