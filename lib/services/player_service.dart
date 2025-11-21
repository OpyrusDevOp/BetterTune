import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../datas/song.dart';
import 'storage_service.dart';

class PlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  // Let's stick to simple repeat all for now as per request "repeat, single repeat".
  // Actually request says "repeat, single repeat".
  LoopMode _loopMode = LoopMode.off;

  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;

  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  PlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        _onSongFinished();
      }
    });
  }

  Future<void> playSong(Song song, {List<Song>? newQueue}) async {
    if (newQueue != null) {
      _queue = List.from(newQueue);
    } else if (!_queue.contains(song)) {
      // If playing a song not in queue, add it to queue or replace queue?
      // Usually "Play" on a song in a list replaces the queue with that list starting from that song.
      // For now, let's assume if newQueue is not provided, we just play this song (clear queue or add to end?)
      // Let's clear queue and add this song for simplicity if no queue context is given.
      _queue = [song];
    }

    _currentIndex = _queue.indexOf(song);
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final song = _queue[_currentIndex];
    final serverUrl = await StorageService.getServerUrl();

    if (serverUrl == null) {
      print("Error: Server URL is null");
      return;
    }

    final url = '$serverUrl/Audio/${song.id}/stream?static=true&Container=mp3';

    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      _currentIndex = Random().nextInt(_queue.length);
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else {
        // End of queue
        if (_loopMode == LoopMode.all) {
          _currentIndex = 0;
        } else {
          return; // Stop or do nothing
        }
      }
    }
    await _playCurrent();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        // Start of queue
        if (_loopMode == LoopMode.all) {
          _currentIndex = _queue.length - 1;
        }
      }
      await _playCurrent();
    }
  }

  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  void playNext(Song song) {
    if (_queue.isEmpty) {
      addToQueue(song);
    } else {
      _queue.insert(_currentIndex + 1, song);
      notifyListeners();
    }
  }

  void addToQueueNext(Song song) => playNext(song);

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    // just_audio has setShuffleModeEnabled but we are managing queue manually for now to keep it simple with our Song model.
    // Or we can use ConcatenatingAudioSource.
    // For now, manual queue management.
    notifyListeners();
  }

  void toggleRepeat() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }

    // Sync with just_audio
    _audioPlayer.setLoopMode(_loopMode);
    notifyListeners();
  }

  void _onSongFinished() {
    if (_loopMode == LoopMode.one) {
      // just_audio handles loop one automatically if setLoopMode is used?
      // Yes, but we need to be careful if we are manually setting URL.
      // If we use setUrl, just_audio might not loop automatically if we don't use a playlist source.
      // Let's handle it manually for now to be safe with setUrl.
      _playCurrent();
    } else {
      next();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
