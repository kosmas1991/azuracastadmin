import 'dart:async';
import 'dart:convert';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/nextsongs.dart';
import 'package:azuracastadmin/models/nowplaying.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;

class StationInfo extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const StationInfo({
    required this.url,
    required this.apiKey,
    required this.stationID,
    super.key,
  });

  @override
  State<StationInfo> createState() => _StationInfoState();
}

class _StationInfoState extends State<StationInfo> {
  late Future<NowPlaying> nowPlaying;
  late Future<List<NextSongs>> nextSongs;
  @override
  void initState() {
    nextSongs =
        fetchNextSongs(widget.url, 'queue', widget.apiKey, widget.stationID);
    nowPlaying = fetchNowPlaying(widget.url, 'nowplaying', widget.stationID);

    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        nowPlaying =
            fetchNowPlaying(widget.url, 'nowplaying', widget.stationID);
        nextSongs = fetchNextSongs(
            widget.url, 'queue', widget.apiKey, widget.stationID);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadioTitle(),
              SizedBox(
                height: 15,
              ),
              ImageAndTitle(screenWidth),
              SizedBox(
                height: 15,
              ),
              HistoryAndNextSongs(context, screenWidth, screenHeight),
            ],
          )),
    );
  }

  Wrap HistoryAndNextSongs(
      BuildContext context, double screenWidth, double screenHeight) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.spaceBetween,
      children: [
        TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: Color.fromARGB(255, 42, 42, 42),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Song History',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    content: FutureBuilder<NowPlaying>(
                        future: nowPlaying,
                        builder: (context, snapshot) {
                          DateTime now = DateTime.now();
                          if (snapshot.hasData) {
                            return Container(
                              width: screenWidth * 7 / 9,
                              height: screenHeight * 5 / 9,
                              child: ListView.builder(
                                itemCount: snapshot.data!.songHistory!.length,
                                itemBuilder: (context, index) => Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image:
                                                '${snapshot.data!.songHistory![index].song!.art}',
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: screenWidth * 1 / 2.5,
                                              child: Text(
                                                '${utf8.decode(snapshot.data!.songHistory![index].song!.title!.codeUnits)}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 1 / 2.5,
                                              child: Text(
                                                '${utf8.decode(snapshot.data!.songHistory![index].song!.artist!.codeUnits)}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 1 / 2.5,
                                              child: Text(
                                                'before ${(((now.millisecondsSinceEpoch / 1000) - snapshot.data!.songHistory![index].playedAt!) / 60).round()} mins',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }
                        })),
              );
            },
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ),
            label: Text(
              'Song History',
              style: TextStyle(color: Colors.white),
            )),
        TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: Color.fromARGB(255, 42, 42, 42),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Next songs',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    content: FutureBuilder<List<NextSongs>>(
                        future: nextSongs,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              width: screenWidth * 7 / 9,
                              height: screenHeight * 2.5 / 9,
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) => Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image:
                                                '${snapshot.data![index].song!.art}',
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: screenWidth * 1 / 2.5,
                                              child: Text(
                                                '${utf8.decode(snapshot.data![index].song!.title!.codeUnits)}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 1 / 2.5,
                                              child: Text(
                                                '${utf8.decode(snapshot.data![index].song!.artist!.codeUnits)}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }
                        })),
              );
            },
            icon: Icon(
              Icons.fast_forward,
              color: Colors.white,
            ),
            label: Text(
              'Next Songs',
              style: TextStyle(color: Colors.white),
            )),
        TextButton.icon(
            onPressed: () async {
              await http.post(
                  headers: <String, String>{
                    'accept': 'application/json',
                    'X-API-Key': '${widget.apiKey}',
                  },
                  Uri.parse(
                      '${widget.url}/api/station/${widget.stationID}/backend/skip')).then(
                (Response response) {
                  if (response.statusCode == 200) {
                    printWarning(response.body);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      'Song will be skipped',
                      style: TextStyle(color: Colors.green),
                    )));
                  } else {
                    printWarning(
                        'error code : ${response.statusCode.toString()} and headers ${response.headers} and is redirect ${response.isRedirect}');
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      'Failed! Try again',
                      style: TextStyle(color: Colors.red),
                    )));
                  }
                },
              );
            },
            icon: Icon(
              Icons.skip_next_outlined,
              color: Colors.white,
            ),
            label: Text(
              'Skip song',
              style: TextStyle(color: Colors.white),
            )),
        // TextButton(
        //     onPressed: () {
        //       throw Exception('for testing crashlytics');
        //     },
        //     child: Text('throw ex')),
      ],
    );
  }

  FutureBuilder<NowPlaying> ImageAndTitle(double screenWidth) {
    return FutureBuilder<NowPlaying>(
        future: nowPlaying,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FadeInImage.memoryNetwork(
                    height: 50,
                    placeholder: kTransparentImage,
                    image: '${snapshot.data!.nowPlaying!.song!.art}',
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 5 / 9,
                      child: Text(
                        '${utf8.decode(snapshot.data!.nowPlaying!.song!.title!.codeUnits)}',
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
                      width: screenWidth * 5 / 9,
                      child: Text(
                        '${utf8.decode(snapshot.data!.nowPlaying!.song!.artist!.codeUnits)}',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                        softWrap: false,
                      ),
                    ),
                  ],
                )
              ],
            );
          } else {
            return Container();
          }
        });
  }

  Container RadioTitle() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder(
            future: nowPlaying,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '${snapshot.data!.station!.name}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
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
          FutureBuilder(
              future: nowPlaying,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'listening now: ${snapshot.data!.listeners!.unique}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.blue,
                  ));
                }
              }),
        ],
      ),
    );
  }
}
