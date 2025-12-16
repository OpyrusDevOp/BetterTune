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
      // Update widget data
      await HomeWidget.saveWidgetData<String>('song_title', currentSong.name);
      await HomeWidget.saveWidgetData<String>(
        'song_artist',
        currentSong.artist,
      );
      await HomeWidget.saveWidgetData<String>('song_album', currentSong.album);
      await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);
      await HomeWidget.saveWidgetData<String>(
        'current_song_id',
        currentSong.id,
      );

      // Get and cache album art
      final imageUrl = ApiClient().getImageUrl(
        currentSong.id,
        width: 300,
        height: 300,
      );

      final imagePath = await _cacheAlbumArt(imageUrl, currentSong.id);
      if (imagePath != null) {
        await HomeWidget.saveWidgetData<String>('album_art_path', imagePath);
      } else {
        await HomeWidget.saveWidgetData<String>('album_art_path', null);
      }

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
      await HomeWidget.saveWidgetData<String>('current_song_id', '');
      await HomeWidget.saveWidgetData<int>('queue_length', 0);
      await HomeWidget.saveWidgetData<String>('album_art_path', null);
    }

    // Update the widget
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  Future<String?> _cacheAlbumArt(String url, String songId) async {
    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      // Add auth header if needed, but ApiClient().getImageUrl might include token in query or relies on cookie?
      // BetterTune ApiClient typically puts token in header.
      // But getImageUrl likely returns a public URL or one needing headers.
      // Looking at audio_player_service, it sets headers for AudioSource.
      // So we likely need headers here too.
      final headers = ApiClient().authHeaders;
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final directory = await getApplicationSupportDirectory();
        final file = File('${directory.path}/widget_cover_$songId.jpg');
        await response.pipe(file.openWrite());
        return file.path;
      }
      return null;
    } catch (e) {
      print('Error caching album art: $e');
      return null;
    }
  }

  Future<void> handleWidgetAction(String? action, {String? songId}) async {
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
      case shuffleAction:
        await playerService.toggleShuffle();
        break;
      case repeatAction:
        await playerService.toggleRepeat();
        break;
      case playQueueItemAction:
        if (songId != null) {
          // Find song in queue and play it
          // We need a way to play by ID from queue.
          // Implement simple lookup in AudioPlayerService or just iterate.
          // playerService.jumpToSongById(songId); // hypothetical
          // Current `jumpToSong` takes a Song object.
          // I'll implement a helper here.
          final queue = await playerService.queueStream.first;
          final song = queue.firstWhere(
            (s) => s.id == songId,
            orElse: () => queue.first /* fallback? */,
          );
          if (song.id == songId) {
            await playerService.jumpToSong(song);
          }
        }
        break;
    }

    await updateWidget();
  }
}
