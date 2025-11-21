import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

import '../datas/song.dart';
import 'storage_service.dart';

import '../services/jellyfin_service.dart';

class PlayerService extends ChangeNotifier {
  final AudioHandler _audioHandler;

  PlayerService(this._audioHandler) {
    _audioHandler.playbackState.listen((state) {
      notifyListeners();
    });
    _audioHandler.mediaItem.listen((item) {
      notifyListeners();
    });
    _audioHandler.queue.listen((queue) {
      notifyListeners();
    });
  }

  List<Song> get queue {
    // We need to map MediaItems back to Songs if possible, or store Songs separately.
    // Storing separately in PlayerService might be easier for now to keep existing logic,
    // but AudioHandler is the source of truth for the queue.
    // Let's try to reconstruct Song from MediaItem extras.
    return _audioHandler.queue.value.map((item) {
      return Song(
        id: item.id,
        name: item.title,
        serverId: item.extras?['serverId'] ?? '',
        artist: item.artist ?? '',
        artistId: item.extras?['artistId'],
        album: item.album ?? '',
        albumId: item.extras?['albumId'] ?? '',
        runTimeTicks: (item.duration?.inMicroseconds ?? 0) * 10,
        isFavorite: item.extras?['isFavorite'] ?? false,
        imageTags: Map<String, String>.from(item.extras?['imageTags'] ?? {}),
      );
    }).toList();
  }

  // Helper to get current song from queue based on index
  Song? get currentSong {
    final index = currentIndex;
    final q = queue;
    if (index >= 0 && index < q.length) {
      return q[index];
    }
    return null;
  }

  int get currentIndex => _audioHandler.playbackState.value.queueIndex ?? -1;
  bool get isPlaying => _audioHandler.playbackState.value.playing;
  bool get isShuffle =>
      _audioHandler.playbackState.value.shuffleMode ==
      AudioServiceShuffleMode.all;
  LoopMode get loopMode {
    switch (_audioHandler.playbackState.value.repeatMode) {
      case AudioServiceRepeatMode.none:
        return LoopMode.off;
      case AudioServiceRepeatMode.one:
        return LoopMode.one;
      case AudioServiceRepeatMode.all:
        return LoopMode.all;
      case AudioServiceRepeatMode.group:
        return LoopMode.all; // Map group to all for now
    }
  }

  Duration get position => _audioHandler.playbackState.value.position;
  Duration get duration =>
      _audioHandler.mediaItem.value?.duration ?? Duration.zero;

  Stream<Duration> get positionStream => AudioService.position;
  Stream<Duration?> get durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration);
  Stream<PlayerState> get playerStateStream => _audioHandler.playbackState.map((
    state,
  ) {
    // Map PlaybackState to just_audio PlayerState if needed by UI,
    // or update UI to use PlaybackState directly.
    // For minimal UI changes, let's map it.
    final processingState = {
      AudioProcessingState.idle: ProcessingState.idle,
      AudioProcessingState.loading: ProcessingState.loading,
      AudioProcessingState.buffering: ProcessingState.buffering,
      AudioProcessingState.ready: ProcessingState.ready,
      AudioProcessingState.completed: ProcessingState.completed,
      AudioProcessingState.error: ProcessingState.idle, // Map error to idle?
    }[state.processingState]!;
    return PlayerState(state.playing, processingState);
  });

  Future<void> playSong(Song song, {List<Song>? newQueue}) async {
    final serverUrl = await StorageService.getServerUrl();
    if (serverUrl == null) return;

    if (newQueue != null) {
      final mediaItems = newQueue.map((s) => s.toMediaItem(serverUrl)).toList();
      await _audioHandler.updateQueue(mediaItems);
      // Find index of song in new queue
      final index = newQueue.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        await _audioHandler.skipToQueueItem(index);
      }
      await _audioHandler.play();
    } else {
      // Just play this song, maybe clear queue?
      // Existing logic was: clear queue and add this song.
      final mediaItem = song.toMediaItem(serverUrl);
      await _audioHandler.updateQueue([mediaItem]);
      await _audioHandler.play();
    }
  }

  Future<void> playSongs(List<Song> songs, {bool shuffle = false}) async {
    final serverUrl = await StorageService.getServerUrl();
    if (serverUrl == null || songs.isEmpty) return;

    final mediaItems = songs.map((s) => s.toMediaItem(serverUrl)).toList();

    if (shuffle) {
      mediaItems.shuffle();
    }

    await _audioHandler.updateQueue(mediaItems);
    await _audioHandler.skipToQueueItem(0);
    await _audioHandler.play();
  }

  Future<void> play() => _audioHandler.play();
  Future<void> pause() => _audioHandler.pause();
  Future<void> seek(Duration position) => _audioHandler.seek(position);
  Future<void> stop() => _audioHandler.stop();
  Future<void> next() => _audioHandler.skipToNext();
  Future<void> previous() => _audioHandler.skipToPrevious();

  Future<void> addToQueue(Song song) async {
    final serverUrl = await StorageService.getServerUrl();
    if (serverUrl == null) return;

    if (queue.isEmpty) {
      await playSong(song);
    } else {
      await _audioHandler.addQueueItem(song.toMediaItem(serverUrl));
    }
  }

  Future<void> addSongsToQueue(List<Song> songs) async {
    final serverUrl = await StorageService.getServerUrl();
    if (serverUrl == null) return;

    if (queue.isEmpty) {
      await playSongs(songs);
    } else {
      final mediaItems = songs.map((s) => s.toMediaItem(serverUrl)).toList();
      await _audioHandler.addQueueItems(mediaItems);
    }
  }

  Future<void> playNext(Song song) async {
    final serverUrl = await StorageService.getServerUrl();
    if (serverUrl == null) return;

    if (queue.isEmpty) {
      await playSong(song);
      return;
    }

    final item = song.toMediaItem(serverUrl);
    await _audioHandler.customAction('playNext', {
      'id': item.id,
      'title': item.title,
      'artist': item.artist,
      'album': item.album,
      'duration': item.duration?.inMicroseconds,
      'artUri': item.artUri?.toString(),
      'extras': item.extras,
    });
  }

  void addToQueueNext(Song song) => playNext(song);

  void toggleShuffle() {
    final mode = isShuffle
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all;
    _audioHandler.setShuffleMode(mode);
  }

  void toggleRepeat() {
    AudioServiceRepeatMode mode;
    switch (loopMode) {
      case LoopMode.off:
        mode = AudioServiceRepeatMode.all;
        break;
      case LoopMode.all:
        mode = AudioServiceRepeatMode.one;
        break;
      case LoopMode.one:
        mode = AudioServiceRepeatMode.none;
        break;
    }
    _audioHandler.setRepeatMode(mode);
  }

  Future<void> toggleFavorite() async {
    final song = currentSong;
    if (song == null) return;

    final newIsFavorite = !song.isFavorite;

    // Optimistic update
    final currentItem = _audioHandler.mediaItem.value;
    if (currentItem != null) {
      final newExtras = Map<String, dynamic>.from(currentItem.extras ?? {});
      newExtras['isFavorite'] = newIsFavorite;
      final newItem = currentItem.copyWith(extras: newExtras);
      await _audioHandler.updateMediaItem(newItem);

      // Also update in queue if needed (AudioHandler might not sync queue automatically)
      // For now, updating current item is enough for UI
    }

    final success = await JellyfinService.markFavorite(song.id, newIsFavorite);

    if (!success) {
      // Revert if failed
      if (currentItem != null) {
        await _audioHandler.updateMediaItem(currentItem);
      }
    }
  }

  @override
  void dispose() {
    // _audioHandler.stop(); // Don't stop on dispose, let it run in background
    super.dispose();
  }
}
