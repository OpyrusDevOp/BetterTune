import 'dart:async';
import 'package:bettertune/models/song.dart';
import 'package:bettertune/services/songs_service.dart';
import 'package:bettertune/services/api_client.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

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
  final _currentSongController = StreamController<Song?>.broadcast();
  Song? _currentSong;

  // Getters
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Song? get currentSong => _currentSong;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player completion to handle auto-advance (future task)
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // TODO: Queue logic
      }
    });
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    _currentSongController.add(song);

    // Get URL
    final url = SongsService().getStreamUrl(song.id);
    if (url.isEmpty) {
      debugPrint("Error: Stream URL is empty for ${song.name}");
      return;
    }

    try {
      // Use AudioSource.uri to include headers
      final headers = ApiClient().authHeaders;
      final source = AudioSource.uri(
        Uri.parse(url),
        headers: headers,
        tag: song, // Optional: useful for metadata later
      );

      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
    _currentSongController.close();
  }
}
