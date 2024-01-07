import 'dart:async';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/listeners.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ListenersScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const ListenersScreen(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<ListenersScreen> createState() => _ListenersScreenState();
}

class _ListenersScreenState extends State<ListenersScreen> {
  late Future<List<ActiveListeners>> activeListeners;
  late var timer;
  @override
  void initState() {
    activeListeners = fetchListeners(
        widget.url, 'listeners', widget.apiKey, widget.stationID);
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        activeListeners = fetchListeners(
            widget.url, 'listeners', widget.apiKey, widget.stationID);
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
                  future: activeListeners,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Listening now: ${snapshot.data!.length}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
                  future: activeListeners,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IP: ${data.ip}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Listening for: ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        data.connectedTime! < 60
                                            ? Text(
                                                '${data.connectedTime!} secs',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : data.connectedTime! >= 3600
                                                ? Text(
                                                    '${(data.connectedTime! / 3600).round().toInt()} hour(s)',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    '${(data.connectedTime! / 60).round().toInt()} min(s)',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                      ],
                                    ),
                                    Text(
                                      'City: ${data.location!.city}, ${data.location!.region}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Country: ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image:
                                              'https://flagsapi.com/${data.location!.country}/flat/24.png',
                                        ),
                                        Text(
                                          ' (${data.location!.country})',
                                          style: TextStyle(color: Colors.white),
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
