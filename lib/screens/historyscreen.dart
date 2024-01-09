import 'dart:async';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/historyfiles.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class HistoryScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const HistoryScreen(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late var timer;
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  Future<List<HistoryFiles>>? historyFiles;
  bool searchPressed = false;

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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: textEditingController1,
                      onTap: () {
                        selectDate(true);
                      },
                      decoration: InputDecoration(
                          hintText: 'Start date',
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          filled: false,
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          border: InputBorder.none),
                      readOnly: true,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: textEditingController2,
                      onTap: () {
                        selectDate(false);
                      },
                      decoration: InputDecoration(
                          hintText: 'End date',
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          filled: false,
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          border: InputBorder.none),
                      readOnly: true,
                    ),
                    TextButton.icon(
                        onPressed: () {
                          searchPressed = true;
                          setState(() {
                            historyFiles = fetchHistoryFiles(
                                widget.url,
                                widget.apiKey,
                                widget.stationID,
                                textEditingController1.text,
                                textEditingController2.text);
                          });
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          color: Colors.blue,
                          size: 30,
                        ),
                        label: Text(
                          'Search',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ))
                  ],
                ),
                FutureBuilder(
                  future: historyFiles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var list = snapshot.data!;
                      return list.length != 0
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  var item = list[index];
                                  return Card(
                                    color: Colors.black38,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child:
                                                    FadeInImage.memoryNetwork(
                                                  height: 50,
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: '${item.song!.art}',
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
                                                    width: screenWidth * 5 / 9,
                                                    child: Text(
                                                      '${item.song!.title}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 2,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: screenWidth * 5 / 9,
                                                    child: Text(
                                                      '${item.song!.artist}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 2,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Played at: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(item.playedAt! * 1000))}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Duration: ${item.duration!} secs (${formattedTime(timeInSecond: item.duration!)})',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Listeners start/end: ${item.listenersStart}/${item.listenersEnd}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Delta total: ${item.deltaTotal}',
                                            style: TextStyle(
                                                color: (item
                                                        .deltaTotal!.isNegative)
                                                    ? Colors.red
                                                    : (item.deltaTotal == 0)
                                                        ? Colors.white
                                                        : Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              'No results',
                              style: TextStyle(color: Colors.white),
                            );
                    } else if (searchPressed) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    } else {
                      return Container();
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

  Future<void> selectDate(bool first) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 10),
        lastDate: DateTime(2050));

    if (picked != null) {
      String finalDate =
          '${picked.year.toString()}-${picked.month.toString()}-${picked.day.toString()}';
      setState(() {
        if (first) {
          textEditingController1.text = finalDate;
        } else {
          textEditingController2.text = finalDate;
        }
      });
    }
  }
}

formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute:$second";
}
