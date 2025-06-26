import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';

enum AudioSourceType { radio, episode }

class AudioPlayerService {
  static AudioPlayerService? _instance;
  static AudioPlayerService get instance =>
      _instance ??= AudioPlayerService._internal();

  AudioPlayerService._internal();

  AudioPlayer? _audioPlayer;
  AudioSourceType? _currentSourceType;
  String? _currentSourceId;

  AudioPlayer get player {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  // Check if audio player is currently playing something
  bool get isPlaying => _audioPlayer?.playing ?? false;

  // Check what type of source is currently active
  AudioSourceType? get currentSourceType => _currentSourceType;
  String? get currentSourceId => _currentSourceId;

  Future<void> dispose() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.dispose();
      _audioPlayer = null;
      _currentSourceType = null;
      _currentSourceId = null;
    }
  }

  // Switch to radio mode
  Future<void> switchToRadio({
    required String url,
    required String stationName,
    required String stationId,
  }) async {
    if (_currentSourceType == AudioSourceType.radio &&
        _currentSourceId == stationId &&
        _audioPlayer?.playing == true) {
      // Already playing this radio station
      return;
    }

    try {
      await _audioPlayer?.stop();

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
  Future<void> setAudioSourceWithMetadata({
    required String url,
    required Map<String, String> headers,
    required String title,
    required String artist,
    required String episodeId,
    String? artUri,
  }) async {
    if (_currentSourceType == AudioSourceType.episode &&
        _currentSourceId == episodeId &&
        _audioPlayer?.playing == true) {
      // Already playing this episode
      return;
    }

    try {
      await _audioPlayer?.stop();

      final mediaItem = MediaItem(
        id: episodeId,
        title: title,
        artist: artist,
        artUri: artUri != null ? Uri.parse(artUri) : null,
      );

      final audioSource = AudioSource.uri(
        Uri.parse(url),
        headers: headers,
        tag: mediaItem,
      );

      await player.setAudioSource(audioSource);

      _currentSourceType = AudioSourceType.episode;
      _currentSourceId = episodeId;
    } catch (e) {
      throw Exception('Failed to switch to episode: $e');
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      _currentSourceType = null;
      _currentSourceId = null;
    }
  }

  Future<void> pause() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.pause();
    }
  }

  Future<void> play() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.play();
    }
  }

  Future<void> seek(Duration position) async {
    if (_audioPlayer != null && _currentSourceType == AudioSourceType.episode) {
      await _audioPlayer!.seek(position);
    }
  }

  Future<void> reset() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.seek(Duration.zero);
      _currentSourceType = null;
      _currentSourceId = null;
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  bool get canSeek => _currentSourceType == AudioSourceType.episode;
  Duration get duration => _audioPlayer?.duration ?? Duration.zero;
  Duration get position => _audioPlayer?.position ?? Duration.zero;
}
