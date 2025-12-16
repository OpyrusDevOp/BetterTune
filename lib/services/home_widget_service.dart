import 'package:home_widget/home_widget.dart';
import 'package:bettertune/services/audio_player_service.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/models/song.dart';
import 'dart:convert';

class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  static const String androidWidgetName = 'BetterTuneWidgetProvider';
  static const String playPauseAction = 'com.example.bettertune.PLAY_PAUSE';
  static const String nextAction = 'com.example.bettertune.NEXT';
  static const String previousAction = 'com.example.bettertune.PREVIOUS';
  static const String openAppAction = 'com.example.bettertune.OPEN_APP';

  Future<void> initialize() async {
    // Register callbacks for widget actions
    HomeWidget.setAppGroupId('group.com.example.bettertune');

    // Register background callback
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    // Listen to player state changes and update widget
    AudioPlayerService().playerStateStream.listen((_) {
      updateWidget();
    });

    AudioPlayerService().currentSongStream.listen((_) {
      updateWidget();
    });
  }

  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'widget_action') {
      final action = uri?.queryParameters['action'];
      await HomeWidgetService().handleWidgetAction(action);
    }
  }

  Future<void> updateWidget() async {
    final playerService = AudioPlayerService();
    final currentSong = playerService.currentSong;
    final isPlaying = playerService.isPlaying;

    if (currentSong != null) {
      // Update widget data
      await HomeWidget.saveWidgetData<String>('song_title', currentSong.name);
      await HomeWidget.saveWidgetData<String>(
        'song_artist',
        currentSong.artist,
      );
      await HomeWidget.saveWidgetData<String>('song_album', currentSong.album);
      await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);

      // Get album art URL
      final imageUrl = ApiClient().getImageUrl(
        currentSong.id,
        width: 300,
        height: 300,
      );
      await HomeWidget.saveWidgetData<String>('album_art_url', imageUrl);

      // Get queue data
      final queue = await playerService.queueStream.first;
      final queueJson = jsonEncode(
        queue
            .map(
              (song) => {
                'id': song.id,
                'title': song.name,
                'artist': song.artist,
              },
            )
            .toList(),
      );

      await HomeWidget.saveWidgetData<String>('queue_data', queueJson);
      await HomeWidget.saveWidgetData<int>('queue_length', queue.length);
    } else {
      // No song playing
      await HomeWidget.saveWidgetData<String>('song_title', 'No song playing');
      await HomeWidget.saveWidgetData<String>('song_artist', '');
      await HomeWidget.saveWidgetData<String>('song_album', '');
      await HomeWidget.saveWidgetData<bool>('is_playing', false);
      await HomeWidget.saveWidgetData<int>('queue_length', 0);
    }

    // Update the widget
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  Future<void> handleWidgetAction(String? action) async {
    if (action == null) return;

    final playerService = AudioPlayerService();

    switch (action) {
      case playPauseAction:
        final isPlaying = playerService.isPlaying;
        if (isPlaying) {
          await playerService.pause();
        } else {
          await playerService.play();
        }
        break;
      case nextAction:
        await playerService.skipToNext();
        break;
      case previousAction:
        await playerService.skipToPrevious();
        break;
    }

    await updateWidget();
  }
}
