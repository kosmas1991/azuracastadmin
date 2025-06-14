import 'dart:async';
import 'dart:convert';

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
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  Future<List<HistoryFiles>>? historyFiles;
  bool searchPressed = false;
  bool _isDateRangeExpanded =
      true; // Controls if date range section is expanded
  bool _isLoading = false; // Controls loading state
  String _searchQuery = '';
  String _sortOption = 'time'; // 'time', 'delta_asc', 'delta_desc'
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Set default dates (last 7 days)
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));
    textEditingController1.text =
        '${weekAgo.year.toString()}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
    textEditingController2.text =
        '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    textEditingController1.dispose();
    textEditingController2.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (searchPressed && historyFiles != null)
            IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        var newHistoryFiles = fetchHistoryFiles(
                            widget.url,
                            widget.apiKey,
                            widget.stationID,
                            textEditingController1.text,
                            textEditingController2.text);

                        setState(() {
                          historyFiles = newHistoryFiles;
                        });

                        // Wait for the future to complete to reset loading state
                        await newHistoryFiles;
                      } catch (e) {
                        // Handle error if needed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error refreshing data: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
            ),
        ],
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
                // Date Range Selection Section
                Card(
                  color: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with toggle button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDateRangeExpanded = !_isDateRangeExpanded;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Select Date Range',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Toggle icon
                              AnimatedRotation(
                                turns: _isDateRangeExpanded ? 0.5 : 0,
                                duration: Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.expand_more,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Compact date display when collapsed
                        if (!_isDateRangeExpanded &&
                            textEditingController1.text.isNotEmpty &&
                            textEditingController2.text.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(51),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${textEditingController1.text}',
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.grey, size: 16),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(51),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${textEditingController2.text}',
                                    style: TextStyle(
                                      color: Colors.green.shade300,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Collapsible content
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isDateRangeExpanded ? null : 0,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _isDateRangeExpanded ? 1.0 : 0.0,
                            child: _isDateRangeExpanded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 12),

                                      // Compact date inputs
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => selectDate(true),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.blue
                                                          .withAlpha(76),
                                                      width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.calendar_today,
                                                        color: Colors.blue,
                                                        size: 16),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      textEditingController1
                                                              .text.isNotEmpty
                                                          ? textEditingController1
                                                              .text
                                                          : 'Start date',
                                                      style: TextStyle(
                                                        color:
                                                            textEditingController1
                                                                    .text
                                                                    .isNotEmpty
                                                                ? Colors.white
                                                                : Colors
                                                                    .white54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => selectDate(false),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.green
                                                          .withAlpha(76),
                                                      width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.calendar_today,
                                                        color: Colors.green,
                                                        size: 16),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      textEditingController2
                                                              .text.isNotEmpty
                                                          ? textEditingController2
                                                              .text
                                                          : 'End date',
                                                      style: TextStyle(
                                                        color:
                                                            textEditingController2
                                                                    .text
                                                                    .isNotEmpty
                                                                ? Colors.white
                                                                : Colors
                                                                    .white54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 8),

                                      // Quick Date Range Presets
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          _buildPresetButton(
                                              'Today', () => _setDateRange(0)),
                                          _buildPresetButton('Yesterday',
                                              () => _setDateRange(1)),
                                          _buildPresetButton(
                                              '3D', () => _setDateRange(3)),
                                          _buildPresetButton(
                                              '1W', () => _setDateRange(7)),
                                          _buildPresetButton(
                                              '1M', () => _setDateRange(30)),
                                        ],
                                      ),

                                      SizedBox(height: 10),

                                      // Search Button
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            if (textEditingController1
                                                    .text.isEmpty ||
                                                textEditingController2
                                                    .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Please select both start and end dates',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() {
                                              searchPressed = true;
                                              _isDateRangeExpanded = false;
                                              _isLoading = true;
                                            });

                                            try {
                                              var newHistoryFiles =
                                                  fetchHistoryFiles(
                                                      widget.url,
                                                      widget.apiKey,
                                                      widget.stationID,
                                                      textEditingController1
                                                          .text,
                                                      textEditingController2
                                                          .text);

                                              setState(() {
                                                historyFiles = newHistoryFiles;
                                              });

                                              // Wait for the future to complete to reset loading state
                                              await newHistoryFiles;
                                            } catch (e) {
                                              // Handle error if needed
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error fetching data: ${e.toString()}'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.search_rounded,
                                              color: Colors.white, size: 16),
                                          label: Text(
                                            'Search',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search and Sort Controls (only shown when results are available)
                if (searchPressed && historyFiles != null) ...[
                  Card(
                    color: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Search field
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search by artist, song name, or playlist...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade400),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.grey.shade400),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) {
                              // Cancel previous timer
                              _searchDebounceTimer?.cancel();

                              // Set a new timer for 300ms delay
                              _searchDebounceTimer =
                                  Timer(Duration(milliseconds: 300), () {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          // Sort options
                          Row(
                            children: [
                              Icon(Icons.sort,
                                  color: Colors.grey.shade400, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Sort by:',
                                style: TextStyle(
                                    color: Colors.grey.shade300, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  child: DropdownButtonFormField<String>(
                                    value: _sortOption,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black26,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                    dropdownColor: Colors.grey.shade800,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    isDense: true,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'time',
                                          child: Text('Play Time')),
                                      DropdownMenuItem(
                                          value: 'delta_desc',
                                          child: Text('Listeners ↓')),
                                      DropdownMenuItem(
                                          value: 'delta_asc',
                                          child: Text('Listeners ↑')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _sortOption = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],

                // SizedBox(height: 10),
                FutureBuilder(
                  future: historyFiles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var originalList = snapshot.data!;

                      // Apply search filter
                      var filteredList = originalList.where((item) {
                        if (_searchQuery.isEmpty) return true;

                        String title = utf8
                            .decode(item.song!.title!.codeUnits)
                            .toLowerCase();
                        String artist = utf8
                            .decode(item.song!.artist!.codeUnits)
                            .toLowerCase();
                        String playlist =
                            item.playlist != null && item.playlist!.isNotEmpty
                                ? utf8
                                    .decode(item.playlist!.codeUnits)
                                    .toLowerCase()
                                : '';

                        return title.contains(_searchQuery) ||
                            artist.contains(_searchQuery) ||
                            playlist.contains(_searchQuery);
                      }).toList();

                      // Apply sorting
                      switch (_sortOption) {
                        case 'delta_desc':
                          filteredList.sort((a, b) =>
                              (b.deltaTotal ?? 0).compareTo(a.deltaTotal ?? 0));
                          break;
                        case 'delta_asc':
                          filteredList.sort((a, b) =>
                              (a.deltaTotal ?? 0).compareTo(b.deltaTotal ?? 0));
                          break;
                        case 'time':
                        default:
                          filteredList.sort((a, b) =>
                              (b.playedAt ?? 0).compareTo(a.playedAt ?? 0));
                          break;
                      }

                      var list = filteredList;
                      return list.length != 0
                          ? Expanded(
                              child: Column(
                                children: [
                                  // Results Summary Header
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue.withAlpha(76)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.analytics,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Search Results',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Results count badge
                                            if (_searchQuery.isNotEmpty ||
                                                _sortOption != 'time') ...[
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.blue.withAlpha(76),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${list.length}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                            // Modify search button
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _isDateRangeExpanded = true;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.edit_calendar,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                'Modify',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade700,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                minimumSize: Size(0, 0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'Showing ${list.length} of ${originalList.length} tracks matching "${_searchController.text}"'
                                              : _sortOption != 'time'
                                                  ? 'Showing ${list.length} tracks sorted by ${_getSortLabel()}'
                                                  : 'Found ${list.length} tracks played between ${textEditingController1.text} and ${textEditingController2.text}',
                                          style: TextStyle(
                                            color: Colors.blue.shade300,
                                            fontSize: 14,
                                          ),
                                        ),
                                        // Quick actions row
                                        if (_searchQuery.isNotEmpty ||
                                            _sortOption != 'time') ...[
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              if (_searchQuery.isNotEmpty) ...[
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      _searchController.clear();
                                                      _searchQuery = '';
                                                    });
                                                  },
                                                  icon: Icon(Icons.clear_all,
                                                      size: 14),
                                                  label: Text('Show All'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    minimumSize: Size(0, 0),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                              ],
                                              if (_sortOption != 'time') ...[
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      _sortOption = 'time';
                                                    });
                                                  },
                                                  icon: Icon(Icons.restore,
                                                      size: 14),
                                                  label: Text('Default Sort'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    minimumSize: Size(0, 0),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Results List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: list.length,
                                      itemBuilder: (context, index) {
                                        var item = list[index];
                                        return Card(
                                          color: Colors.black38,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 4,
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Main track info row
                                                Row(
                                                  children: [
                                                    // Album art with better styling
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withAlpha(51),
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: FadeInImage
                                                            .memoryNetwork(
                                                          height: 60,
                                                          width: 60,
                                                          placeholder:
                                                              kTransparentImage,
                                                          image:
                                                              '${item.song!.art}',
                                                          fit: BoxFit.cover,
                                                          imageErrorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Container(
                                                              height: 60,
                                                              width: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade800,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .music_note,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                size: 30,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),

                                                    // Track details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Title
                                                          Text(
                                                            '${utf8.decode(item.song!.title!.codeUnits)}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(height: 4),
                                                          // Artist
                                                          Text(
                                                            '${utf8.decode(item.song!.artist!.codeUnits)}',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Request indicator
                                                    if (item.isRequest == true)
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.purple
                                                              .withAlpha(51),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .purple
                                                                  .withAlpha(
                                                                      102)),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .request_page,
                                                              color: Colors
                                                                  .purple
                                                                  .shade300,
                                                              size: 14,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'Request',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .purple
                                                                    .shade300,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),

                                                SizedBox(height: 12),

                                                // Track metadata row
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      color: Colors.grey,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Played: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(item.playedAt! * 1000))}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[300],
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: Colors.grey,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Duration: ${formattedTime(timeInSecond: item.duration!)} (${item.duration!}s)',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[300],
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                if (item.playlist != null &&
                                                    item.playlist!
                                                        .isNotEmpty) ...[
                                                  SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.playlist_play,
                                                        color: Colors.grey,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Playlist: ${utf8.decode(item.playlist!.codeUnits)}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[300],
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      color: Colors.grey,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Listeners: ${item.listenersStart} → ${item.listenersEnd}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[300],
                                                          fontSize: 12),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Icon(
                                                      item.deltaTotal! > 0
                                                          ? Icons.trending_up
                                                          : item.deltaTotal! < 0
                                                              ? Icons
                                                                  .trending_down
                                                              : Icons
                                                                  .trending_flat,
                                                      color: item.deltaTotal! >
                                                              0
                                                          ? Colors.green
                                                          : item.deltaTotal! < 0
                                                              ? Colors.red
                                                              : Colors.grey,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      '${item.deltaTotal! > 0 ? '+' : ''}${item.deltaTotal}',
                                                      style: TextStyle(
                                                          color: item.deltaTotal! >
                                                                  0
                                                              ? Colors.green
                                                              : item.deltaTotal! <
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors.grey[
                                                                      300],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(16),
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: _searchQuery.isNotEmpty
                                      ? Colors.blue.withAlpha(26)
                                      : Colors.orange.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _searchQuery.isNotEmpty
                                          ? Colors.blue.withAlpha(76)
                                          : Colors.orange.withAlpha(76)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      _searchQuery.isNotEmpty
                                          ? Icons.search_off
                                          : Icons.search_off,
                                      color: _searchQuery.isNotEmpty
                                          ? Colors.blue
                                          : Colors.orange,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No Matching Results'
                                          : 'No Results Found',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No tracks matching "${_searchController.text}" found in the selected date range.'
                                          : 'No tracks were played during the selected date range.',
                                      style: TextStyle(
                                        color: _searchQuery.isNotEmpty
                                            ? Colors.blue.shade300
                                            : Colors.orange.shade300,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_searchQuery.isNotEmpty) ...[
                                      SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                        icon: Icon(Icons.clear, size: 16),
                                        label: Text('Clear Search'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                    } else if (searchPressed) {
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
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

  Future<void> selectDate(bool isStartDate) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;
    DateTime firstDate = DateTime(now.year - 2);
    DateTime lastDate = now;

    // Set appropriate initial date based on current selection
    if (isStartDate && textEditingController1.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(textEditingController1.text);
      } catch (e) {
        initialDate = now.subtract(Duration(days: 7));
      }
    } else if (!isStartDate && textEditingController2.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(textEditingController2.text);
      } catch (e) {
        initialDate = now;
      }
    } else {
      initialDate = isStartDate ? now.subtract(Duration(days: 7)) : now;
    }

    // If selecting end date and start date is set, ensure end date is not before start date
    if (!isStartDate && textEditingController1.text.isNotEmpty) {
      try {
        DateTime startDate = DateTime.parse(textEditingController1.text);
        if (initialDate.isBefore(startDate)) {
          initialDate = startDate;
        }
        firstDate = startDate;
      } catch (e) {
        // Handle parsing error gracefully
      }
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStartDate ? 'Select Start Date' : 'Select End Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: isStartDate ? Colors.blue : Colors.green,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.grey[900],
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String finalDate =
          '${picked.year.toString()}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      setState(() {
        if (isStartDate) {
          textEditingController1.text = finalDate;
          // If end date is before start date, clear or adjust end date
          if (textEditingController2.text.isNotEmpty) {
            try {
              DateTime endDate = DateTime.parse(textEditingController2.text);
              if (endDate.isBefore(picked)) {
                textEditingController2.text = '';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'End date cleared because it was before the new start date',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              // Handle parsing error gracefully
            }
          }
        } else {
          textEditingController2.text = finalDate;
        }
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isStartDate ? 'Start' : 'End'} date set to ${DateFormat('dd/MM/yyyy').format(picked)}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: isStartDate ? Colors.blue : Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Helper method to build preset buttons
  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  // Helper method to set date range based on days back
  void _setDateRange(int daysBack) {
    DateTime now = DateTime.now();
    DateTime endDate = now;
    DateTime startDate;

    if (daysBack == 0) {
      // Today
      startDate = now;
    } else if (daysBack == 1) {
      // Yesterday
      startDate = now.subtract(Duration(days: 1));
      endDate = now.subtract(Duration(days: 1));
    } else {
      // Last N days
      startDate = now.subtract(Duration(days: daysBack));
    }

    String startDateStr =
        '${startDate.year.toString()}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String endDateStr =
        '${endDate.year.toString()}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    setState(() {
      textEditingController1.text = startDateStr;
      textEditingController2.text = endDateStr;
    });

    // Show feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    String label = daysBack == 0
        ? 'Today'
        : daysBack == 1
            ? 'Yesterday'
            : 'Last $daysBack days';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Date range set to: $label',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Helper method to get sort label
  String _getSortLabel() {
    switch (_sortOption) {
      case 'delta_desc':
        return 'listener changes (high to low)';
      case 'delta_asc':
        return 'listener changes (low to high)';
      case 'time':
      default:
        return 'play time';
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
