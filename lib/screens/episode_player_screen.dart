import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:azuracastadmin/models/episode.dart';
import 'package:azuracastadmin/models/podcast.dart';
import 'package:azuracastadmin/services/audio_player_service.dart';
import 'package:blur/blur.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EpisodePlayerScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  final Podcast podcast;
  final Episode episode;

  const EpisodePlayerScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
    required this.podcast,
    required this.episode,
  });

  @override
  State<EpisodePlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends State<EpisodePlayerScreen> {
  AudioPlayer get _audioPlayer => AudioPlayerService.instance.player;
  bool _isLoading = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.episode.links.download == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No media available for this episode'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Reset the player to ensure clean state
      await AudioPlayerService.instance.reset();

      // Use the singleton service to set up audio with metadata
      await AudioPlayerService.instance.setAudioSourceWithMetadata(
        url: widget.episode.links.download!,
        headers: {
          'X-API-Key': widget.apiKey,
        },
        title: utf8.decode(widget.episode.title.codeUnits),
        artist: widget.podcast.title != null
            ? utf8.decode(widget.podcast.title!.codeUnits)
            : 'Unknown Podcast',
        episodeId: widget.episode.id,
        artUri: widget.episode.art,
      );

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          setState(() {
            _isPlaying = playerState.playing;
          });
        }
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });

      // Listen to position changes
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
            // Ensure position doesn't exceed duration to prevent slider errors
            if (_duration.inMilliseconds > 0 &&
                _position.inMilliseconds > _duration.inMilliseconds) {
              _position = _duration;
            }
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await AudioPlayerService.instance.pause();
      } else {
        await AudioPlayerService.instance.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error controlling playback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await AudioPlayerService.instance.seek(position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seeking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadEpisode() async {
    if (widget.episode.links.download == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No download link available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Request storage permission (only needed for Android)
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      Permission permission;
      if (await Permission.manageExternalStorage.isGranted) {
        // Already have manage external storage permission
        permission = Permission.manageExternalStorage;
      } else {
        // Try to get manage external storage permission first
        permission = Permission.manageExternalStorage;
        var status = await permission.request();

        if (!status.isGranted) {
          // Fallback to regular storage permission
          permission = Permission.storage;
          status = await permission.request();

          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Storage permission is required to download'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
            return;
          }
        }
      }
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Get appropriate directory for each platform
      Directory directory;
      if (Platform.isIOS) {
        // On iOS, use Documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // On Android, try to use Downloads directory
        Directory? downloadsDir;

        // Try to get the Downloads directory
        try {
          // For Android, get external storage directory first
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Navigate to Downloads folder
            final downloadsPath = '/storage/emulated/0/Download';
            downloadsDir = Directory(downloadsPath);

            // Check if Downloads directory exists and is accessible
            if (!downloadsDir.existsSync()) {
              // Fallback to external storage if Downloads not accessible
              directory = externalDir;
            } else {
              directory = downloadsDir;
            }
          } else {
            throw Exception('Could not access storage directory');
          }
        } catch (e) {
          // Fallback to external storage directory if Downloads fails
          final externalDir = await getExternalStorageDirectory();
          if (externalDir == null) {
            throw Exception('Could not access storage directory');
          }
          directory = externalDir;
        }
      }

      // Create podcasts directory
      final podcastsDir = Directory('${directory.path}/Podcasts');
      if (!podcastsDir.existsSync()) {
        podcastsDir.createSync(recursive: true);
      }

      // Clean filename for cross-platform compatibility
      final fileName =
          '${widget.podcast.title != null ? utf8.decode(widget.podcast.title!.codeUnits) : 'Unknown'} - ${utf8.decode(widget.episode.title.codeUnits)}.mp3'
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(RegExp(r'\s+'),
                  ' ') // Replace multiple spaces with single space
              .trim();
      final filePath = '${podcastsDir.path}/$fileName';

      // Download the file
      final response = await http.get(
        Uri.parse(widget.episode.links.download!),
        headers: {
          'X-API-Key': widget.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final platformMessage = Platform.isIOS
            ? 'Episode downloaded to app documents folder'
            : podcastsDir.path.contains('/Download')
                ? 'Episode downloaded to Downloads/Podcasts folder'
                : 'Episode downloaded to: ${podcastsDir.path}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(platformMessage),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            action: Platform.isIOS
                ? SnackBarAction(
                    label: 'Files App',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Open Files app → On My iPhone → [App Name] → Podcasts'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  void dispose() {
    // Stop the shared audio player when leaving the screen
    AudioPlayerService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'Now Playing',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: _isDownloading ? null : _downloadEpisode,
              icon: _isDownloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.download, color: Colors.white),
              tooltip: 'Download Episode',
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/azu.png',
                  fit: BoxFit.fill,
                ),
              ).blurred(blur: 10, blurColor: Colors.black),
              SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 40),

                    // Episode Artwork
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: widget.episode.hasCustomArt &&
                                widget.episode.art != null
                            ? Image.network(
                                widget.episode.art!,
                                fit: BoxFit.cover,
                                headers: {
                                  'X-API-Key': widget.apiKey,
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultArtwork();
                                },
                              )
                            : _buildDefaultArtwork(),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Episode Info
                    Text(
                      utf8.decode(widget.episode.title.codeUnits),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.podcast.title != null
                          ? utf8.decode(widget.podcast.title!.codeUnits)
                          : 'Unknown Podcast',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40),

                    // Progress Bar
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbColor: Colors.white,
                            activeTrackColor: Colors.blue,
                            inactiveTrackColor: Colors.grey[600],
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _duration.inMilliseconds > 0
                                ? (_position.inMilliseconds /
                                        _duration.inMilliseconds)
                                    .clamp(
                                        0.0, 1.0) // Clamp between 0.0 and 1.0
                                : 0.0,
                            onChanged: (value) {
                              final newPosition = Duration(
                                milliseconds:
                                    (value * _duration.inMilliseconds).round(),
                              );
                              _seek(newPosition);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            final newPosition =
                                _position - Duration(seconds: 30);
                            if (newPosition.inMilliseconds >= 0) {
                              _seek(newPosition);
                            } else {
                              _seek(Duration.zero);
                            }
                          },
                          icon: Icon(Icons.replay_30,
                              color: Colors.white, size: 36),
                        ),
                        SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _playPause,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            final newPosition =
                                _position + Duration(seconds: 30);
                            if (newPosition.inMilliseconds <=
                                _duration.inMilliseconds) {
                              _seek(newPosition);
                            } else if (_duration.inMilliseconds > 0) {
                              _seek(_duration);
                            }
                          },
                          icon: Icon(Icons.forward_30,
                              color: Colors.white, size: 36),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Episode Description
                    if (widget.episode.description.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episode Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              utf8.decode(widget.episode.description.codeUnits),
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultArtwork() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.podcasts,
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}
