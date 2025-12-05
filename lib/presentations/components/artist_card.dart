import 'package:flutter/material.dart';

import '../../models/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  const ArtistCard({super.key, required this.artist});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        children: [
          Expanded(
            child: CircleAvatar(
              radius: 80,
              child: Icon(Icons.person, size: 40),
            ),
          ),
          Text(artist.name, style: TextTheme.of(context).titleLarge),
        ],
      ),
    );
  }
}
