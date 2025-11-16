import 'package:flutter/material.dart';

class Playlist {
  final String name;
  final int songCount;
  final String? description;
  final Color color;
  final IconData icon;

  Playlist({
    required this.name,
    required this.songCount,
    this.description,
    required this.color,
    this.icon = Icons.playlist_play,
  });
}
