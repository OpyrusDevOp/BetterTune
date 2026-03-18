// Web stub — mirrors the just_audio_background API so all casts and
// method calls in audio_player_service.dart compile and work on web.
// JustAudioBackground.init() becomes a no-op; MediaItem is a plain value object.

class JustAudioBackground {
  static Future<void> init({
    required String androidNotificationChannelId,
    required String androidNotificationChannelName,
    bool androidNotificationOngoing = false,
    bool androidStopForegroundOnPause = false,
    String? androidNotificationIcon,
    bool androidShowNotificationBadge = false,
    bool androidNotificationClickStartsActivity = true,
  }) async {}
}

class MediaItem {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final Uri? artUri;
  final Map<String, dynamic>? extras;

  const MediaItem({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.artUri,
    this.extras,
  });
}
