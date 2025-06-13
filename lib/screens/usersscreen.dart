import 'dart:async';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/users.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class UsersScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  const UsersScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<Users>> users;

  @override
  void initState() {
    users = fetchUsers(widget.url, 'admin/users', widget.apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
                  future: users,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
                            return Card(
                              color: Colors.black38,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FadeInImage.memoryNetwork(
                                    width: screenWidth / 10 * 2,
                                    placeholder: kTransparentImage,
                                    image:
                                        'https://www.azuracast.com/img/avatar.png',
                                  ),
                                  Container(
                                    width: screenWidth / 10 * 7,
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data.email}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Created at:  ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.createdAt! * 1000))}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Updated at:  ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.updatedAt! * 1000))}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Role: ${data.roles![0].name}',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
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
