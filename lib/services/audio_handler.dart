import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.setVolume(1);
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  int? _queueIndex;

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _queueIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    mediaItem = mediaItem.copyWith(duration: mediaItem.duration);

    // Update current media item
    this.mediaItem.add(mediaItem);

    // Update queue index
    final currentQueue = queue.value;
    final index = currentQueue.indexOf(mediaItem);
    if (index != -1) {
      _queueIndex = index;
    }

    await _player.setUrl(mediaItem.extras!['url'] as String);
    await _player.play();
  }

  // Queue management
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    this.queue.add(queue);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final currentQueue = queue.value;
    if (index < 0 || index >= currentQueue.length) return;
    await playMediaItem(currentQueue[index]);
  }

  @override
  Future<void> skipToNext() async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    final currentIndex = _queueIndex ?? currentQueue.indexOf(mediaItem.value!);
    if (currentIndex < currentQueue.length - 1) {
      await playMediaItem(currentQueue[currentIndex + 1]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      final currentIndex =
          _queueIndex ?? currentQueue.indexOf(mediaItem.value!);
      if (currentIndex > 0) {
        await playMediaItem(currentQueue[currentIndex - 1]);
      }
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'playNext') {
      if (extras != null) {
        final item = MediaItem(
          id: extras['id'],
          title: extras['title'],
          artist: extras['artist'],
          album: extras['album'],
          duration: extras['duration'] != null
              ? Duration(microseconds: extras['duration'])
              : null,
          artUri: extras['artUri'] != null ? Uri.parse(extras['artUri']) : null,
          extras: Map<String, dynamic>.from(extras['extras'] ?? {}),
        );

        final currentQueue = queue.value;
        final currentIndex =
            _queueIndex ??
            (mediaItem.value != null
                ? currentQueue.indexOf(mediaItem.value!)
                : -1);

        final newQueue = List<MediaItem>.from(currentQueue);
        if (currentIndex != -1 && currentIndex < newQueue.length - 1) {
          newQueue.insert(currentIndex + 1, item);
        } else {
          newQueue.add(item);
        }
        queue.add(newQueue);
      }
    }
    super.customAction(name, extras);
  }

  // Custom actions for shuffle/repeat if needed
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // Implement shuffle logic here or in PlayerService
    // For now just notify state
    super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Implement repeat logic
    super.setRepeatMode(repeatMode);
  }
}
