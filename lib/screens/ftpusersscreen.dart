import 'dart:async';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/ftpusers.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class FTPUsersScreen extends StatefulWidget {
  final String url;
  final int stationID;
  final String apiKey;
  const FTPUsersScreen(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<FTPUsersScreen> createState() => _FTPUsersScreenState();
}

class _FTPUsersScreenState extends State<FTPUsersScreen> {
  late Future<List<FtpUsers>> ftpusers;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    ftpusers = fetchFTPUsers(
        widget.url, widget.stationID, 'sftp-users', widget.apiKey);
    super.initState();
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
              children: [
                FutureBuilder(
                  future: ftpusers,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!.length == 0
                          ? Text(
                              'No FTP users available',
                              style: TextStyle(color: Colors.white),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data![index];
                                  return Card(
                                    color: Colors.black38,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'username: ${data.username}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'user id: ${data.id}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          TextButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context2) =>
                                                      AlertDialog(
                                                          actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              putFTPUser(
                                                                      url: widget
                                                                          .url,
                                                                      path:
                                                                          'sftp-user',
                                                                      apiKey: widget
                                                                          .apiKey,
                                                                      stationID:
                                                                          widget
                                                                              .stationID,
                                                                      userID: data
                                                                          .id!,
                                                                      pass: textEditingController
                                                                          .text,
                                                                      username: data
                                                                          .username!)
                                                                  .then((Response
                                                                      response) {
                                                                if (response.statusCode ==
                                                                        200 &&
                                                                    response
                                                                        .body
                                                                        .contains(
                                                                            '"success":true')) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .hideCurrentSnackBar();
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text(
                                                                    'Record updated successfully.',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  )));
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .hideCurrentSnackBar();
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text(
                                                                    'Failed!',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  )));
                                                                }
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              'ok',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue),
                                                            ))
                                                      ],
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  42,
                                                                  42,
                                                                  42),
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Set new password',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .grey,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              )
                                                            ],
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextField(
                                                                onChanged:
                                                                    (value) {
                                                                  if (value
                                                                      .isNotEmpty) {
                                                                    setState(
                                                                        () {
                                                                      textEditingController
                                                                              .text =
                                                                          value;
                                                                    });
                                                                  }
                                                                },
                                                                controller:
                                                                    textEditingController,
                                                                cursorColor:
                                                                    Colors.blue,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                                decoration: InputDecoration(
                                                                    enabledBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .blue)),
                                                                    focusedBorder:
                                                                        UnderlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(color: Colors.blue))),
                                                              )
                                                            ],
                                                          )),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.lock,
                                                color: Colors.blue,
                                              ),
                                              label: Text(
                                                'Set new password',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ))
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
