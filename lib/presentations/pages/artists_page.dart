import 'package:bettertune/models/artist.dart';
import 'package:bettertune/presentations/components/artist_card.dart';
import 'package:flutter/material.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => ArtistsPageState();
}

class ArtistsPageState extends State<ArtistsPage> {
  bool selectionMode = false;
  Set<Artist> selectedArtists = {};

  final artists = List<Artist>.generate(
    20,
    (index) => Artist(id: index.toString(), name: 'Future'),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (didPop) return;
        if (selectedArtists.isNotEmpty || selectionMode) {
          setState(() {
            selectedArtists.clear();
            selectionMode = false;
          });
          return;
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          children: List.generate(artists.length, (index) {
            final artist = artists[index];
            return ArtistCard(
              artist: artist,
              selectionMode: selectionMode,
              isSelect: selectedArtists.contains(artist),
              onSelection: () => onArtistSelection(artist),
              onPress: () {},
            );
          }),
        ),
      ),
    );
  }

  void onArtistSelection(Artist artist) {
    if (!selectionMode) {
      selectedArtists.clear();
      setState(() {
        selectionMode = true;
      });
    }

    setState(() {
      if (selectedArtists.contains(artist)) {
        selectedArtists.remove(artist);
      } else {
        selectedArtists.add(artist);
      }
      if (selectedArtists.isEmpty) {
        selectionMode = false;
      }
    });
  }
}
