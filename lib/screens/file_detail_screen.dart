import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:azuracastadmin/models/listoffiles.dart';
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
  late ListOfFiles currentFile;

  @override
  void initState() {
    currentFile = widget.file;
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'File Details',
            style: TextStyle(color: Colors.white),
          ),
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
                                    key: ValueKey('${widget.url}/api/station/${widget.stationID}/art/${currentFile.id}?t=${DateTime.now().millisecondsSinceEpoch}'),
                                    placeholder: kTransparentImage,
                                    image: '${widget.url}/api/station/${widget.stationID}/art/${currentFile.id}?t=${DateTime.now().millisecondsSinceEpoch}',
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isUploading ? null : _pickAndUploadImage,
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
                                    label: Text(_isUploading ? 'Uploading...' : 'Upload Art'),
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
                                    label: Text(_isDeleting ? 'Deleting...' : 'Delete Art'),
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
                      
                      // File Information
                      Card(
                        color: Colors.black38,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Song Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              _buildInfoRow('Title:', currentFile.title ?? 'Unknown'),
                              _buildInfoRow('Artist:', currentFile.artist ?? 'Unknown'),
                              _buildInfoRow('Album:', currentFile.album ?? 'Unknown'),
                              _buildInfoRow('Genre:', currentFile.genre ?? 'Unknown'),
                              _buildInfoRow('Length:', currentFile.lengthText ?? 'Unknown'),
                              if (currentFile.isrc != null)
                                _buildInfoRow('ISRC:', currentFile.isrc!),
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
                                _buildInfoRow('Uploaded:', _formatTimestamp(currentFile.uploadedAt!)),
                              if (currentFile.artUpdatedAt != null)
                                _buildInfoRow('Art Updated:', _formatTimestamp(currentFile.artUpdatedAt!)),
                            ],
                          ),
                        ),
                      ),
                      
                      // Playlists if available
                      if (currentFile.playlists != null && currentFile.playlists!.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: 20),
                            Card(
                              color: Colors.black38,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Playlists',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    ...currentFile.playlists!.map((playlist) => 
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.queue_music, color: Colors.blue, size: 20),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${playlist.name} (${playlist.count} songs)',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
