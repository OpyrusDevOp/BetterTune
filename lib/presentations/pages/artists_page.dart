import 'package:bettertune/models/artist.dart';
import 'package:bettertune/presentations/components/artist_card.dart';
import 'package:flutter/material.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => ArtistsPageState();
}

class ArtistsPageState extends State<ArtistsPage> {
  final artists = List<Artist>.generate(
    20,
    (index) => Artist(id: index.toString(), name: 'Future'),
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        children: List<ArtistCard>.generate(
          artists.length,
          (index) => ArtistCard(artist: artists[index]),
        ),
      ),
    );
  }
}
