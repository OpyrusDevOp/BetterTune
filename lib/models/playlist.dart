class Playlist {
  final String id;
  final String name;
  final int songCount;
  final String? coverUrl;

  const Playlist({
    required this.id,
    required this.name,
    this.songCount = 0,
    this.coverUrl,
  });
}
