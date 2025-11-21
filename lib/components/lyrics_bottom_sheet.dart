import 'package:flutter/material.dart';
import '../services/jellyfin_service.dart';

class LyricsBottomSheet extends StatefulWidget {
  final String songId;
  final String songTitle;

  const LyricsBottomSheet({
    super.key,
    required this.songId,
    required this.songTitle,
  });

  @override
  State<LyricsBottomSheet> createState() => _LyricsBottomSheetState();
}

class _LyricsBottomSheetState extends State<LyricsBottomSheet> {
  Future<String?>? _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = JellyfinService.getLyrics(widget.songId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lyrics: ${widget.songTitle}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),

          // Content
          Expanded(
            child: FutureBuilder<String?>(
              future: _lyricsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading lyrics',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final lyrics = snapshot.data;
                if (lyrics == null || lyrics.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lyrics,
                          size: 48,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lyrics found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    lyrics,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
