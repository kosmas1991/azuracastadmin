import 'package:azuracastadmin/screens/filesscreens.dart';
import 'package:azuracastadmin/screens/ftpusersscreen.dart';
import 'package:azuracastadmin/screens/historyscreen.dart';
import 'package:azuracastadmin/screens/listeners.dart';
import 'package:azuracastadmin/screens/settingsScreen.dart';
import 'package:azuracastadmin/screens/settingsscreens.dart';
import 'package:azuracastadmin/screens/usersscreen.dart';
import 'package:flutter/material.dart';

class OtherInfo extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const OtherInfo(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<OtherInfo> createState() => _OtherInfoState();
}

class _OtherInfoState extends State<OtherInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(20),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        alignment: WrapAlignment.start,
        children: [
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListenersScreen(
                          apiKey: widget.apiKey,
                          stationID: widget.stationID,
                          url: widget.url),
                    ));
              },
              child: Text(
                'Listeners',
                style: TextStyle(color: Colors.white),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Play station',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilesScreen(
                          apiKey: widget.apiKey,
                          stationID: widget.stationID,
                          url: widget.url),
                    ));
              },
              child: Text(
                'Files',
                style: TextStyle(color: Colors.white),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServerSettingsScreen(apiKey: widget.apiKey, url: widget.url,
                    ),
                    ));
              },
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                          apiKey: widget.apiKey,
                          stationID: widget.stationID,
                          url: widget.url),
                    ));
              },
              child: Text(
                'History',
                style: TextStyle(color: Colors.white),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UsersScreen(apiKey: widget.apiKey, url: widget.url),
                    ));
              },
              child: Text(
                'Users',
                style: TextStyle(color: Colors.white),
              )),
          FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FTPUsersScreen(apiKey: widget.apiKey, stationID: widget.stationID, url: widget.url),
                    ));
              },
              child: Text(
                'FTP users',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
