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
  @override
  void initState() {
    listOfFiles =
        fetchListOfFiles(widget.url, 'files', widget.apiKey, widget.stationID);
    timer = Timer.periodic(Duration(minutes: 2), (timer) {
      setState(() {
        listOfFiles = fetchListOfFiles(
            widget.url, 'files', widget.apiKey, widget.stationID);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
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
                FutureBuilder(
                  future: listOfFiles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Number of files: ${snapshot.data!.length}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
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
                SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: listOfFiles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
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
                                          onPressed: () {
                                            Navigator.push(
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
