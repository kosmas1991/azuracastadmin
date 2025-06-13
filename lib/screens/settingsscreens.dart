import 'dart:async';
import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/api_response.dart';
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
  bool _isEditMode = false;
  bool _isUpdating = false;

  // Text controllers for editable fields
  final _instanceNameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _apiAccessControlController = TextEditingController();
  final _analyticsController = TextEditingController();
  final _historyKeepDaysController = TextEditingController();
  final _homepageRedirectUrlController = TextEditingController();
  final _lastFmApiKeyController = TextEditingController();
  final _publicCustomCssController = TextEditingController();
  final _publicCustomJsController = TextEditingController();
  final _internalCustomCssController = TextEditingController();
  final _mailSenderNameController = TextEditingController();
  final _mailSenderEmailController = TextEditingController();
  final _mailSmtpHostController = TextEditingController();
  final _mailSmtpPortController = TextEditingController();
  final _mailSmtpUsernameController = TextEditingController();
  final _mailSmtpPasswordController = TextEditingController();
  final _avatarServiceController = TextEditingController();
  final _avatarDefaultUrlController = TextEditingController();
  final _acmeEmailController = TextEditingController();
  final _acmeDomainsController = TextEditingController();
  final _ipSourceController = TextEditingController();
  final _geoliteLicenseKeyController = TextEditingController();

  // Boolean state variables for switches
  bool _preferBrowserUrl = false;
  bool _useRadioProxy = false;
  bool _alwaysUseSsl = false;
  bool _enableStaticNowplaying = false;
  bool _checkForUpdates = false;
  bool _hideAlbumArt = false;
  bool _useExternalAlbumArtWhenProcessingMedia = false;
  bool _useExternalAlbumArtInApis = false;
  bool _hideProductName = false;
  bool _backupEnabled = false;
  bool _backupExcludeMedia = false;
  bool _syncDisabled = false;
  bool _enableAdvancedFeatures = false;
  bool _mailEnabled = false;
  bool _mailSmtpSecure = false;

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
    // Dispose all text controllers
    _instanceNameController.dispose();
    _baseUrlController.dispose();
    _apiAccessControlController.dispose();
    _analyticsController.dispose();
    _historyKeepDaysController.dispose();
    _homepageRedirectUrlController.dispose();
    _lastFmApiKeyController.dispose();
    _publicCustomCssController.dispose();
    _publicCustomJsController.dispose();
    _internalCustomCssController.dispose();
    _mailSenderNameController.dispose();
    _mailSenderEmailController.dispose();
    _mailSmtpHostController.dispose();
    _mailSmtpPortController.dispose();
    _mailSmtpUsernameController.dispose();
    _mailSmtpPasswordController.dispose();
    _avatarServiceController.dispose();
    _avatarDefaultUrlController.dispose();
    _acmeEmailController.dispose();
    _acmeDomainsController.dispose();
    _ipSourceController.dispose();
    _geoliteLicenseKeyController.dispose();
    super.dispose();
  }

  void _populateControllers(SettingsModel data) {
    _instanceNameController.text = data.instanceName ?? '';
    _baseUrlController.text = data.baseUrl ?? '';
    _apiAccessControlController.text = data.apiAccessControl ?? '';
    _analyticsController.text = data.analytics ?? '';
    _historyKeepDaysController.text = data.historyKeepDays?.toString() ?? '';
    _homepageRedirectUrlController.text = data.homepageRedirectUrl ?? '';
    _lastFmApiKeyController.text = data.lastFmApiKey ?? '';
    _publicCustomCssController.text = data.publicCustomCss?.toString() ?? '';
    _publicCustomJsController.text = data.publicCustomJs?.toString() ?? '';
    _internalCustomCssController.text =
        data.internalCustomCss?.toString() ?? '';
    _mailSenderNameController.text = data.mailSenderName ?? '';
    _mailSenderEmailController.text = data.mailSenderEmail ?? '';
    _mailSmtpHostController.text = data.mailSmtpHost ?? '';
    _mailSmtpPortController.text = data.mailSmtpPort?.toString() ?? '';
    _mailSmtpUsernameController.text = data.mailSmtpUsername ?? '';
    _mailSmtpPasswordController.text = data.mailSmtpPassword ?? '';
    _avatarServiceController.text = data.avatarService ?? '';
    _avatarDefaultUrlController.text = data.avatarDefaultUrl?.toString() ?? '';
    _acmeEmailController.text = data.acmeEmail ?? '';
    _acmeDomainsController.text = data.acmeDomains ?? '';
    _ipSourceController.text = data.ipSource ?? '';
    _geoliteLicenseKeyController.text =
        data.geoliteLicenseKey?.toString() ?? '';

    // Update boolean values
    _preferBrowserUrl = data.preferBrowserUrl ?? false;
    _useRadioProxy = data.useRadioProxy ?? false;
    _alwaysUseSsl = data.alwaysUseSsl ?? false;
    _enableStaticNowplaying = data.enableStaticNowplaying ?? false;
    _checkForUpdates = data.checkForUpdates ?? false;
    _hideAlbumArt = data.hideAlbumArt ?? false;
    _useExternalAlbumArtWhenProcessingMedia =
        data.useExternalAlbumArtWhenProcessingMedia ?? false;
    _useExternalAlbumArtInApis = data.useExternalAlbumArtInApis ?? false;
    _hideProductName = data.hideProductName ?? false;
    _backupEnabled = data.backupEnabled ?? false;
    _backupExcludeMedia = data.backupExcludeMedia ?? false;
    _syncDisabled = data.syncDisabled ?? false;
    _enableAdvancedFeatures = data.enableAdvancedFeatures ?? false;
    _mailEnabled = data.mailEnabled ?? false;
    _mailSmtpSecure = data.mailSmtpSecure ?? false;
  }

  Future<void> _refreshSettings() async {
    setState(() {
      settings = fetchSettings(widget.url, 'admin/settings', widget.apiKey);
    });
  }

  Future<void> _updateSettings() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withAlpha(230),
          title: Text(
            'Confirm Changes',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to update the server settings? This action will modify the server configuration.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Update Settings',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Prepare settings data
      Map<String, dynamic> settingsData = {
        'instance_name': _instanceNameController.text.trim(),
        'base_url': _baseUrlController.text.trim(),
        'api_access_control': _apiAccessControlController.text.trim(),
        'analytics': _analyticsController.text.trim(),
        'history_keep_days': int.tryParse(_historyKeepDaysController.text) ?? 0,
        'homepage_redirect_url': _homepageRedirectUrlController.text.trim(),
        'last_fm_api_key': _lastFmApiKeyController.text.trim(),
        'public_custom_css': _publicCustomCssController.text.trim(),
        'public_custom_js': _publicCustomJsController.text.trim(),
        'internal_custom_css': _internalCustomCssController.text.trim(),
        'mail_sender_name': _mailSenderNameController.text.trim(),
        'mail_sender_email': _mailSenderEmailController.text.trim(),
        'mail_smtp_host': _mailSmtpHostController.text.trim(),
        'mail_smtp_port': int.tryParse(_mailSmtpPortController.text) ?? 0,
        'mail_smtp_username': _mailSmtpUsernameController.text.trim(),
        'mail_smtp_password': _mailSmtpPasswordController.text.trim(),
        'avatar_service': _avatarServiceController.text.trim(),
        'avatar_default_url': _avatarDefaultUrlController.text.trim(),
        'acme_email': _acmeEmailController.text.trim(),
        'acme_domains': _acmeDomainsController.text.trim(),
        'ip_source': _ipSourceController.text.trim(),
        'geolite_license_key': _geoliteLicenseKeyController.text.trim(),
        'prefer_browser_url': _preferBrowserUrl,
        'use_radio_proxy': _useRadioProxy,
        'always_use_ssl': _alwaysUseSsl,
        'enable_static_nowplaying': _enableStaticNowplaying,
        'check_for_updates': _checkForUpdates,
        'hide_album_art': _hideAlbumArt,
        'use_external_album_art_when_processing_media':
            _useExternalAlbumArtWhenProcessingMedia,
        'use_external_album_art_in_apis': _useExternalAlbumArtInApis,
        'hide_product_name': _hideProductName,
        'backup_enabled': _backupEnabled,
        'backup_exclude_media': _backupExcludeMedia,
        'sync_disabled': _syncDisabled,
        'enable_advanced_features': _enableAdvancedFeatures,
        'mail_enabled': _mailEnabled,
        'mail_smtp_secure': _mailSmtpSecure,
      };

      ApiResponse response = await updateSettings(
        url: widget.url,
        apiKey: widget.apiKey,
        settingsData: settingsData,
      );

      setState(() {
        _isUpdating = false;
        if (response.success) {
          _isEditMode = false;
        }
      });

      // Show feedback
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message,
            style: TextStyle(
              color: response.success ? Colors.white : Colors.white,
            ),
          ),
          backgroundColor: response.success ? Colors.green : Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      // Refresh settings if successful
      if (response.success) {
        await _refreshSettings();
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update settings: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  Widget _buildEditableTextRow(String label, TextEditingController controller,
      {IconData? icon,
      TextInputType? keyboardType,
      int? maxLines,
      String? hintText}) {
    if (!_isEditMode) {
      String displayValue = controller.text.isEmpty ? 'Not set' : controller.text;
      return _buildSettingRow(label, displayValue, icon: icon, copyable: displayValue != 'Not set');
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withAlpha(76)),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: keyboardType,
                maxLines: maxLines ?? 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  hintText: hintText,
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableBooleanRow(
      String label, bool value, Function(bool) onChanged,
      {IconData? icon}) {
    if (!_isEditMode) {
      return _buildBooleanRow(label, value, icon: icon);
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
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.blue,
                  activeTrackColor: Colors.blue.withAlpha(102),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withAlpha(102),
                ),
                SizedBox(width: 8),
                Text(
                  value ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: value ? Colors.green.shade300 : Colors.red.shade300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    if (_isEditMode && label.contains('SMTP Password')) {
      return _buildEditableTextRow('SMTP Password', _mailSmtpPasswordController,
          icon: icon, keyboardType: TextInputType.visiblePassword);
    }

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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshSettings,
              tooltip: 'Refresh Settings',
            ),
            IconButton(
              icon: Icon(_isEditMode ? Icons.close : Icons.edit),
              onPressed: () {
                if (_isEditMode) {
                  setState(() {
                    _isEditMode = false;
                  });
                } else {
                  setState(() {
                    _isEditMode = true;
                  });
                }
              },
              tooltip: _isEditMode ? 'Cancel Edit' : 'Edit Settings',
            ),
            if (_isEditMode) ...[
              IconButton(
                icon: _isUpdating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.save),
                onPressed: _isUpdating ? null : _updateSettings,
                tooltip: 'Save Changes',
              ),
            ],
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

                  // Populate controllers when data is first loaded or when entering edit mode
                  if (_instanceNameController.text.isEmpty ||
                      _instanceNameController.text != (data.instanceName ?? '')) {
                    _populateControllers(data);
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 16),
                      children: [
                        // Edit Mode Indicator
                        if (_isEditMode) ...[
                          Container(
                            margin: EdgeInsets.all(16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.blue.withAlpha(76)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit Mode Active',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'You can now modify the server settings. Use the Save button to apply changes.',
                                        style: TextStyle(
                                          color: Colors.blue.shade300,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Server Information Section
                        _buildSectionHeader(
                            'Server Information', Icons.dns, Colors.blue),
                        _buildSettingCard([
                          _buildEditableTextRow(
                              'Instance Name', _instanceNameController,
                              icon: Icons.label),
                          _buildEditableTextRow('Base URL', _baseUrlController,
                              icon: Icons.link,
                              hintText: 'https://example.com'),
                          _buildSettingRow('Unique Identifier',
                              data.appUniqueIdentifier ?? 'Not set',
                              icon: Icons.fingerprint, copyable: true),
                          _buildEditableBooleanRow(
                              'Prefer Browser URL', _preferBrowserUrl, (value) {
                            setState(() => _preferBrowserUrl = value);
                          }, icon: Icons.web),
                          _buildEditableBooleanRow(
                              'Use Radio Proxy', _useRadioProxy, (value) {
                            setState(() => _useRadioProxy = value);
                          }, icon: Icons.router),
                        ]),

                        SizedBox(height: 8),

                        // Update Status
                        if (data.updateResults != null) ...[
                          _buildSectionHeader('System Updates',
                              Icons.system_update, Colors.green),
                          _buildUpdateStatusCard(data.updateResults),
                          _buildSettingCard([
                            _buildEditableBooleanRow(
                                'Check for Updates', _checkForUpdates, (value) {
                              setState(() => _checkForUpdates = value);
                            }, icon: Icons.update),
                            _buildDateRow(
                                'Last Update Check', data.updateLastRun,
                                icon: Icons.schedule),
                          ]),
                          SizedBox(height: 8),
                        ],

                        // Custom CSS/JS Section
                        _buildSectionHeader('Custom CSS & JavaScript',
                            Icons.code, Colors.deepPurple),
                        _buildSettingCard([
                          _buildEditableTextRow(
                              'Public Custom CSS', _publicCustomCssController,
                              icon: Icons.style, maxLines: 3),
                          _buildEditableTextRow(
                              'Public Custom JS', _publicCustomJsController,
                              icon: Icons.javascript, maxLines: 3),
                          _buildEditableTextRow('Internal Custom CSS',
                              _internalCustomCssController,
                              icon: Icons.admin_panel_settings, maxLines: 3),
                        ]),

                        SizedBox(height: 8),

                        // Security & Access Section
                        _buildSectionHeader(
                            'Security & Access', Icons.security, Colors.orange),
                        _buildSettingCard([
                          _buildEditableBooleanRow(
                              'Always Use SSL', _alwaysUseSsl, (value) {
                            setState(() => _alwaysUseSsl = value);
                          }, icon: Icons.lock),
                          _buildEditableTextRow(
                              'API Access Control', _apiAccessControlController,
                              icon: Icons.api),
                          _buildEditableTextRow(
                              'IP Source', _ipSourceController,
                              icon: Icons.location_on),
                          _buildEditableBooleanRow('Enable Advanced Features',
                              _enableAdvancedFeatures, (value) {
                            setState(() => _enableAdvancedFeatures = value);
                          }, icon: Icons.settings),
                        ]),

                        SizedBox(height: 8),

                        // Media & Content Section
                        _buildSectionHeader('Media & Content',
                            Icons.library_music, Colors.purple),
                        _buildSettingCard([
                          _buildEditableTextRow(
                              'History Keep Days', _historyKeepDaysController,
                              icon: Icons.history,
                              keyboardType: TextInputType.number,
                              hintText: '0 = Forever'),
                          _buildEditableBooleanRow(
                              'Hide Album Art', _hideAlbumArt, (value) {
                            setState(() => _hideAlbumArt = value);
                          }, icon: Icons.image),
                          _buildEditableBooleanRow(
                              'Use External Album Art (Processing)',
                              _useExternalAlbumArtWhenProcessingMedia, (value) {
                            setState(() =>
                                _useExternalAlbumArtWhenProcessingMedia =
                                    value);
                          }, icon: Icons.cloud_download),
                          _buildEditableBooleanRow(
                              'Use External Album Art (APIs)',
                              _useExternalAlbumArtInApis, (value) {
                            setState(() => _useExternalAlbumArtInApis = value);
                          }, icon: Icons.api),
                          _buildEditableTextRow(
                              'LastFM API Key', _lastFmApiKeyController,
                              icon: Icons.music_note),
                          _buildEditableTextRow('Homepage Redirect URL',
                              _homepageRedirectUrlController,
                              icon: Icons.home),
                        ]),

                        SizedBox(height: 8),

                        // Analytics & Monitoring Section
                        _buildSectionHeader('Analytics & Monitoring',
                            Icons.analytics, Colors.teal),
                        _buildSettingCard([
                          _buildEditableTextRow(
                              'Analytics Level', _analyticsController,
                              icon: Icons.bar_chart),
                          _buildEditableBooleanRow('Enable Static Now Playing',
                              _enableStaticNowplaying, (value) {
                            setState(() => _enableStaticNowplaying = value);
                          }, icon: Icons.radio),
                          _buildEditableBooleanRow(
                              'Hide Product Name', _hideProductName, (value) {
                            setState(() => _hideProductName = value);
                          }, icon: Icons.visibility_off),
                          _buildEditableBooleanRow(
                              'Sync Disabled', _syncDisabled, (value) {
                            setState(() => _syncDisabled = value);
                          }, icon: Icons.sync),
                          _buildDateRow('Last Sync Run', data.syncLastRun,
                              icon: Icons.sync),
                        ]),

                        SizedBox(height: 8),

                        // Backup Configuration Section
                        _buildSectionHeader('Backup Configuration',
                            Icons.backup, Colors.indigo),
                        _buildSettingCard([
                          _buildEditableBooleanRow(
                              'Backup Enabled', _backupEnabled, (value) {
                            setState(() => _backupEnabled = value);
                          }, icon: Icons.backup),
                          _buildSettingRow(
                              'Keep Copies', '${data.backupKeepCopies ?? 0}',
                              icon: Icons.content_copy),
                          _buildEditableBooleanRow(
                              'Exclude Media', _backupExcludeMedia, (value) {
                            setState(() => _backupExcludeMedia = value);
                          }, icon: Icons.library_music),
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
                          _buildEditableBooleanRow('Mail Enabled', _mailEnabled,
                              (value) {
                            setState(() => _mailEnabled = value);
                          }, icon: Icons.email),
                          _buildEditableTextRow(
                              'Sender Name', _mailSenderNameController,
                              icon: Icons.person),
                          _buildEditableTextRow(
                              'Sender Email', _mailSenderEmailController,
                              icon: Icons.email),
                          _buildEditableTextRow(
                              'SMTP Host', _mailSmtpHostController,
                              icon: Icons.dns),
                          _buildEditableTextRow(
                              'SMTP Port', _mailSmtpPortController,
                              icon: Icons.router,
                              keyboardType: TextInputType.number,
                              hintText: 'e.g., 587, 465, 25'),
                          _buildEditableTextRow(
                              'SMTP Username', _mailSmtpUsernameController,
                              icon: Icons.account_circle),
                          _buildPasswordRow(
                              'SMTP Password', data.mailSmtpPassword,
                              icon: Icons.lock),
                          _buildEditableBooleanRow(
                              'SMTP Secure', _mailSmtpSecure, (value) {
                            setState(() => _mailSmtpSecure = value);
                          }, icon: Icons.lock),
                        ]),

                        SizedBox(height: 8),

                        // Additional Configuration Section
                        _buildSectionHeader('Additional Configuration',
                            Icons.settings, Colors.grey),
                        _buildSettingCard([
                          _buildEditableTextRow(
                              'Avatar Service', _avatarServiceController,
                              icon: Icons.account_circle),
                          _buildEditableTextRow(
                              'Avatar Default URL', _avatarDefaultUrlController,
                              icon: Icons.image),
                          _buildEditableTextRow(
                              'ACME Email', _acmeEmailController,
                              icon: Icons.email),
                          _buildEditableTextRow(
                              'ACME Domains', _acmeDomainsController,
                              icon: Icons.domain),
                          _buildDateRow(
                              'Setup Complete Time', data.setupCompleteTime,
                              icon: Icons.check_circle),
                          _buildEditableTextRow('GeoLite License Key',
                              _geoliteLicenseKeyController,
                              icon: Icons.location_on),
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
        floatingActionButton: _isEditMode
            ? FloatingActionButton.extended(
                onPressed: _isUpdating ? null : _updateSettings,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: _isUpdating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.save),
                label: Text(_isUpdating ? 'Saving...' : 'Save Changes'),
              )
            : null,
      ),
    );
  }
}
