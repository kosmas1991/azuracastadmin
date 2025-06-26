import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

enum AudioSourceType { radio, episode }

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  AudioPlayer? _player;
  AudioSourceType? _currentSourceType;
  String? _currentSourceId;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  // Check if audio manager is currently playing something
  bool get isPlaying => _player?.playing ?? false;

  // Check what type of source is currently active
  AudioSourceType? get currentSourceType => _currentSourceType;
  String? get currentSourceId => _currentSourceId;

  // Switch to radio mode
  Future<void> switchToRadio({
    required String url,
    required String stationName,
    required String stationId,
  }) async {
    if (_currentSourceType == AudioSourceType.radio &&
        _currentSourceId == stationId &&
        _player?.playing == true) {
      // Already playing this radio station
      return;
    }

    try {
      await _player?.stop();

      await player.setUrl(
        url,
        tag: MediaItem(
          id: stationId,
          title: stationName,
          artist: 'Live Radio Stream',
          isLive: true,
          artUri: Uri.parse(
              'https://avatars.githubusercontent.com/u/28115974?s=200&v=4'),
        ),
      );

      _currentSourceType = AudioSourceType.radio;
      _currentSourceId = stationId;
    } catch (e) {
      throw Exception('Failed to switch to radio: $e');
    }
  }

  // Switch to episode mode
  Future<void> switchToEpisode({
    required String url,
    required String episodeTitle,
    required String podcastTitle,
    required String episodeId,
    required String apiKey,
    String? artworkUrl,
  }) async {
    if (_currentSourceType == AudioSourceType.episode &&
        _currentSourceId == episodeId &&
        _player?.playing == true) {
      // Already playing this episode
      return;
    }

    try {
      await _player?.stop();

      final audioSource = AudioSource.uri(
        Uri.parse(url),
        headers: {
          'X-API-Key': apiKey,
        },
        tag: MediaItem(
          id: episodeId,
          title: episodeTitle,
          artist: podcastTitle,
          artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
        ),
      );

      await player.setAudioSource(audioSource);

      _currentSourceType = AudioSourceType.episode;
      _currentSourceId = episodeId;
    } catch (e) {
      throw Exception('Failed to switch to episode: $e');
    }
  }

  // Play current source
  Future<void> play() async {
    await player.play();
  }

  // Pause current source
  Future<void> pause() async {
    await player.pause();
  }

  // Stop and clear current source
  Future<void> stop() async {
    await _player?.stop();
    _currentSourceType = null;
    _currentSourceId = null;
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  // Seek to position (only for episodes, not radio)
  Future<void> seek(Duration position) async {
    if (_currentSourceType == AudioSourceType.episode) {
      await player.seek(position);
    }
  }

  // Dispose of the player
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _currentSourceType = null;
    _currentSourceId = null;
  }
}
