import 'dart:async';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/listeners.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _ListenersScreenState extends State<ListenersScreen>
    with TickerProviderStateMixin {
  late Future<List<ActiveListeners>> activeListeners;
  List<ActiveListeners>? _currentListeners;
  late Timer timer;
  late AnimationController _refreshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Initialize data
    activeListeners = fetchListeners(
        widget.url, 'listeners', widget.apiKey, widget.stationID);

    // Start fade animation
    _fadeController.forward();

    // Set up periodic refresh
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  void _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward().then((_) {
      _refreshController.reverse();
    });

    try {
      // Fetch new data in background
      final newListeners = await fetchListeners(
          widget.url, 'listeners', widget.apiKey, widget.stationID);

      // Update the current listeners without rebuilding
      if (mounted) {
        setState(() {
          _currentListeners = newListeners;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      // If error, just stop refreshing and keep current data
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _refreshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()}m';
    } else if (seconds < 86400) {
      return '${(seconds / 3600).round()}h';
    } else {
      return '${(seconds / 86400).round()}d';
    }
  }

  Widget _buildStatsCard(int listenerCount) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(30),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Listeners',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$listenerCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          RotationTransition(
            turns: _refreshController,
            child: GestureDetector(
              onTap: _refreshData,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListenerCard(ActiveListeners listener, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(70),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                listener.device?.isMobile == true
                    ? Icons.smartphone
                    : listener.device?.isBrowser == true
                        ? Icons.computer
                        : Icons.radio,
                color: Colors.blue.shade300,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                if (listener.location?.country != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image:
                          'https://flagsapi.com/${listener.location!.country}/flat/24.png',
                      width: 24,
                      height: 16,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 300),
                      imageErrorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.flag, size: 16, color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    '${listener.location?.city ?? "Unknown"}, ${listener.location?.country ?? "Unknown"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      color: Colors.blue.shade300, size: 16),
                  SizedBox(width: 4),
                  Text(
                    _formatDuration(listener.connectedTime ?? 0),
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  if (listener.device?.client != null) ...[
                    Icon(Icons.devices, color: Colors.grey.shade400, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listener.device!.client!,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.location_on,
                      'IP Address',
                      listener.ip ?? 'Unknown',
                      Colors.orange.shade300,
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.router,
                      'Mount Point',
                      listener.mountName ?? 'Default',
                      Colors.green.shade300,
                    ),
                    if (listener.location?.region != null) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.map,
                        'Region',
                        listener.location!.region!,
                        Colors.purple.shade300,
                      ),
                    ],
                    if (listener.device?.browserFamily != null ||
                        listener.device?.osFamily != null) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.info,
                        'Platform',
                        '${listener.device?.browserFamily ?? ''} on ${listener.device?.osFamily ?? ''}',
                        Colors.cyan.shade300,
                      ),
                    ],
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.schedule,
                      'Connected Since',
                      listener.connectedOn != null
                          ? DateFormat('MMM dd, HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  listener.connectedOn! * 1000))
                          : 'Unknown',
                      Colors.blue.shade300,
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

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black.withAlpha(80),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Active Listeners',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isRefreshing)
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
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
                  fit: BoxFit.cover,
                ),
              ).blurred(blur: 12, blurColor: Colors.black),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(60),
                      Colors.black.withAlpha(40),
                      Colors.black.withAlpha(60),
                    ],
                  ),
                ),
              ),
              FutureBuilder<List<ActiveListeners>>(
                future: activeListeners,
                builder: (context, snapshot) {
                  // Use current listeners if available, otherwise use snapshot data
                  List<ActiveListeners>? listenersToShow =
                      _currentListeners ?? snapshot.data;

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _currentListeners == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading listeners...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError && _currentListeners == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade300,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading listeners',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check your connection',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (listenersToShow == null || listenersToShow.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.people_outline,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No Active Listeners',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your station is currently not being listened to',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Store the data for future refreshes if this is the first load
                  if (_currentListeners == null && snapshot.hasData) {
                    _currentListeners = snapshot.data;
                  }

                  return Column(
                    children: [
                      _buildStatsCard(listenersToShow.length),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: listenersToShow.length,
                          itemBuilder: (context, index) {
                            return _buildListenerCard(
                                listenersToShow[index], index);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
