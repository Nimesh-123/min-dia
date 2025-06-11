import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PodcastListenerWidget extends StatefulWidget {
  const PodcastListenerWidget({super.key});

  @override
  State<PodcastListenerWidget> createState() => _PodcastListenerWidgetState();
}

class _PodcastListenerWidgetState extends State<PodcastListenerWidget>
    with WidgetsBindingObserver {
  late AudioSource _audioUrl;

  late AudioPlayer _player;
  bool _isPlaying = true;
  Duration _currentPosition = Duration.zero;
  late StreamSubscription<Duration> _positionSubscription;
  bool _isDisposing = false;

  bool _showPlaybackSlider = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioUrl = AudioSource.uri(
      Uri.parse('http://daq7nasbr6dck.cloudfront.net/7habits/1.mp3'),
      tag: MediaItem(
        id: '1',
        album: '7 Habits of Highly Effective People',
        title: 'Chapter 1',
        artist: 'Stephen R. Covey',
        artUri: Uri.parse(
          'http://daq7nasbr6dck.cloudfront.net/7habits/cover.jpg',
        ),
      ),
    );
    _player = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
        darwinLoadControl: DarwinLoadControl(
          automaticallyWaitsToMinimizeStalling:
              false, // Start playback immediately
          preferredForwardBufferDuration: Duration(seconds: 15),
        ),
        // Android settings
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: Duration(seconds: 10),
          maxBufferDuration: Duration(seconds: 50),
          bufferForPlaybackDuration: Duration(milliseconds: 2500),
          bufferForPlaybackAfterRebufferDuration: Duration(seconds: 5),
        ),
      ),
    );
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _player.setAudioSource(
      _audioUrl,
      preload: true,
      initialIndex: 0,
      initialPosition: _currentPosition,
    );
    await _player.setAndroidAudioAttributes(
      AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
    );

    await _player.play();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _togglePlaybackSpeedSlider() {
    setState(() {
      _showPlaybackSlider = !_showPlaybackSlider;
    });
  }

  void _rewind30() {
    final newPosition = _currentPosition - Duration(seconds: 30);
    _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _forward30() {
    final totalDuration = _player.duration ?? Duration.zero;
    final newPosition = _currentPosition + Duration(seconds: 30);
    _player.seek(newPosition > totalDuration ? totalDuration : newPosition);
  }

  Widget _buildAudioSeekBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(0, 255, 255, 255),
            Colors.white,
            Colors.white,
          ],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.replay_30, color: Colors.black),
                onPressed: _rewind30,
                tooltip: 'Rewind 30 seconds',
              ),
              const SizedBox(width: 10),
              IconButton(
                iconSize: 64,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.black,
                ),
                onPressed: _togglePlayback,
              ),
              const SizedBox(width: 10),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.forward_30, color: Colors.black),
                onPressed: _forward30,
                tooltip: 'Rewind 30 seconds',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_showPlaybackSlider) {
            _togglePlaybackSpeedSlider();
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [const Text('Empty area')],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildAudioSeekBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDisposeEvent() async {
    // Events in this function happen in orfer of priority as it may not complete.
    if (_isDisposing) {
      return; // Already handling dispose, or already disposed
    }
    _isDisposing = true;

    WidgetsBinding.instance.removeObserver(this);

    // It's good to stop the player before accessing duration or position for logging.
    _player.stop();
    final duration =
        _player.duration; // Capture duration before potential nullification
    _player.dispose();
    _positionSubscription.cancel();

    final percentageListened =
        duration != null && duration.inSeconds > 0
            ? (_currentPosition.inSeconds / duration.inSeconds * 100).clamp(
              0.0,
              100.0,
            )
            : 0.0;

    print('percentageListened: $percentageListened');
    if (percentageListened > 94) {
      _currentPosition = Duration.zero;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // App has come to the foreground.
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., interrupted by a phone call or Siri on iOS,
        // or switching apps). Audio should ideally continue if background mode is active.
        // `just_audio_background` handles this for continued playback.
        break;
      case AppLifecycleState.paused:
        // App is in the background (minimized).
        // For your requirement, audio should continue playing.
        // `just_audio_background` is responsible for this. Do NOT dispose the player here.
        break;
      case AppLifecycleState.detached:
        // The application is about to be detached.
        // This is the correct place to stop and release all resources on app close.
        _handleDisposeEvent();
        break;
      case AppLifecycleState.hidden:
        // Flutter 3.13+ The application is hidden.
        // On mobile, this often behaves like `paused`. For app close, `detached` is more definitive.
        // If you find `detached` is not reliably called on iOS for app termination via swipe,
        // you might consider also disposing here, but test `detached` first.
        break;
    }
  }

  @override
  void dispose() {
    _handleDisposeEvent();
    super.dispose();
  }
}
