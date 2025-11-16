import 'package:flutter/material.dart';
import '../components/artist_card.dart';
import '../datas/artist.dart';

class ArtistsScreen extends StatelessWidget {
  ArtistsScreen({super.key});

  final List<Artist> artists = [
    Artist(name: 'Imagine Dragons', albumCount: 5, color: Colors.purple),
    Artist(name: 'ODESZA', albumCount: 4, color: Colors.blue),
    Artist(name: 'Erika Recinos', albumCount: 2, color: Colors.orange),
    Artist(name: 'HVÖNNÅ', albumCount: 3, color: Colors.teal),
    Artist(name: 'Twin Peaks', albumCount: 4, color: Colors.red),
    Artist(name: 'Arctic Monkeys', albumCount: 6, color: Colors.indigo),
    Artist(name: 'The Weeknd', albumCount: 5, color: Colors.pink),
    Artist(name: 'Tame Impala', albumCount: 4, color: Colors.deepPurple),
    Artist(name: 'Coldplay', albumCount: 9, color: Colors.yellow),
    Artist(name: 'Radiohead', albumCount: 9, color: Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Artists Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${artists.length} artists',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Artists Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ArtistCard(artist: artist);
              },
            ),
          ),
        ],
      ),
    );
  }
}
