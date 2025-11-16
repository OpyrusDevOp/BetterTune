import 'package:bettertune/components/album_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final albums = [
    (
      imageUrl: 'assets/monsters_go_bump.jpg',
      title: 'Monsters Go Bump',
      artist: 'ERIKA RECINOS',
      color: Colors.orange.shade900,
    ),
    (
      imageUrl: 'assets/moment_apart.jpg',
      title: 'Moment Apart',
      artist: 'ODESZA',
      color: Colors.blue.shade900,
    ),
    (
      imageUrl: 'assets/moment_apart.jpg',
      title: 'Moment Apart',
      artist: 'ODESZA',
      color: Colors.blue.shade900,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommended for you section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Recommended for you',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        children: createAlbumCards(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // My Playlist section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'My Playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          AlbumCard(
                            imageUrl: 'assets/believer.jpg',
                            title: 'Believer',
                            artist: '',
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 16),
                          AlbumCard(
                            imageUrl: 'assets/shortwave.jpg',
                            title: 'Shortwave',
                            artist: '',
                            color: Colors.red.shade900,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for player
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AlbumCard> createAlbumCards() {
    List<AlbumCard> albumCards = [];

    albums.forEach((album) {
      albumCards.add(
        AlbumCard(
          imageUrl: album.imageUrl,
          title: album.title,
          artist: album.artist,
          color: album.color,
        ),
      );
    });

    return albumCards;
  }
}
