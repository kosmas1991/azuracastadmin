import 'package:azuracastadmin/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class FrontEndActions extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const FrontEndActions(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<FrontEndActions> createState() => _FrontEndActionsState();
}

class _FrontEndActionsState extends State<FrontEndActions> {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frontend management',
            style: TextStyle(color: Colors.white),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                  onPressed: () async {
                    await postAdminActions(widget.url, 'frontend',
                            widget.apiKey, widget.stationID, 'start')
                        .then((Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Started',
                          style: TextStyle(color: Colors.green),
                        )));
                      } else if (response.statusCode == 500) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Cannot start! It is already running.',
                          style: TextStyle(color: Colors.red),
                        )));
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Failed.',
                          style: TextStyle(color: Colors.red),
                        )));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    color: Colors.blue,
                  ),
                  label: Text(
                    'Start',
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton.icon(
                  onPressed: () async {
                    await postAdminActions(widget.url, 'frontend',
                            widget.apiKey, widget.stationID, 'stop')
                        .then((Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Stopped',
                          style: TextStyle(color: Colors.green),
                        )));
                      } else if (response.statusCode == 500) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Cannot stop! It is already stopped.',
                          style: TextStyle(color: Colors.red),
                        )));
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Failed.',
                          style: TextStyle(color: Colors.red),
                        )));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.stop,
                    color: Colors.blue,
                  ),
                  label: Text(
                    'Stop',
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton.icon(
                  onPressed: () async {
                    await postAdminActions(widget.url, 'frontend',
                            widget.apiKey, widget.stationID, 'restart')
                        .then((Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Restarted',
                          style: TextStyle(color: Colors.green),
                        )));
                      } else if (response.statusCode == 500) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Seems that a restart action is already asked.',
                          style: TextStyle(color: Colors.red),
                        )));
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Failed.',
                          style: TextStyle(color: Colors.red),
                        )));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.restart_alt,
                    color: Colors.blue,
                  ),
                  label: Text(
                    'Restart',
                    style: TextStyle(color: Colors.blue),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
