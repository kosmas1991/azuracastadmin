import 'dart:async';
import 'dart:convert';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/listoffiles.dart';
import 'package:azuracastadmin/screens/file_detail_screen.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class FilesScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const FilesScreen(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late Future<List<ListOfFiles>> listOfFiles;
  late var timer;
  bool _isRefreshing = false;
  
  // Search functionality
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;
  
  @override
  void initState() {
    _refreshFilesList();
    timer = Timer.periodic(Duration(minutes: 2), (timer) {
      _refreshFilesList();
    });
    super.initState();
  }
  
  // Method to refresh the files list
  Future<void> _refreshFilesList() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final newListOfFiles = fetchListOfFiles(
          widget.url, 'files', widget.apiKey, widget.stationID);
      
      setState(() {
        listOfFiles = newListOfFiles;
      });
      
      // Wait for the request to complete to stop the loading indicator
      await newListOfFiles;
    } catch (e) {
      // Handle error if needed
      print('Error refreshing files: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // Method to filter files based on search query
  List<ListOfFiles> _filterFiles(List<ListOfFiles> files) {
    if (_searchQuery.isEmpty) {
      return files;
    }
    
    return files.where((file) {
      final title = file.title?.toLowerCase() ?? '';
      final artist = file.artist?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  // Method to toggle search visibility
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(children: [
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
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder(
                      future: listOfFiles,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final filteredFiles = _filterFiles(snapshot.data!);
                          return Text(
                            _searchQuery.isEmpty 
                              ? 'Number of files: ${snapshot.data!.length}'
                              : 'Found: ${filteredFiles.length} of ${snapshot.data!.length}',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          );
                        }
                        return Text(
                          'Loading files...',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        );
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _toggleSearch,
                          icon: Icon(
                            _isSearchVisible ? Icons.search_off : Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: _isSearchVisible ? 'Hide search' : 'Search files',
                        ),
                        IconButton(
                          onPressed: _isRefreshing ? null : _refreshFilesList,
                          icon: _isRefreshing 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                          tooltip: _isRefreshing ? 'Refreshing...' : 'Refresh files list',
                        ),
                      ],
                    ),
                  ],
                ),
                // Search bar (conditionally visible)
                if (_isSearchVisible) ...[
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by song title or artist...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                        suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
                SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: listOfFiles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final filteredFiles = _filterFiles(snapshot.data!);
                      
                      if (filteredFiles.isEmpty && _searchQuery.isNotEmpty) {
                        // Show empty search results
                        return Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No files found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try searching with different keywords',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _refreshFilesList();
                          },
                          backgroundColor: Colors.black54,
                          color: Colors.blue,
                          child: ListView.builder(
                            itemCount: filteredFiles.length,
                            itemBuilder: (context, index) {
                            var data = filteredFiles[index];
                            return Card(
                              color: Colors.black38,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: FadeInImage.memoryNetwork(
                                        height: 50,
                                        placeholder: kTransparentImage,
                                        image:
                                            '${widget.url}/api/station/${widget.stationID}/art/${data.id}',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: screenWidth * 4 / 10,
                                          child: Text(
                                            '${utf8.decode(data.title!.codeUnits)}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.fade,
                                            maxLines: 2,
                                            softWrap: false,
                                          ),
                                        ),
                                        Container(
                                          width: screenWidth * 4 / 10,
                                          child: Text(
                                            '${utf8.decode(data.artist!.codeUnits)}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            if (data.path != null) {
                                              // Show loading dialog
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 42, 42, 42),
                                                  content: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 20),
                                                      Text(
                                                        'Downloading...',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );

                                              try {
                                                // Extract filename from path
                                                String fileName =
                                                    data.path!.split('/').last;

                                                // Call download function
                                                var response =
                                                    await downloadFile(
                                                  url: widget.url,
                                                  apiKey: widget.apiKey,
                                                  stationID: widget.stationID,
                                                  filePath: data.path!,
                                                  fileName: fileName,
                                                );

                                                // Close loading dialog
                                                Navigator.of(context).pop();

                                                // Show result
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      response.message,
                                                      style: TextStyle(
                                                        color: response.success
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                // Close loading dialog
                                                Navigator.of(context).pop();

                                                // Show error
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Download failed: $e',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'File path not available',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.download,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                          tooltip: 'Download file',
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            // Navigate to edit screen and wait for result
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FileDetailScreen(
                                                  url: widget.url,
                                                  apiKey: widget.apiKey,
                                                  stationID: widget.stationID,
                                                  file: data,
                                                ),
                                              ),
                                            );
                                            // Refresh files list when returning from edit screen
                                            await _refreshFilesList();
                                          },
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Colors.blue,
                                            size: 24,
                                          ),
                                          tooltip: 'Edit file details',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 16),
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
                )
              ],
            ),
          )
        ]),
      ),
    ));
  }
}
