import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:azuracastadmin/models/listoffiles.dart';
import 'package:azuracastadmin/models/station_playlist.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

class FileDetailScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  final ListOfFiles file;

  const FileDetailScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
    required this.file,
  });

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isDeleting = false;
  bool _isUpdating = false;
  bool _isDeletingFile = false;
  bool _isEditing = false;
  bool _isLoadingPlaylists = false;
  late ListOfFiles currentFile;

  // Text controllers for editable fields
  late TextEditingController _textController;
  late TextEditingController _artistController;
  late TextEditingController _titleController;
  late TextEditingController _albumController;
  late TextEditingController _genreController;

  // Playlist management
  List<StationPlaylist> _availablePlaylists = [];
  List<int> _selectedPlaylistIds = [];

  @override
  void initState() {
    currentFile = widget.file;
    _initControllers();
    _loadPlaylists();
    _initializeSelectedPlaylists();
    super.initState();
  }

  void _initControllers() {
    _textController = TextEditingController(text: currentFile.text ?? '');
    _artistController = TextEditingController(text: currentFile.artist ?? '');
    _titleController = TextEditingController(text: currentFile.title ?? '');
    _albumController = TextEditingController(text: currentFile.album ?? '');
    _genreController = TextEditingController(text: currentFile.genre ?? '');
  }

  void _initializeSelectedPlaylists() {
    if (currentFile.playlists != null) {
      _selectedPlaylistIds = currentFile.playlists!.map((p) => p.id).toList();
    }
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoadingPlaylists = true;
    });

    try {
      List<StationPlaylist> playlists = await fetchStationPlaylists(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
      );

      setState(() {
        _availablePlaylists = playlists;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlaylists = false;
      });
      print('Error loading playlists: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _artistController.dispose();
    _titleController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        File imageFile = File(image.path);

        ApiResponse response = await uploadFileArt(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          fileID: currentFile.id,
          imageFile: imageFile,
        );

        setState(() {
          _isUploading = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Art uploaded successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
          // Refresh the art URL to show the new image
          setState(() {
            currentFile = currentFile; // This will trigger a rebuild
          });
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload image: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Future<void> _deleteArt() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Text(
            'Delete Art',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete the art for this file?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        ApiResponse response = await deleteFileArt(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          fileID: currentFile.id,
        );

        setState(() {
          _isDeleting = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Art deleted successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
          // Refresh the art URL to show the default image
          setState(() {
            currentFile = currentFile; // This will trigger a rebuild
          });
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete art: $e',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateFileDetails() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Prepare the data to send to the API - only send the editable fields
      Map<String, dynamic> fileData = {
        'text': _textController.text.isNotEmpty ? _textController.text : "",
        'artist':
            _artistController.text.isNotEmpty ? _artistController.text : "",
        'title': _titleController.text.isNotEmpty ? _titleController.text : "",
        'album': _albumController.text.isNotEmpty ? _albumController.text : "",
        'genre': _genreController.text.isNotEmpty ? _genreController.text : "",
        'playlists': _selectedPlaylistIds.map((id) => {'id': id}).toList(),
      };

      ApiResponse response = await updateFileDetails(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        fileID: currentFile.id,
        fileData: fileData,
      );

      setState(() {
        _isUpdating = false;
        _isEditing = false;
      });

      if (response.success) {
        // Update current file with new values for UI
        currentFile = ListOfFiles(
          id: currentFile.id,
          uniqueId: currentFile.uniqueId,
          songId: currentFile.songId,
          art: currentFile.art,
          path: currentFile.path,
          mtime: currentFile.mtime,
          uploadedAt: currentFile.uploadedAt,
          artUpdatedAt: currentFile.artUpdatedAt,
          length: currentFile.length,
          lengthText: currentFile.lengthText,
          customFields: currentFile.customFields,
          extraMetadata: currentFile.extraMetadata,
          playlists: currentFile.playlists,
          text: _textController.text.isNotEmpty ? _textController.text : null,
          artist:
              _artistController.text.isNotEmpty ? _artistController.text : null,
          title:
              _titleController.text.isNotEmpty ? _titleController.text : null,
          album:
              _albumController.text.isNotEmpty ? _albumController.text : null,
          genre:
              _genreController.text.isNotEmpty ? _genreController.text : null,
          isrc: currentFile.isrc,
          lyrics: currentFile.lyrics,
          links: currentFile.links,
        );

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File details updated successfully!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update file details: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Future<void> _deleteFile() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Text(
            'Delete File',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to permanently delete this file? This action cannot be undone.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isDeletingFile = true;
      });

      try {
        ApiResponse response = await deleteFile(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          fileID: currentFile.id,
        );

        setState(() {
          _isDeletingFile = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File deleted successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
          // Navigate back to files list
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isDeletingFile = false;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete file: $e',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'File Details',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              tooltip: _isEditing ? 'Cancel editing' : 'Edit file details',
            ),
            IconButton(
              onPressed: _isDeletingFile ? null : _deleteFile,
              icon: _isDeletingFile
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
              tooltip: 'Delete file',
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
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Art and Actions Section
                      Card(
                        color: Colors.black38,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Art Image
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FadeInImage.memoryNetwork(
                                    key: ValueKey(
                                        '${widget.url}/api/station/${widget.stationID}/art/${currentFile.id}?t=${DateTime.now().millisecondsSinceEpoch}'),
                                    placeholder: kTransparentImage,
                                    image:
                                        '${widget.url}/api/station/${widget.stationID}/art/${currentFile.id}?t=${DateTime.now().millisecondsSinceEpoch}',
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.music_note,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Action Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isUploading
                                        ? null
                                        : _pickAndUploadImage,
                                    icon: _isUploading
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(Icons.upload),
                                    label: Text(_isUploading
                                        ? 'Uploading...'
                                        : 'Upload Art'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _isDeleting ? null : _deleteArt,
                                    icon: _isDeleting
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(Icons.delete),
                                    label: Text(_isDeleting
                                        ? 'Deleting...'
                                        : 'Delete Art'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Song Information & Playlists (Merged Section)
                      Card(
                        color: Colors.black38,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Song Information',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (_isLoadingPlaylists)
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      if (_isEditing)
                                        ElevatedButton.icon(
                                          onPressed: _isUpdating
                                              ? null
                                              : _updateFileDetails,
                                          icon: _isUpdating
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Icon(Icons.save),
                                          label: Text(_isUpdating
                                              ? 'Saving...'
                                              : 'Save'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),

                              // Song Information Subsection
                              Text(
                                'Song Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildEditableInfoRow(
                                  'Text:', _textController, _isEditing),
                              _buildEditableInfoRow(
                                  'Title:', _titleController, _isEditing),
                              _buildEditableInfoRow(
                                  'Artist:', _artistController, _isEditing),
                              _buildEditableInfoRow(
                                  'Album:', _albumController, _isEditing),
                              _buildEditableInfoRow(
                                  'Genre:', _genreController, _isEditing),
                              if (!_isEditing) ...[
                                _buildInfoRow('Length:',
                                    currentFile.lengthText ?? 'Unknown'),
                                if (currentFile.isrc != null)
                                  _buildInfoRow('ISRC:', currentFile.isrc!),
                              ],

                              SizedBox(height: 20),

                              // Playlists Subsection
                              Text(
                                'Playlists',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (_isEditing &&
                                  _availablePlaylists.isNotEmpty) ...[
                                // Editable playlist selection
                                Text(
                                  'Select playlists for this file:',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ..._availablePlaylists.map((playlist) {
                                  final isSelected = _selectedPlaylistIds
                                      .contains(playlist.id);
                                  return CheckboxListTile(
                                    title: Text(
                                      '${playlist.name} (${playlist.numSongs} songs)',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedPlaylistIds.add(playlist.id);
                                        } else {
                                          _selectedPlaylistIds
                                              .remove(playlist.id);
                                        }
                                      });
                                    },
                                    activeColor: Colors.blue,
                                    checkColor: Colors.white,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ] else if (!_isEditing &&
                                  currentFile.playlists != null &&
                                  currentFile.playlists!.isNotEmpty) ...[
                                // Display current playlists (read-only)
                                ...currentFile.playlists!
                                    .map(
                                      (playlist) => Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.queue_music,
                                                color: Colors.blue, size: 20),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${playlist.name} (${playlist.count} songs)',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ] else if (!_isEditing) ...[
                                // No playlists message
                                Text(
                                  'This file is not in any playlists',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Technical Information
                      Card(
                        color: Colors.black38,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Technical Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              _buildInfoRow('ID:', currentFile.id.toString()),
                              _buildInfoRow('Unique ID:', currentFile.uniqueId),
                              _buildInfoRow('Song ID:', currentFile.songId),
                              if (currentFile.path != null)
                                _buildInfoRow('Path:', currentFile.path!),
                              if (currentFile.uploadedAt != null)
                                _buildInfoRow('Uploaded:',
                                    _formatTimestamp(currentFile.uploadedAt!)),
                              if (currentFile.artUpdatedAt != null)
                                _buildInfoRow(
                                    'Art Updated:',
                                    _formatTimestamp(
                                        currentFile.artUpdatedAt!)),
                            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              utf8.decode(value.codeUnits),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(
      String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  )
                : Text(
                    controller.text.isNotEmpty
                        ? utf8.decode(controller.text.codeUnits)
                        : 'Unknown',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
