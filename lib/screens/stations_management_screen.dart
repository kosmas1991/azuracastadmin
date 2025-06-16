import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/station.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class StationsManagementScreen extends StatefulWidget {
  final String url;
  final String apiKey;

  const StationsManagementScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<StationsManagementScreen> createState() =>
      _StationsManagementScreenState();
}

class _StationsManagementScreenState extends State<StationsManagementScreen>
    with TickerProviderStateMixin {
  List<Station> stations = [];
  bool isLoading = false;
  bool _isRefreshing = false;
  String? errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadStations();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isRefreshing = true;
      errorMessage = null;
    });

    try {
      final stationsData = await fetchStations(widget.url, widget.apiKey);
      setState(() {
        stations = stationsData.map((data) => Station.fromJson(data)).toList();
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _deleteStation(int stationId, String stationName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 42, 42, 42),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Station',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "$stationName"?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All station data will be permanently deleted.',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final result =
            await deleteStation(widget.url, widget.apiKey, stationId);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'],
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.2),
            ),
          );
          _loadStations(); // Refresh the list
        } else {
          _showErrorMessage(result['message']);
        }
      } catch (e) {
        _showErrorMessage('Error deleting station: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _cloneStation(int stationId, String originalName) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 42, 42, 42),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Clone Station',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clone "$originalName"',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Station Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Station name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Media storage will be cloned automatically',
                          style: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text('Clone', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final cloneResult = await cloneStation(
          widget.url,
          widget.apiKey,
          stationId,
          nameController.text.trim(),
          descriptionController.text.trim(),
        );

        if (cloneResult['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                cloneResult['message'],
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.2),
            ),
          );
          _loadStations(); // Refresh the list
        } else {
          _showErrorMessage(cloneResult['message']);
        }
      } catch (e) {
        _showErrorMessage('Error cloning station: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showEditStationDialog(Station station) async {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
        text: station.name != null ? utf8.decode(station.name!.codeUnits) : '');
    final shortNameController =
        TextEditingController(text: station.shortName ?? '');
    final descriptionController = TextEditingController(
        text: station.description != null
            ? utf8.decode(station.description!.codeUnits)
            : '');
    final urlController = TextEditingController(text: station.url ?? '');
    final genreController = TextEditingController(
        text:
            station.genre != null ? utf8.decode(station.genre!.codeUnits) : '');

    bool isEnabled = station.isEnabled ?? true;
    bool enableRequests = station.enableRequests ?? true;
    bool enableStreamers = station.enableStreamers ?? false;
    bool enablePublicPage = station.enablePublicPage ?? true;
    bool enableOnDemand = station.enableOnDemand ?? false;
    bool enableOnDemandDownload = station.enableOnDemandDownload ?? false;
    bool enableHls = station.enableHls ?? false;

    int requestDelay = station.requestDelay ?? 5;
    int requestThreshold = station.requestThreshold ?? 15;
    int apiHistoryItems = station.apiHistoryItems ?? 5;
    int maxBitrate = station.maxBitrate ?? 128;
    int maxMounts = station.maxMounts ?? 3;
    int maxHlsStreams = station.maxHlsStreams ?? 3;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Station',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Basic Information Section
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Station Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Station name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: shortNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Short Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: urlController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Website URL',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: genreController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Genre',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Station Settings Section
                    Text(
                      'Station Settings',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Toggle switches
                    _buildToggleRow('Station Enabled', isEnabled, (value) {
                      setDialogState(() {
                        isEnabled = value;
                      });
                    }),
                    _buildToggleRow('Enable Requests', enableRequests, (value) {
                      setDialogState(() {
                        enableRequests = value;
                      });
                    }),
                    _buildToggleRow('Enable Streamers', enableStreamers,
                        (value) {
                      setDialogState(() {
                        enableStreamers = value;
                      });
                    }),
                    _buildToggleRow('Enable Public Page', enablePublicPage,
                        (value) {
                      setDialogState(() {
                        enablePublicPage = value;
                      });
                    }),
                    _buildToggleRow('Enable On Demand', enableOnDemand,
                        (value) {
                      setDialogState(() {
                        enableOnDemand = value;
                      });
                    }),
                    _buildToggleRow('Enable HLS', enableHls, (value) {
                      setDialogState(() {
                        enableHls = value;
                      });
                    }),

                    SizedBox(height: 16),

                    // Numeric settings in a compact layout
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: requestDelay.toString(),
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Request Delay',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              requestDelay =
                                  int.tryParse(value) ?? requestDelay;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: requestThreshold.toString(),
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Request Threshold',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              requestThreshold =
                                  int.tryParse(value) ?? requestThreshold;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Advanced settings like backend/frontend configs are preserved',
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text('Save Changes', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });

      try {
        // Prepare station data for update
        Map<String, dynamic> stationData = {
          'name': nameController.text.trim(),
          'short_name': shortNameController.text.trim(),
          'is_enabled': isEnabled,
          'frontend_type': station.frontendType ?? 'icecast',
          'frontend_config': station.frontendConfig?.toJson() ?? {},
          'backend_type': station.backendType ?? 'liquidsoap',
          'backend_config': station.backendConfig?.toJson() ?? {},
          'description': descriptionController.text.trim(),
          'url': urlController.text.trim(),
          'genre': genreController.text.trim(),
          'radio_base_dir': station.radioBaseDir ??
              '/var/azuracast/stations/${shortNameController.text.trim()}',
          'enable_requests': enableRequests,
          'request_delay': requestDelay,
          'request_threshold': requestThreshold,
          'disconnect_deactivate_streamer':
              station.disconnectDeactivateStreamer ?? 0,
          'enable_streamers': enableStreamers,
          'is_streamer_live': station.isStreamerLive ?? false,
          'enable_public_page': enablePublicPage,
          'enable_on_demand': enableOnDemand,
          'enable_on_demand_download': enableOnDemandDownload,
          'enable_hls': enableHls,
          'api_history_items': apiHistoryItems,
          'timezone': station.timezone ?? 'UTC',
          'max_bitrate': maxBitrate,
          'max_mounts': maxMounts,
          'max_hls_streams': maxHlsStreams,
          'branding_config': station.brandingConfig?.toJson() ?? {},
        };

        final updateResult = await updateStation(
          widget.url,
          widget.apiKey,
          station.id!,
          stationData,
        );

        if (updateResult['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updateResult['message'],
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.2),
            ),
          );
          _loadStations(); // Refresh the list
        } else {
          _showErrorMessage(updateResult['message']);
        }
      } catch (e) {
        _showErrorMessage('Error updating station: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.red)),
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      ),
    );
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
            'Stations Management',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _isRefreshing ? null : _loadStations,
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
                  fit: BoxFit.fill,
                ),
              ).blurred(blur: 10, blurColor: Colors.black),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      if (_isRefreshing)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Loading stations...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: _buildStationsList(),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationsList() {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading stations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (stations.isEmpty && !_isRefreshing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.radio,
                color: Colors.grey,
                size: 64,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No stations available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No radio stations found in your system.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        return _buildStationCard(stations[index]);
      },
    );
  }

  Widget _buildStationCard(Station station) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      color: Colors.black.withValues(alpha: 0.6),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: station.isEnabled == true
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.radio,
                    color:
                        station.isEnabled == true ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name != null
                            ? utf8.decode(station.name!.codeUnits)
                            : 'Unknown Station',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'ID: ${station.id?.toString() ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: station.isEnabled == true
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: station.isEnabled == true
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.red.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              station.isEnabled == true
                                  ? 'ENABLED'
                                  : 'DISABLED',
                              style: TextStyle(
                                color: station.isEnabled == true
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  color: Color.fromARGB(255, 42, 42, 42),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditStationDialog(station);
                        break;
                      case 'clone':
                        _cloneStation(station.id!, station.name ?? 'Unknown');
                        break;
                      case 'delete':
                        _deleteStation(
                            station.id!, station.name ?? 'Unknown Station');
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Station',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clone',
                      child: Row(
                        children: [
                          Icon(Icons.copy, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Clone Station',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Station',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (station.description != null &&
                station.description!.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                utf8.decode(station.description!.codeUnits),
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                ),
              ),
            ],
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Station Details',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow('Short Name', station.shortName ?? 'N/A'),
                  _buildInfoRow('Frontend', station.frontendType ?? 'N/A'),
                  _buildInfoRow('Backend', station.backendType ?? 'N/A'),
                  if (station.genre != null && station.genre!.isNotEmpty)
                    _buildInfoRow(
                        'Genre', utf8.decode(station.genre!.codeUnits)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
