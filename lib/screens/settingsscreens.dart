import 'dart:async';
import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/settings.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ServerSettingsScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  const ServerSettingsScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen>
    with TickerProviderStateMixin {
  late Future<SettingsModel> settings;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showBackupOutput = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    settings = fetchSettings(widget.url, 'admin/settings', widget.apiKey);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [iconColor.withAlpha(204), iconColor.withAlpha(153)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(76),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(26),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSettingRow(String label, String value,
      {IconData? icon, bool copyable = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blue.shade300, size: 16),
            SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (copyable && value.isNotEmpty) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      color: Colors.blue.shade300,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool? value, {IconData? icon}) {
    return _buildSettingRow(
      label,
      value == null ? 'Not set' : (value ? 'Enabled' : 'Disabled'),
      icon: icon,
    );
  }

  Widget _buildDateRow(String label, int? timestamp, {IconData? icon}) {
    String formattedDate = 'Not set';
    if (timestamp != null) {
      formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      );
    }
    return _buildSettingRow(label, formattedDate, icon: icon);
  }

  Widget _buildPasswordRow(String label, String? value, {IconData? icon}) {
    String displayValue = value ?? 'Not set';
    if (value != null && value.isNotEmpty && !_showPassword) {
      displayValue = '*' * value.length;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blue.shade300, size: 16),
            SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (value != null && value.isNotEmpty) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue.shade300,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      color: Colors.blue.shade300,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusCard(UpdateResults? updateResults) {
    if (updateResults == null) return SizedBox.shrink();

    bool upToDate = updateResults.currentRelease == updateResults.latestRelease;
    Color statusColor = upToDate ? Colors.green : Colors.orange;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withAlpha(76),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                upToDate ? Icons.check_circle : Icons.update,
                color: statusColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  upToDate ? 'System Up to Date' : 'Update Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSettingRow(
              'Current Version', updateResults.currentRelease ?? 'Unknown'),
          _buildSettingRow(
              'Latest Version', updateResults.latestRelease ?? 'Unknown'),
          if (updateResults.rollingUpdatesAvailable != null &&
              updateResults.rollingUpdatesAvailable! > 0)
            _buildSettingRow('Rolling Updates',
                '${updateResults.rollingUpdatesAvailable} available'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(204),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Server Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
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
                      Colors.black.withAlpha(153),
                      Colors.black.withAlpha(102),
                      Colors.black.withAlpha(153),
                    ],
                  ),
                ),
              ),
              FutureBuilder<SettingsModel>(
                future: settings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            'Loading settings...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
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
                            'Error loading settings',
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

                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        'No settings data available',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  SettingsModel data = snapshot.data!;

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 16),
                      children: [
                        // Server Information Section
                        _buildSectionHeader(
                            'Server Information', Icons.dns, Colors.blue),
                        _buildSettingCard([
                          _buildSettingRow(
                              'Instance Name', data.instanceName ?? 'Not set',
                              icon: Icons.label, copyable: true),
                          _buildSettingRow(
                              'Base URL', data.baseUrl ?? 'Not set',
                              icon: Icons.link, copyable: true),
                          _buildSettingRow('Unique Identifier',
                              data.appUniqueIdentifier ?? 'Not set',
                              icon: Icons.fingerprint, copyable: true),
                          _buildBooleanRow(
                              'Prefer Browser URL', data.preferBrowserUrl,
                              icon: Icons.web),
                          _buildBooleanRow(
                              'Use Radio Proxy', data.useRadioProxy,
                              icon: Icons.router),
                        ]),

                        SizedBox(height: 8),

                        // Update Status
                        if (data.updateResults != null) ...[
                          _buildSectionHeader('System Updates',
                              Icons.system_update, Colors.green),
                          _buildUpdateStatusCard(data.updateResults),
                          _buildSettingCard([
                            _buildBooleanRow(
                                'Check for Updates', data.checkForUpdates,
                                icon: Icons.update),
                            _buildDateRow(
                                'Last Update Check', data.updateLastRun,
                                icon: Icons.schedule),
                          ]),
                          SizedBox(height: 8),
                        ],

                        // Security & Access Section
                        _buildSectionHeader(
                            'Security & Access', Icons.security, Colors.orange),
                        _buildSettingCard([
                          _buildBooleanRow('Always Use SSL', data.alwaysUseSsl,
                              icon: Icons.lock),
                          _buildSettingRow('API Access Control',
                              data.apiAccessControl ?? 'Not set',
                              icon: Icons.api),
                          _buildSettingRow(
                              'IP Source', data.ipSource ?? 'Not set',
                              icon: Icons.location_on),
                          _buildBooleanRow('Enable Advanced Features',
                              data.enableAdvancedFeatures,
                              icon: Icons.settings),
                        ]),

                        SizedBox(height: 8),

                        // Media & Content Section
                        _buildSectionHeader('Media & Content',
                            Icons.library_music, Colors.purple),
                        _buildSettingCard([
                          _buildSettingRow(
                              'History Keep Days',
                              data.historyKeepDays == 0
                                  ? 'Forever'
                                  : '${data.historyKeepDays} days',
                              icon: Icons.history),
                          _buildBooleanRow('Hide Album Art', data.hideAlbumArt,
                              icon: Icons.image),
                          _buildBooleanRow(
                              'Use External Album Art (Processing)',
                              data.useExternalAlbumArtWhenProcessingMedia,
                              icon: Icons.cloud_download),
                          _buildBooleanRow('Use External Album Art (APIs)',
                              data.useExternalAlbumArtInApis,
                              icon: Icons.api),
                          _buildSettingRow(
                              'LastFM API Key', data.lastFmApiKey ?? 'Not set',
                              icon: Icons.music_note, copyable: true),
                          _buildSettingRow('Homepage Redirect URL',
                              data.homepageRedirectUrl ?? 'Not set',
                              icon: Icons.home, copyable: true),
                        ]),

                        SizedBox(height: 8),

                        // Analytics & Monitoring Section
                        _buildSectionHeader('Analytics & Monitoring',
                            Icons.analytics, Colors.teal),
                        _buildSettingCard([
                          _buildSettingRow(
                              'Analytics Level', data.analytics ?? 'Not set',
                              icon: Icons.bar_chart),
                          _buildBooleanRow('Enable Static Now Playing',
                              data.enableStaticNowplaying,
                              icon: Icons.radio),
                          _buildBooleanRow(
                              'Hide Product Name', data.hideProductName,
                              icon: Icons.visibility_off),
                          _buildBooleanRow('Sync Disabled', data.syncDisabled,
                              icon: Icons.sync),
                          _buildDateRow('Last Sync Run', data.syncLastRun,
                              icon: Icons.sync),
                        ]),

                        SizedBox(height: 8),

                        // Backup Configuration Section
                        _buildSectionHeader('Backup Configuration',
                            Icons.backup, Colors.indigo),
                        _buildSettingCard([
                          _buildBooleanRow('Backup Enabled', data.backupEnabled,
                              icon: Icons.backup),
                          _buildSettingRow(
                              'Keep Copies', '${data.backupKeepCopies ?? 0}',
                              icon: Icons.content_copy),
                          _buildBooleanRow(
                              'Exclude Media', data.backupExcludeMedia,
                              icon: Icons.library_music),
                          _buildSettingRow('Storage Location ID',
                              '${data.backupStorageLocation ?? 0}',
                              icon: Icons.storage),
                          _buildSettingRow('Backup Format',
                              data.backupFormat?.toString() ?? 'Not set',
                              icon: Icons.archive),
                          _buildDateRow('Last Backup Run', data.backupLastRun,
                              icon: Icons.schedule),
                          if (data.backupLastOutput != null &&
                              data.backupLastOutput!.isNotEmpty) ...[
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showBackupOutput = !_showBackupOutput;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.blue.withAlpha(76)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.terminal,
                                        color: Colors.blue.shade300, size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _showBackupOutput
                                            ? 'Hide Backup Output'
                                            : 'Show Backup Output',
                                        style: TextStyle(
                                          color: Colors.blue.shade300,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _showBackupOutput
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.blue.shade300,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showBackupOutput) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(204),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey.withAlpha(76)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Backup Output Log',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                text: data.backupLastOutput!));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Backup output copied to clipboard'),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            color: Colors.blue.shade300,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 200),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          utf8.decode(
                                              data.backupLastOutput!.codeUnits),
                                          style: TextStyle(
                                            color: Colors.green.shade300,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ]),

                        SizedBox(height: 8),

                        // Mail Configuration Section
                        _buildSectionHeader(
                            'Mail Configuration', Icons.email, Colors.red),
                        _buildSettingCard([
                          _buildBooleanRow('Mail Enabled', data.mailEnabled,
                              icon: Icons.email),
                          _buildSettingRow(
                              'Sender Name', data.mailSenderName ?? 'Not set',
                              icon: Icons.person, copyable: true),
                          _buildSettingRow(
                              'Sender Email', data.mailSenderEmail ?? 'Not set',
                              icon: Icons.email, copyable: true),
                          _buildSettingRow(
                              'SMTP Host', data.mailSmtpHost ?? 'Not set',
                              icon: Icons.dns, copyable: true),
                          _buildSettingRow(
                              'SMTP Port', '${data.mailSmtpPort ?? 0}',
                              icon: Icons.router),
                          _buildSettingRow('SMTP Username',
                              data.mailSmtpUsername ?? 'Not set',
                              icon: Icons.account_circle, copyable: true),
                          _buildPasswordRow(
                              'SMTP Password', data.mailSmtpPassword,
                              icon: Icons.lock),
                          _buildBooleanRow('SMTP Secure', data.mailSmtpSecure,
                              icon: Icons.lock),
                        ]),

                        SizedBox(height: 8),

                        // Additional Configuration Section
                        _buildSectionHeader('Additional Configuration',
                            Icons.settings, Colors.grey),
                        _buildSettingCard([
                          _buildSettingRow(
                              'Avatar Service', data.avatarService ?? 'Not set',
                              icon: Icons.account_circle),
                          _buildSettingRow('Avatar Default URL',
                              data.avatarDefaultUrl ?? 'Not set',
                              icon: Icons.image, copyable: true),
                          _buildSettingRow(
                              'ACME Email', data.acmeEmail ?? 'Not set',
                              icon: Icons.email, copyable: true),
                          _buildSettingRow(
                              'ACME Domains', data.acmeDomains ?? 'Not set',
                              icon: Icons.domain, copyable: true),
                          _buildDateRow(
                              'Setup Complete Time', data.setupCompleteTime,
                              icon: Icons.check_circle),
                          _buildDateRow('GeoLite Last Run', data.geoliteLastRun,
                              icon: Icons.location_on),
                        ]),
                      ],
                    ),
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
