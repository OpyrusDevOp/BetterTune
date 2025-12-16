import 'dart:async';
import 'package:bettertune/services/home_widget_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:bettertune/services/songs_service.dart'; // For Stream URL
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  // State
  // We derive current song from _player.currentIndex and the playlist sequence
  // Stream for player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get shuffleModeEnabledStream => _player.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  // Synchoronous State
  bool get isPlaying => _player.playing;

  // Stream for the current song based on index changes
  Stream<Song?> get currentSongStream =>
      _player.currentIndexStream.map((index) {
        final sequence = _player.sequence;
        if (index != null && sequence != null && index < sequence.length) {
          final source = sequence[index] as UriAudioSource;
          return _mediaItemToSong(source.tag as MediaItem);
        }
        return null;
      });

  Song? get currentSong {
    final index = _player.currentIndex;
    final sequence = _player.sequence;
    if (index != null && sequence != null && index < sequence.length) {
      final source = sequence[index] as UriAudioSource;
      return _mediaItemToSong(source.tag as MediaItem);
    }
    return null;
  }

  // Stream for the queue (taking shuffle into account)
  // This combines sequenceStream and shuffleModeEnabledStream to give the effective list
  Stream<List<Song>> get queueStream => _player.sequenceStateStream.map((
    state,
  ) {
    if (state == null) return [];
    final sequence = state.effectiveSequence;
    return sequence
        .map(
          (source) =>
              _mediaItemToSong((source as UriAudioSource).tag as MediaItem),
        )
        .toList();
  });

  Song _mediaItemToSong(MediaItem item) {
    // We store extra data in extras if needed, or map strictly from standard fields
    return Song(
      id: item.id,
      name: item.title,
      artist: item.artist ?? "Unknown",
      album: item.album ?? "Unknown",
      // We can store original song object or other props in extras if needed
      isFavorite: item.extras?['isFavorite'] ?? false,
    );
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  // --- Queue Management ---

  Future<void> setQueue(List<Song> songs, {int initialIndex = 0}) async {
    try {
      final headers = ApiClient().authHeaders;

      final children = songs.map((song) {
        final url = SongsService().getStreamUrl(song.id);
        final imageUrl = ApiClient().getImageUrl(
          song.id,
          width: 300,
          height: 300,
        );

        return AudioSource.uri(
          Uri.parse(url),
          headers: headers,
          tag: MediaItem(
            id: song.id,
            title: song.name,
            artist: song.artist,
            album: song.album,
            artUri: Uri.parse(imageUrl),
            extras: {'isFavorite': song.isFavorite},
          ),
        );
      }).toList();

      await _player.setAudioSource(
        ConcatenatingAudioSource(children: children),
        initialIndex: initialIndex,
      );
      await _player.play();
      await HomeWidgetService().updateWidget();
    } catch (e) {
      debugPrint("Error setting queue: $e");
    }
  }

  Future<void> addToQueue(Song song) async {
    await addToQueueList([song]);
    await HomeWidgetService().updateWidget();
  }

  Future<void> addToQueueList(List<Song> songs) async {
    try {
      final headers = ApiClient().authHeaders;
      final List<AudioSource> newSources = [];

      for (var song in songs) {
        final url = SongsService().getStreamUrl(song.id);
        final imageUrl = ApiClient().getImageUrl(
          song.id,
          width: 300,
          height: 300,
        );

        newSources.add(
          AudioSource.uri(
            Uri.parse(url),
            headers: headers,
            tag: MediaItem(
              id: song.id,
              title: song.name,
              artist: song.artist,
              album: song.album,
              artUri: Uri.parse(imageUrl),
              extras: {'isFavorite': song.isFavorite},
            ),
          ),
        );
      }

      final currentSource = _player.audioSource;
      if (currentSource is ConcatenatingAudioSource) {
        await currentSource.addAll(newSources);
      } else {
        // If current source is not a playlist (or null), create one.
        final List<AudioSource> newQueue = [];
        if (currentSource != null) {
          newQueue.add(currentSource);
        }
        newQueue.addAll(newSources);

        await _player.setAudioSource(
          ConcatenatingAudioSource(children: newQueue),
        );
      }
      await HomeWidgetService().updateWidget();
    } catch (e) {
      debugPrint("Error adding to queue: $e");
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final currentSource = _player.audioSource;
    if (currentSource is ConcatenatingAudioSource) {
      await currentSource.move(oldIndex, newIndex);
    }
    await HomeWidgetService().updateWidget();
  }

  // --- Playback Controls ---

  // Retaining simple playSong for backward compatibility or single plays (creates a queue of 1)
  Future<void> playSong(Song song) async {
    await setQueue([song]);
    await HomeWidgetService().updateWidget();
  }

  // Jumps to a specific song in the current queue if it exists
  Future<void> jumpToSong(Song song) async {
    final sequence = _player.sequence;
    if (sequence != null) {
      for (int i = 0; i < sequence.length; i++) {
        final source = sequence[i] as UriAudioSource;
        final tag = source.tag as MediaItem;
        if (tag.id == song.id) {
          await _player.seek(Duration.zero, index: i);
          return;
        }
      }
    }
    await HomeWidgetService().updateWidget();
  }

  Future<void> play() async {
    await _player.play();
    await HomeWidgetService().updateWidget();
  }

  Future<void> pause() async {
    await _player.pause();
    await HomeWidgetService().updateWidget();
  }

  Future<void> stop() async {
    await _player.stop();
    await HomeWidgetService().updateWidget();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    await HomeWidgetService().updateWidget();
  }

  // --- Navigation & Modes ---

  Future<void> skipToNext() async {
    final sequence = _player.sequence;
    final currentIndex = _player.currentIndex;

    if (sequence != null && currentIndex != null) {
      if (currentIndex < sequence.length - 1) {
        // Go to next song
        await _player.seek(Duration.zero, index: currentIndex + 1);
      } else {
        // At the last song, wrap around to first
        await _player.seek(Duration.zero, index: 0);
      }
    }
  }

  Future<void> skipToPrevious() async {
    // If playing for > 3s, restart song
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
      } else {
        // "If current song is first... restart it"
        await _player.seek(Duration.zero);
      }
    }
  }

  Future<void> toggleShuffle() async {
    final enable = !(_player.shuffleModeEnabled);
    await setShuffleMode(enable);
  }

  Future<void> setShuffleMode(bool enable) async {
    if (enable) {
      await _player.setShuffleModeEnabled(true);
    } else {
      await _player.setShuffleModeEnabled(false);
    }
  }

  Future<void> toggleRepeat() async {
    // Cycle: Off -> All -> One
    switch (_player.loopMode) {
      case LoopMode.off:
        await _player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await _player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
