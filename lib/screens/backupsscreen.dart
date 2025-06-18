import 'dart:async';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/backup.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackupsScreen extends StatefulWidget {
  final String url;
  final String apiKey;

  const BackupsScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends State<BackupsScreen>
    with TickerProviderStateMixin {
  late Future<List<Backup>> backups;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _refreshBackupsList();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refreshBackupsList() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final newBackups = fetchBackups(widget.url, widget.apiKey);

      setState(() {
        backups = newBackups;
      });

      await newBackups;
    } catch (e) {
      print('Error refreshing backups: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showDeleteBackupDialog(Backup backup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withAlpha(230),
          title: Text(
            'Delete Backup',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this backup?',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withAlpha(76)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      backup.basename ?? 'Unknown backup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Size: ${_formatFileSize(backup.size ?? 0)}',
                      style: TextStyle(color: Colors.grey.shade300),
                    ),
                    if (backup.timestamp != null)
                      Text(
                        'Created: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(backup.timestamp! * 1000))}',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '⚠️ This action cannot be undone!',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteBackup(backup),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteBackup(Backup backup) async {
    if (backup.pathEncoded == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup path'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await deleteBackup(
        url: widget.url,
        apiKey: widget.apiKey,
        pathEncoded: backup.pathEncoded!,
      );

      Navigator.pop(context);

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withAlpha(51),
          ),
        );
        _refreshBackupsList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete backup: ${response.message}',
              style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.red.withAlpha(51),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting backup: $e',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.red.withAlpha(51),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadBackup(Backup backup) async {
    if (backup.pathEncoded == null || backup.basename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withAlpha(230),
          content: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(width: 20),
                Text(
                  'Downloading backup...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      ApiResponse response = await downloadBackup(
        url: widget.url,
        apiKey: widget.apiKey,
        pathEncoded: backup.pathEncoded!,
        fileName: backup.basename!,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show result
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message,
            style: TextStyle(
              color: response.success ? Colors.green : Colors.red,
            ),
          ),
          backgroundColor: response.success
              ? Colors.green.withAlpha(51)
              : Colors.red.withAlpha(51),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download failed: $e',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.red.withAlpha(51),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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
            'Server Backups',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _isRefreshing ? null : _refreshBackupsList,
              tooltip: 'Refresh Backups',
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      if (_isRefreshing)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Refreshing backups...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: FutureBuilder<List<Backup>>(
                          future: backups,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !_isRefreshing) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 64,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Error loading backups',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${snapshot.error}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshBackupsList,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withAlpha(25),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.backup,
                                          color: Colors.grey,
                                          size: 64,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No backups available',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Server backups will appear here when available.',
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withAlpha(25),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.blue.withAlpha(76)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.info_outline,
                                                color: Colors.blue, size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Configure backups in server settings',
                                              style: TextStyle(
                                                color: Colors.blue.shade300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: _refreshBackupsList,
                                color: Colors.blue,
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return _buildBackupCard(
                                        snapshot.data![index]);
                                  },
                                ),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupCard(Backup backup) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      color: Colors.black.withAlpha(153),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.backup,
                    color: Colors.blue.shade300,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.basename ?? 'Unknown backup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.storage, color: Colors.grey, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Storage ID: ${backup.storageLocationId ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  color: Color.fromARGB(255, 42, 42, 42),
                  onSelected: (value) {
                    switch (value) {
                      case 'download':
                        _downloadBackup(backup);
                        break;
                      case 'delete':
                        _showDeleteBackupDialog(backup);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Download',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(76),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withAlpha(76)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Backup Information',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'File Size:',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        _formatFileSize(backup.size ?? 0),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (backup.timestamp != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Created:',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        Text(
                          DateFormat.yMMMEd().add_jm().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  backup.timestamp! * 1000)),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  if (backup.path != null)
                    Column(
                      children: [
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Path:',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                backup.path!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
