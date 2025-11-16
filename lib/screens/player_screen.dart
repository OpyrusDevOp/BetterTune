import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  double _currentPosition = 50.0; // in seconds
  final double _totalDuration = 240.0; // 4 minutes in seconds
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isRepeat = false;
  bool _isShuffle = false;

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, size: 40),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Now Playing'),
      ),
      backgroundColor: const Color(0xFF1A2332),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top Bar
              Spacer(),

              const SizedBox(height: 20),
              SizedBox(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.brown.shade900,
                            Colors.orange.shade700,
                            Colors.yellow.shade600,
                            Colors.cyan.shade400,
                            Colors.blue.shade900,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'IMAGINE DRAGONS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 120),
                            const Text(
                              'BELIEVER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Song Title and Artist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Believer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IMAGINE DRAGON',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Additional Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_outlined,
                      color: Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: _isRepeat
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRepeat = !_isRepeat;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: _isShuffle
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isShuffle = !_isShuffle;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.playlist_play,
                      color: Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              const Spacer(),

              // Progress Bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _currentPosition,
                      min: 0,
                      max: _totalDuration,
                      onChanged: (value) {
                        setState(() {
                          _currentPosition = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
