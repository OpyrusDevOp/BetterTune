import 'package:home_widget/home_widget.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/models/song.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  static const String androidWidgetName = 'BetterTuneWidgetProvider';
  static const String playPauseAction = 'com.example.bettertune.PLAY_PAUSE';
  static const String nextAction = 'com.example.bettertune.NEXT';
  static const String previousAction = 'com.example.bettertune.PREVIOUS';
  static const String openAppAction = 'com.example.bettertune.OPEN_APP';
  static const String shuffleAction = 'com.example.bettertune.SHUFFLE';
  static const String repeatAction = 'com.example.bettertune.REPEAT';
  static const String playQueueItemAction =
      'com.example.bettertune.PLAY_QUEUE_ITEM';

  Future<void> initialize() async {
    HomeWidget.setAppGroupId('group.com.example.bettertune');
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    // Handle launch from widget
    final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      await backgroundCallback(initialUri);
    }

    AudioPlayerService().playerStateStream.listen((_) => updateWidget());
    AudioPlayerService().currentSongStream.listen((_) => updateWidget());
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'widget_action') {
      final action = uri?.queryParameters['action'];
      final songId = uri?.queryParameters['songId'];
      await HomeWidgetService().handleWidgetAction(action, songId: songId);
    }
  }

  Future<void> updateWidget() async {
    final playerService = AudioPlayerService();
    final currentSong = playerService.currentSong;
    final isPlaying = playerService.isPlaying;

    if (currentSong != null) {
      await HomeWidget.saveWidgetData<String>('song_title', currentSong.name);
      await HomeWidget.saveWidgetData<String>('song_artist', currentSong.artist);
      await HomeWidget.saveWidgetData<String>('song_album', currentSong.album);
      await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);
      await HomeWidget.saveWidgetData<String>('current_song_id', currentSong.id);

      final imageUrl = ApiClient().getImageUrl(currentSong.id, width: 300, height: 300);
      final imagePath = await _cacheAlbumArt(imageUrl, currentSong.id);
      await HomeWidget.saveWidgetData<String>('album_art_path', imagePath);

      final queue = await playerService.queueStream.first;
      final queueJson = jsonEncode(
        queue.map((s) => {'id': s.id, 'title': s.name, 'artist': s.artist}).toList(),
      );
      await HomeWidget.saveWidgetData<String>('queue_data', queueJson);
      await HomeWidget.saveWidgetData<int>('queue_length', queue.length);
    } else {
      await HomeWidget.saveWidgetData<String>('song_title', 'No song playing');
      await HomeWidget.saveWidgetData<String>('song_artist', '');
      await HomeWidget.saveWidgetData<String>('song_album', '');
      await HomeWidget.saveWidgetData<bool>('is_playing', false);
      await HomeWidget.saveWidgetData<String>('current_song_id', '');
      await HomeWidget.saveWidgetData<int>('queue_length', 0);
      await HomeWidget.saveWidgetData<String>('album_art_path', null);
    }

    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  Future<String?> _cacheAlbumArt(String url, String songId) async {
    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final headers = ApiClient().authHeaders;
      headers.forEach((key, value) => request.headers.add(key, value));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final directory = await getApplicationSupportDirectory();
        final file = File('${directory.path}/widget_cover_$songId.jpg');
        await response.pipe(file.openWrite());
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> handleWidgetAction(String? action, {String? songId}) async {
    if (action == null) return;
    final playerService = AudioPlayerService();

    switch (action) {
      case playPauseAction:
        playerService.isPlaying ? await playerService.pause() : await playerService.play();
        break;
      case nextAction:
        await playerService.skipToNext();
        break;
      case previousAction:
        await playerService.skipToPrevious();
        break;
      case shuffleAction:
        await playerService.toggleShuffle();
        break;
      case repeatAction:
        await playerService.toggleRepeat();
        break;
      case playQueueItemAction:
        if (songId != null) {
          final queue = await playerService.queueStream.first;
          final song = queue.firstWhere(
            (s) => s.id == songId,
            orElse: () => queue.first,
          );
          if (song.id == songId) await playerService.jumpToSong(song);
        }
        break;
    }

    await updateWidget();
  }
}
