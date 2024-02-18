import 'dart:async';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/cpustats.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CPUMemoryDiskStatsWidget extends StatefulWidget {
  final String url;
  final String apiKey;
  const CPUMemoryDiskStatsWidget({
    required this.url,
    required this.apiKey,
    super.key,
  });

  @override
  State<CPUMemoryDiskStatsWidget> createState() =>
      _CPUMemoryDiskStatsWidgetState();
}

class _CPUMemoryDiskStatsWidgetState extends State<CPUMemoryDiskStatsWidget> {
  late Future<CpuStats> cpuStats;
  @override
  void initState() {
    cpuStats = fetchCpuStats(widget.url, 'admin/server/stats', widget.apiKey);
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        cpuStats =
            fetchCpuStats(widget.url, 'admin/server/stats', widget.apiKey);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        CPU(screenWidth, screenHeight),
        Memory(screenWidth, screenHeight),
        Disk(screenWidth, screenHeight),
      ],
    );
  }

  Container Disk(double screenWidth, double screenHeight) {
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        width: screenWidth,
        child: FutureBuilder(
            future: cpuStats,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(
                      'Disk data',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'Total space: ${snapshot.data!.disk.readable.total} ',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LinearPercentIndicator(
                      lineHeight: 20,
                      center: Text(
                        'used: ${snapshot.data!.disk.readable.used}',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      progressColor: Colors.blue,
                      percent: double.parse(
                              snapshot.data!.disk.readable.used[0]) /
                          double.parse(snapshot.data!.disk.readable.total[0]),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
            }));
  }

  Container Memory(double screenWidth, double screenHeight) {
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        width: (screenWidth - 30) / 2,
        height: screenHeight / 4,
        child: FutureBuilder(
            future: cpuStats,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Memory data',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'Total: ${snapshot.data!.memory.readable.total}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Column(
                      children: [
                        CircularPercentIndicator(
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'used:',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '${snapshot.data!.memory.readable.used}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                          progressColor: (double.parse(snapshot
                                              .data!.memory.readable.used[0]) /
                                          double.parse(snapshot.data!.memory
                                              .readable.total[0])) *
                                      100 <
                                  80
                              ? Colors.blue
                              : Colors.red,
                          percent: (double.parse(
                                  snapshot.data!.memory.readable.used.substring(
                                      0,
                                      snapshot.data!.memory.readable.used
                                          .indexOf(' '))) /
                              double.parse(snapshot.data!.memory.readable.total
                                  .substring(
                                      0,
                                      snapshot.data!.memory.readable.total
                                          .indexOf(' ')))),
                          radius: 50,
                          lineWidth: 8,
                        ),
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
            }));
  }

  Container CPU(double screenWidth, double screenHeight) {
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        width: (screenWidth - 30) / 2,
        height: screenHeight / 4,
        child: FutureBuilder(
            future: cpuStats,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'CPU data',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'Num of cores: ${snapshot.data!.cpu.cores.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Column(
                      children: [
                        CircularPercentIndicator(
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'used:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '${snapshot.data!.cpu.total.usage} %',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            progressColor:
                                double.parse(snapshot.data!.cpu.total.usage) <
                                        80
                                    ? Colors.blue
                                    : Colors.red,
                            percent:
                                double.parse(snapshot.data!.cpu.total.usage) /
                                    100,
                            radius: 50,
                            lineWidth: 8),
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
            }));
  }
}
