class Album {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String serverId;
  final int year;
  final Map<String, String> imageTags;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.serverId,
    required this.year,
    required this.imageTags,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['Id'],
      title: json['Name'],
      artist: json['AlbumArtist'] ?? 'Unknown Artist',
      artistId: (json['ArtistItems'] as List?)?.firstOrNull?['Id'] ?? '',
      serverId: json['ServerId'] ?? '',
      year: json['ProductionYear'] ?? 0,
      imageTags: Map<String, String>.from(json['ImageTags'] ?? {}),
    );
  }
}
