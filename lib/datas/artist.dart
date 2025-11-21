class Artist {
  final String id;
  final String name;
  final String serverId;
  final Map<String, String> imageTags;

  Artist({
    required this.id,
    required this.name,
    required this.serverId,
    required this.imageTags,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['Id'],
      name: json['Name'],
      serverId: json['ServerId'] ?? '',
      imageTags: Map<String, String>.from(json['ImageTags'] ?? {}),
    );
  }
}
