import 'dart:convert';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/charts.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  
  const ChartsScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
  });

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<Charts> chartsData;

  @override
  void initState() {
    super.initState();
    chartsData = fetchCharts(widget.url, widget.apiKey, widget.stationID);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
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
                    Text(
                      'Station Charts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: FutureBuilder<Charts>(
                        future: chartsData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Daily Listeners Chart
                                  if (snapshot.data!.daily != null)
                                    _buildDailyChart(snapshot.data!.daily!, screenWidth),
                                  
                                  SizedBox(height: 20),
                                  
                                  // Day of Week Chart
                                  if (snapshot.data!.dayOfWeek != null)
                                    _buildDayOfWeekChart(snapshot.data!.dayOfWeek!, screenWidth),
                                  
                                  SizedBox(height: 20),
                                  
                                  // Hourly Chart (All)
                                  if (snapshot.data!.hourly?.all != null)
                                    _buildHourlyChart(snapshot.data!.hourly!.all!, screenWidth, 'All Days'),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error loading charts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChart(Daily daily, double screenWidth) {
    return Card(
      color: Colors.black38,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Listeners',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            if (daily.alt != null && daily.alt!.isNotEmpty)
              ...daily.alt!.first.values!.map((value) {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.original! * 1000);
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(date),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        value.value ?? '0',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekChart(DayOfWeek dayOfWeek, double screenWidth) {
    return Card(
      color: Colors.black38,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listeners by Day of Week',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            if (dayOfWeek.alt != null && dayOfWeek.alt!.isNotEmpty)
              ...dayOfWeek.alt!.first.values!.map((value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value.label ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        value.value ?? '0',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(HourlyData hourlyData, double screenWidth, String title) {
    return Card(
      color: Colors.black38,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listeners by Hour ($title)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            if (hourlyData.alt != null && hourlyData.alt!.isNotEmpty)
              ...hourlyData.alt!.first.values!.map((value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value.label ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        value.value ?? '0',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
