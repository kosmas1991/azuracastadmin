import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/charts.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class ChartsOverviewScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;

  const ChartsOverviewScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
  });

  @override
  State<ChartsOverviewScreen> createState() => _ChartsOverviewScreenState();
}

class _ChartsOverviewScreenState extends State<ChartsOverviewScreen> {
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'Charts',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
                child: FutureBuilder<Charts>(
                  future: chartsData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Daily Listeners Line Chart
                            if (snapshot.data!.daily != null)
                              _buildDailyLineChart(
                                  snapshot.data!.daily!, screenWidth),

                            SizedBox(height: 20),

                            // Day of Week Bar Chart
                            if (snapshot.data!.dayOfWeek != null)
                              _buildDayOfWeekBarChart(
                                  snapshot.data!.dayOfWeek!, screenWidth),

                            SizedBox(height: 20),

                            // Hourly Chart (All)
                            if (snapshot.data!.hourly?.all != null)
                              _buildHourlyBarChart(snapshot.data!.hourly!.all!,
                                  screenWidth, 'Weelky'),

                            SizedBox(height: 20),
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
                              'Error loading charts overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading charts...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyLineChart(Daily daily, double screenWidth) {
    if (daily.metrics == null || daily.metrics!.isEmpty) {
      return Container();
    }

    List<FlSpot> spots = [];
    List<DateTime> dates = [];
    if (daily.metrics!.first.data != null) {
      for (int i = 0; i < daily.metrics!.first.data!.length; i++) {
        var dataPoint = daily.metrics!.first.data![i];
        spots.add(FlSpot(i.toDouble(), dataPoint.y?.toDouble() ?? 0));
        // Convert epoch timestamp to DateTime - dataPoint.x contains the epoch timestamp in milliseconds
        int timestamp = dataPoint.x ?? 0;
        // Timestamps are already in milliseconds, treat as UTC to get correct date
        DateTime utcDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
        dates.add(utcDate);
      }
    }

    return Card(
      color: Colors.black.withValues(alpha: 0.6),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Listeners Trend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _calculateYAxisInterval(spots),
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          );
                          if (value.toInt() < dates.length) {
                            DateTime date = dates[value.toInt()];
                            String formattedDate =
                                DateFormat('dd/MM').format(date);

                            // Split date into two lines - alternating positioning
                            bool isEvenIndex = value.toInt() % 2 == 0;
                            return Container(
                              padding:
                                  EdgeInsets.only(top: isEvenIndex ? 4 : 20),
                              child: Text(formattedDate, style: style),
                            );
                          }
                          return Text('', style: style);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateYAxisInterval(spots),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ));
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  minX: 0,
                  maxX: spots.length > 0 ? spots.length - 1.0 : 0,
                  minY: 0,
                  maxY: spots.isNotEmpty
                      ? spots
                              .map((spot) => spot.y)
                              .reduce((a, b) => a > b ? a : b) +
                          1
                      : 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withValues(alpha: 0.3),
                            Colors.blue.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekBarChart(DayOfWeek dayOfWeek, double screenWidth) {
    if (dayOfWeek.metrics == null || dayOfWeek.metrics!.isEmpty) {
      return Container();
    }

    List<BarChartGroupData> barGroups = [];
    var data = dayOfWeek.metrics!.first.data;
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    return Card(
      color: Colors.black.withValues(alpha: 0.6),
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
            Container(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isNotEmpty
                      ? barGroups
                              .map((group) => group.barRods.first.toY)
                              .reduce((a, b) => a > b ? a : b) +
                          1
                      : 5,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          Colors.black.withValues(alpha: 0.8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay = dayOfWeek.labels != null &&
                                groupIndex < dayOfWeek.labels!.length
                            ? utf8
                                .decode(dayOfWeek.labels![groupIndex].codeUnits)
                            : 'Day ${groupIndex + 1}';
                        return BarTooltipItem(
                          '$weekDay\n${rod.toY.round()} listeners',
                          TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          if (dayOfWeek.labels != null &&
                              value.toInt() < dayOfWeek.labels!.length) {
                            String day = dayOfWeek.labels![value.toInt()];
                            String decodedDay = utf8.decode(day.codeUnits);
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(decodedDay.substring(0, 3),
                                  style: style),
                            );
                          }
                          return Text('', style: style);
                        },
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _calculateBarChartYAxisInterval(barGroups),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        _calculateBarChartYAxisInterval(barGroups),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyBarChart(
      HourlyData hourlyData, double screenWidth, String title) {
    if (hourlyData.metrics == null || hourlyData.metrics!.isEmpty) {
      return Container();
    }

    List<BarChartGroupData> barGroups = [];
    var data = hourlyData.metrics!.first.data;
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        );
      }
    }

    return Card(
      color: Colors.black.withValues(alpha: 0.6),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hourly Listeners ($title)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isNotEmpty
                      ? barGroups
                              .map((group) => group.barRods.first.toY)
                              .reduce((a, b) => a > b ? a : b) +
                          1
                      : 5,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          Colors.black.withValues(alpha: 0.8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String hour = hourlyData.labels != null &&
                                groupIndex < hourlyData.labels!.length
                            ? hourlyData.labels![groupIndex]
                            : '${groupIndex}:00';
                        return BarTooltipItem(
                          '$hour\n${rod.toY.round()} listeners',
                          TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 7,
                          );
                          if (hourlyData.labels != null &&
                              value.toInt() < hourlyData.labels!.length) {
                            String hour = hourlyData.labels![value.toInt()];

                            // Alternate positioning for better visibility
                            bool isEvenIndex = value.toInt() % 2 == 0;
                            return Container(
                              padding:
                                  EdgeInsets.only(top: isEvenIndex ? 2 : 18),
                              child: Text(hour, style: style),
                            );
                          }
                          return Text('', style: style);
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _calculateBarChartYAxisInterval(barGroups),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        _calculateBarChartYAxisInterval(barGroups),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate appropriate Y-axis interval
  double _calculateYAxisInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 50;

    double maxValue =
        spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Calculate interval to show approximately 5-8 labels
    double rawInterval = maxValue / 6;

    // Round to nice numbers
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 25) return 25;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 250) return 250;
    if (rawInterval <= 500) return 500;

    // For very large numbers, round to nearest 100
    return (rawInterval / 100).ceil() * 100;
  }

  // Helper method to calculate appropriate Y-axis interval for bar charts
  double _calculateBarChartYAxisInterval(List<BarChartGroupData> barGroups) {
    if (barGroups.isEmpty) return 50;

    double maxValue = barGroups
        .map((group) => group.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);

    // Calculate interval to show approximately 5-8 labels
    double rawInterval = maxValue / 6;

    // Round to nice numbers
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 25) return 25;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 250) return 250;
    if (rawInterval <= 500) return 500;

    // For very large numbers, round to nearest 100
    return (rawInterval / 100).ceil() * 100;
  }
}
