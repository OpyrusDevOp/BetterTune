import 'package:audio_service/audio_service.dart';

class Song {
  final String id;
  final String name;
  final String serverId;
  final String artist;
  final String? artistId;
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
    this.artistId,
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
      artistId: (json['ArtistIds'] as List?)?.firstOrNull,
      album: json['Album'] ?? 'Unknown Album',
      albumId: json['AlbumId'] ?? '',
      runTimeTicks: json['RunTimeTicks'] ?? 0,
      isFavorite: json['UserData']?['IsFavorite'] ?? false,
      imageTags: Map<String, String>.from(json['ImageTags'] ?? {}),
      container: json['Container'],
    );
  }

  Duration get duration => Duration(microseconds: runTimeTicks ~/ 10);

  MediaItem toMediaItem(String serverUrl) {
    String? imageUrl;
    final imageTag = imageTags['Primary'];
    if (imageTag != null) {
      imageUrl = '$serverUrl/Items/$id/Images/Primary?tag=$imageTag&quality=90';
    }

    return MediaItem(
      id: id,
      title: name,
      artist: artist,
      album: album,
      duration: duration,
      artUri: imageUrl != null ? Uri.parse(imageUrl) : null,
      extras: {
        'serverId': serverId,
        'url': '$serverUrl/Audio/$id/stream?static=true&Container=mp3',
        'artistId': artistId,
        'albumId': albumId,
        'imageTags': imageTags,
        'isFavorite': isFavorite,
      },
    );
  }

  Song copyWith({
    String? id,
    String? name,
    String? serverId,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    int? runTimeTicks,
    bool? isFavorite,
    Map<String, String>? imageTags,
    String? container,
  }) {
    return Song(
      id: id ?? this.id,
      name: name ?? this.name,
      serverId: serverId ?? this.serverId,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      runTimeTicks: runTimeTicks ?? this.runTimeTicks,
      isFavorite: isFavorite ?? this.isFavorite,
      imageTags: imageTags ?? this.imageTags,
      container: container ?? this.container,
    );
  }
}
