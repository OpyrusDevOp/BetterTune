class Song {
  final String id;
  final String name;
  final String serverId;
  final String artist;
  final String album;
  final String albumId;
  final int runTimeTicks;
  final bool isFavorite;
  final Map<String, String> imageTags;
  final String? container;

  Song({
    required this.id,
    required this.name,
    required this.serverId,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.runTimeTicks,
    required this.isFavorite,
    required this.imageTags,
    this.container,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['Id'],
      name: json['Name'],
      serverId: json['ServerId'],
      artist: (json['Artists'] as List?)?.firstOrNull ?? 'Unknown Artist',
      album: json['Album'] ?? 'Unknown Album',
      albumId: json['AlbumId'] ?? '',
      runTimeTicks: json['RunTimeTicks'] ?? 0,
      isFavorite: json['UserData']?['IsFavorite'] ?? false,
      imageTags: Map<String, String>.from(json['ImageTags'] ?? {}),
      container: json['Container'],
    );
  }

  Duration get duration => Duration(microseconds: runTimeTicks ~/ 10);
}
