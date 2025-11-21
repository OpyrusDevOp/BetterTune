import 'package:flutter/material.dart';
import '../datas/artist.dart';
import '../services/storage_service.dart';
import '../screens/artist_detail_screen.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailScreen(artist: artist),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Artist Image (circular)
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipOval(
                child: FutureBuilder<String?>(
                  future: StorageService.getServerUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final serverUrl = snapshot.data!;
                      final imageTag = artist.imageTags['Primary'];

                      if (imageTag != null) {
                        final imageUrl =
                            '$serverUrl/Items/${artist.id}/Images/Primary?tag=$imageTag&quality=90';
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white54,
                              ),
                            );
                          },
                        );
                      }
                    }
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Artist Name
          Text(
            artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
