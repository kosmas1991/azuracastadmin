import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/episode.dart';
import 'package:azuracastadmin/models/podcast.dart';
import 'package:azuracastadmin/screens/episode_player_screen.dart';
import 'package:blur/blur.dart';
import 'package:image/image.dart' as img;

class EditEpisodeScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  final Podcast podcast;
  final Episode? episode; // null for create mode, episode object for edit mode

  const EditEpisodeScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
    required this.podcast,
    this.episode,
  });

  @override
  State<EditEpisodeScreen> createState() => _EditEpisodeScreenState();
}

class _EditEpisodeScreenState extends State<EditEpisodeScreen> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionShortController = TextEditingController();
  final _seasonNumberController = TextEditingController();
  final _episodeNumberController = TextEditingController();

  bool _isLoading = false;
  bool _explicit = false;
  bool _isPublished = true;
  DateTime? _publishAt;
  File? _selectedImageFile;
  File? _selectedMediaFile;
  bool _shouldRemoveArt = false;
  bool _shouldRemoveMedia = false;

  @override
  void initState() {
    super.initState();
    if (widget.episode != null) {
      _populateFields();
    } else {
      // Set default publish date to now
      _publishAt = DateTime.now();
    }
  }

  void _populateFields() {
    final episode = widget.episode!;
    _titleController.text = utf8.decode(episode.title.codeUnits);
    _linkController.text = episode.link ?? '';
    _descriptionController.text = utf8.decode(episode.description.codeUnits);
    _descriptionShortController.text =
        utf8.decode(episode.descriptionShort.codeUnits);
    _seasonNumberController.text = episode.seasonNumber?.toString() ?? '';
    _episodeNumberController.text = episode.episodeNumber?.toString() ?? '';
    _explicit = episode.explicit;
    _isPublished = episode.isPublished;
    _publishAt = DateTime.fromMillisecondsSinceEpoch(episode.publishAt * 1000);
  }

  Future<void> _saveEpisode() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.podcast.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Podcast ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final publishAtTimestamp = _publishAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;
      final publishAtSeconds = (publishAtTimestamp / 1000).round();

      Episode? savedEpisode;

      if (widget.episode == null) {
        // Create new episode
        savedEpisode = await createEpisode(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcastId: widget.podcast.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          descriptionShort: _descriptionShortController.text.trim(),
          link: _linkController.text.trim().isNotEmpty
              ? _linkController.text.trim()
              : null,
          explicit: _explicit,
          seasonNumber: _seasonNumberController.text.trim().isNotEmpty
              ? int.tryParse(_seasonNumberController.text.trim())
              : null,
          episodeNumber: _episodeNumberController.text.trim().isNotEmpty
              ? int.tryParse(_episodeNumberController.text.trim())
              : null,
          publishAt: publishAtSeconds,
          isPublished: _isPublished,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Episode created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing episode
        savedEpisode = await updateEpisode(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcastId: widget.podcast.id!,
          episodeId: widget.episode!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          descriptionShort: _descriptionShortController.text.trim(),
          link: _linkController.text.trim().isNotEmpty
              ? _linkController.text.trim()
              : null,
          explicit: _explicit,
          seasonNumber: _seasonNumberController.text.trim().isNotEmpty
              ? int.tryParse(_seasonNumberController.text.trim())
              : null,
          episodeNumber: _episodeNumberController.text.trim().isNotEmpty
              ? int.tryParse(_episodeNumberController.text.trim())
              : null,
          publishAt: publishAtSeconds,
          isPublished: _isPublished,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Episode updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Handle media upload/removal after episode is saved
      if (_selectedMediaFile != null) {
        try {
          await uploadEpisodeMedia(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: widget.podcast.id!,
            episodeId: savedEpisode.id,
            mediaFile: _selectedMediaFile!,
          );
        } catch (e) {
          print('Media upload error: $e');
        }
      } else if (_shouldRemoveMedia && widget.episode != null) {
        try {
          await deleteEpisodeMedia(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: widget.podcast.id!,
            episodeId: widget.episode!.id,
          );
        } catch (e) {
          print('Media removal error: $e');
        }
      }

      // Handle artwork upload/removal
      if (_selectedImageFile != null) {
        try {
          await uploadEpisodeArt(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: widget.podcast.id!,
            episodeId: savedEpisode.id,
            imageFile: _selectedImageFile!,
          );
        } catch (e) {
          print('Art upload error: $e');
        }
      } else if (_shouldRemoveArt && widget.episode != null) {
        try {
          await deleteEpisodeArt(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: widget.podcast.id!,
            episodeId: widget.episode!.id,
          );
        } catch (e) {
          print('Art removal error: $e');
        }
      }

      // Navigate back only after all operations are complete
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEpisode() async {
    if (widget.episode == null) return;

    if (widget.podcast.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Podcast ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Episode'),
        content: Text(
            'Are you sure you want to delete this episode? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await deleteEpisode(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        podcastId: widget.podcast.id!,
        episodeId: widget.episode!.id,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Episode deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPublishDate() async {
    final currentDate = _publishAt ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );

      if (time != null) {
        setState(() {
          _publishAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatPublishDate() {
    if (_publishAt == null) return 'Not set';
    return '${_publishAt!.day}/${_publishAt!.month}/${_publishAt!.year} ${_publishAt!.hour}:${_publishAt!.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (image != null) {
      try {
        final processedFile = await _processImage(File(image.path));
        setState(() {
          _selectedImageFile = processedFile;
          _shouldRemoveArt = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File> _processImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        image = img.bakeOrientation(image);

        final rgbImage = img.Image(
          width: image.width,
          height: image.height,
          format: img.Format.uint8,
          numChannels: 3,
        );

        for (int y = 0; y < image.height; y++) {
          for (int x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            rgbImage.setPixel(
                x,
                y,
                img.ColorRgb8(
                  pixel.r.toInt(),
                  pixel.g.toInt(),
                  pixel.b.toInt(),
                ));
          }
        }

        img.Image finalImage = rgbImage;
        if (rgbImage.width > 1024 || rgbImage.height > 1024) {
          finalImage = img.copyResize(
            rgbImage,
            width: rgbImage.width > rgbImage.height ? 1024 : null,
            height: rgbImage.height > rgbImage.width ? 1024 : null,
            maintainAspect: true,
          );
        }

        final processedBytes = img.encodeJpg(finalImage, quality: 90);
        final directory = imageFile.parent;
        final processedFile = File(
            '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await processedFile.writeAsBytes(processedBytes);

        return processedFile;
      }
    } catch (e) {
      print('Image processing error: $e');
    }

    return imageFile;
  }

  Future<void> _selectMediaFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedMediaFile = File(result.files.single.path!);
        _shouldRemoveMedia = false;
      });
    }
  }

  Future<void> _playEpisode() async {
    if (widget.episode?.links.download != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpisodePlayerScreen(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcast: widget.podcast,
            episode: widget.episode!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No media available for playback'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _removeCurrentArt() async {
    if (widget.episode == null) return;

    setState(() {
      _shouldRemoveArt = true;
      _selectedImageFile = null;
    });
  }

  Future<void> _removeCurrentMedia() async {
    if (widget.episode == null) return;

    setState(() {
      _shouldRemoveMedia = true;
      _selectedMediaFile = null;
    });
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
            widget.episode == null ? 'Add Episode' : 'Edit Episode',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            if (widget.episode != null && widget.episode!.hasMedia)
              IconButton(
                onPressed: _playEpisode,
                icon: Icon(Icons.play_arrow, color: Colors.green),
                tooltip: 'Play Episode',
              ),
            if (widget.episode != null)
              IconButton(
                onPressed: _deleteEpisode,
                icon: Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Episode',
              ),
            IconButton(
              onPressed: _isLoading ? null : _saveEpisode,
              icon: Icon(Icons.save, color: Colors.white),
              tooltip: 'Save Episode',
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
              GestureDetector(
                onTap: () {
                  // Dismiss keyboard when tapping outside text fields
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Episode Title
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Episode Title *',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Episode Link
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _linkController,
                          style: TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Episode Link (optional)',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Season and Episode Numbers
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _seasonNumberController,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (value) {
                                  FocusScope.of(context).nextFocus();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Season #',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[600]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _episodeNumberController,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (value) {
                                  FocusScope.of(context).nextFocus();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Episode #',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[600]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Description Short
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _descriptionShortController,
                          style: TextStyle(color: Colors.white),
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Short Description *',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Description
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          style: TextStyle(color: Colors.white),
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Full Description *',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Publish Date
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            'Publish Date',
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                          subtitle: Text(
                            _formatPublishDate(),
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing:
                              Icon(Icons.calendar_today, color: Colors.blue),
                          onTap: _selectPublishDate,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Settings
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                'Published',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Make this episode publicly available',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              value: _isPublished,
                              onChanged: (value) {
                                setState(() {
                                  _isPublished = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            Divider(color: Colors.grey[600]),
                            SwitchListTile(
                              title: Text(
                                'Explicit Content',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Mark this episode as explicit',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              value: _explicit,
                              onChanged: (value) {
                                setState(() {
                                  _explicit = value;
                                });
                              },
                              activeColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Episode Artwork Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Episode Artwork',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_selectedImageFile != null ||
                                (widget.episode?.hasCustomArt == true &&
                                    !_shouldRemoveArt))
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child: _selectedImageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImageFile!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : (widget.episode?.art != null &&
                                            !_shouldRemoveArt)
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              widget.episode!.art!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              headers: {
                                                'X-API-Key': widget.apiKey,
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors.grey[300],
                                                  ),
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.grey[600],
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[300],
                                            ),
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                          ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _selectImage,
                                      icon: Icon(Icons.image),
                                      label: Text(_selectedImageFile != null
                                          ? 'Change Image'
                                          : 'Select Image'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (widget.episode?.hasCustomArt == true ||
                                      _selectedImageFile != null) ...[
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: _removeCurrentArt,
                                      icon: Icon(Icons.delete),
                                      label: Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Episode Media Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Episode Media',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_selectedMediaFile != null)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.audiotrack, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedMediaFile!.path
                                            .split('/')
                                            .last,
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (widget.episode?.hasMedia == true &&
                                !_shouldRemoveMedia)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.audiotrack, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.episode!.media?.originalName ??
                                            'Current media file',
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.episode!.media?.lengthText !=
                                        null) ...[
                                      SizedBox(width: 8),
                                      Text(
                                        widget.episode!.media!.lengthText!,
                                        style:
                                            TextStyle(color: Colors.grey[300]),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _selectMediaFile,
                                      icon: Icon(Icons.audiotrack),
                                      label: Text(_selectedMediaFile != null
                                          ? 'Change Media'
                                          : 'Select Media'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (widget.episode?.hasMedia == true ||
                                      _selectedMediaFile != null) ...[
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: _removeCurrentMedia,
                                      icon: Icon(Icons.delete),
                                      label: Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Save Button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveEpisode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.episode == null
                                      ? 'Create Episode'
                                      : 'Update Episode',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _descriptionShortController.dispose();
    _seasonNumberController.dispose();
    _episodeNumberController.dispose();
    super.dispose();
  }
}
