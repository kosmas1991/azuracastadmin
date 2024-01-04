import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/stationsstatus.dart';
import 'package:flutter/material.dart';

class StationStatusWidget extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  const StationStatusWidget(
      {required this.url,
      required this.apiKey,
      required this.stationID,
      super.key});

  @override
  State<StationStatusWidget> createState() => _StationStatusWidgetState();
}

class _StationStatusWidgetState extends State<StationStatusWidget> {
  late Future<StationStatus> stationStatus;
  @override
  void initState() {
    stationStatus =
        fetchStatus(widget.url, 'status', widget.apiKey, widget.stationID);
    super.initState();
  }

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
        child: FutureBuilder(
          future: stationStatus,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Backend running: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        snapshot.data!.backendRunning.toString() == 'true'
                            ? 'yes'
                            : 'no',
                        style: TextStyle(
                            color: snapshot.data!.backendRunning.toString() ==
                                    'true'
                                ? Colors.green
                                : Colors.red),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Frontend running: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        snapshot.data!.frontendRunning.toString() == 'true'
                            ? 'yes'
                            : 'no',
                        style: TextStyle(
                            color: snapshot.data!.frontendRunning.toString() ==
                                    'true'
                                ? Colors.green
                                : Colors.red),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Station has started: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        snapshot.data!.stationHasStarted.toString() == 'true'
                            ? 'yes'
                            : 'no',
                        style: TextStyle(
                            color:
                                snapshot.data!.stationHasStarted.toString() ==
                                        'true'
                                    ? Colors.green
                                    : Colors.red),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Station needs restart: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        snapshot.data!.stationNeedsRestart.toString() == 'true'
                            ? 'yes'
                            : 'no',
                        style: TextStyle(
                            color:
                                snapshot.data!.stationNeedsRestart.toString() ==
                                        'false'
                                    ? Colors.green
                                    : Colors.red),
                      )
                    ],
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
          },
        ));
  }
}
