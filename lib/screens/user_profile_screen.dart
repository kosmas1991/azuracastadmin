import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/user_account.dart';
import 'package:azuracastadmin/models/notification.dart';
import 'package:azuracastadmin/models/users.dart';
import 'package:azuracastadmin/widgets/notification_popup.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class UserProfileScreen extends StatefulWidget {
  final String url;
  final String apiKey;

  const UserProfileScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserAccount> userAccount;
  late Future<List<NotificationItem>> notifications;
  late Future<List<ApiKey>> apiKeys;

  // Password change controllers and state
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChangingPassword = false;

  // API Keys section state
  bool _isApiKeysExpanded = false;

  @override
  void initState() {
    userAccount = fetchUserAccount(widget.url, widget.apiKey);
    notifications = fetchNotifications(widget.url, widget.apiKey);
    apiKeys = fetchApiKeys(widget.url, widget.apiKey);
    super.initState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showNotifications() async {
    try {
      final notificationList = await notifications;
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              NotificationPopup(notifications: notificationList),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _clearPasswordFields();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Current Password *',
                        labelStyle: TextStyle(color: Colors.blue.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // New Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New Password *',
                        labelStyle: TextStyle(color: Colors.green.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        hintText: 'Minimum 8 characters',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password *',
                        labelStyle: TextStyle(color: Colors.orange.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.orange),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearPasswordFields();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isChangingPassword
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _obscureCurrentPassword = true;
      _obscureNewPassword = true;
      _obscureConfirmPassword = true;
    });
  }

  void _changePassword() async {
    // Validation
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Please enter your current password', Colors.red);
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter a new password', Colors.red);
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showSnackBar('New password must be at least 8 characters', Colors.red);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('New passwords do not match', Colors.red);
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final result = await changePassword(
        widget.url,
        widget.apiKey,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() {
        _isChangingPassword = false;
      });

      if (result['success'] == true) {
        _showSnackBar(result['message'], Colors.green);
        _clearPasswordFields();
        Navigator.pop(context);
      } else {
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      setState(() {
        _isChangingPassword = false;
      });
      _showSnackBar('Error changing password: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  void _deleteApiKey(String keyId, String? keyComment) async {
    // Check if this is the currently used API key
    if (widget.apiKey.startsWith(keyId)) {
      _showSnackBar('Cannot delete the currently used API key', Colors.orange);
      return;
    }

    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 42, 42, 42),
        title: Text(
          'Delete API Key',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the API key "${keyComment ?? 'Unnamed'}"?\n\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final result = await deleteApiKey(widget.url, widget.apiKey, keyId);

        if (result['success'] == true) {
          _showSnackBar(result['message'], Colors.green);
          // Refresh the API keys list
          setState(() {
            apiKeys = fetchApiKeys(widget.url, widget.apiKey);
          });
        } else {
          _showSnackBar(result['message'], Colors.red);
        }
      } catch (e) {
        _showSnackBar('Error deleting API key: $e', Colors.red);
      }
    }
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
            'User Profile',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            FutureBuilder<List<NotificationItem>>(
              future: notifications,
              builder: (context, snapshot) {
                int notificationCount = 0;
                if (snapshot.hasData) {
                  notificationCount = snapshot.data!.length;
                }

                return Stack(
                  children: [
                    IconButton(
                      onPressed: _showNotifications,
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
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
                padding: EdgeInsets.all(20),
                child: FutureBuilder<UserAccount>(
                  future: userAccount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var user = snapshot.data!;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            // Avatar Section
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey,
                                child: ClipOval(
                                  child: FadeInImage.memoryNetwork(
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: kTransparentImage,
                                    image: user.avatar?.url128 ??
                                        'https://www.azuracast.com/img/avatar.png',
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            // User Info Card
                            Card(
                              color: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Information',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    _buildInfoRow('Email', user.email ?? 'N/A'),
                                    _buildInfoRow('Name', user.name ?? 'N/A'),
                                    _buildInfoRow('User ID',
                                        user.id?.toString() ?? 'N/A'),
                                    _buildInfoRow(
                                        'Locale', user.locale ?? 'N/A'),
                                    _buildInfoRow(
                                        '24 Hour Time',
                                        user.show24HourTime?.toString() ??
                                            'N/A'),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Roles Card
                            if (user.roles != null && user.roles!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                child: Card(
                                  color: Colors.black38,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Roles',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: user.roles!
                                              .map((role) => Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withValues(
                                                              alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                          color: Colors.blue),
                                                    ),
                                                    child: Text(
                                                      role.name ??
                                                          'Unknown Role',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 20),
                            // Change Password Card
                            Card(
                              color: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Security',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _showChangePasswordDialog,
                                        icon: Icon(Icons.lock_reset),
                                        label: Text('Change Password'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // API Keys Card
                            Card(
                              color: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isApiKeysExpanded =
                                              !_isApiKeysExpanded;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'API Keys',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              FutureBuilder<List<ApiKey>>(
                                                future: apiKeys,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withValues(
                                                                alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: Colors.blue
                                                              .withValues(
                                                                  alpha: 0.3),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${snapshot.data!.length}',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .blue.shade300,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return SizedBox.shrink();
                                                },
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                _isApiKeysExpanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isApiKeysExpanded) ...[
                                      SizedBox(height: 15),
                                      FutureBuilder<List<ApiKey>>(
                                        future: apiKeys,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.isEmpty) {
                                              return Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        'No API keys found',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade400,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }

                                            return Column(
                                              children: snapshot.data!
                                                  .map((apiKey) => Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 12),
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black38,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            color: Colors.blue
                                                                .withValues(
                                                                    alpha: 0.3),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .blue
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                              ),
                                                              child: Icon(
                                                                Icons.key,
                                                                color:
                                                                    Colors.blue,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    apiKey.comment ??
                                                                        'Unnamed API Key',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'ID: ',
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          apiKey.id ??
                                                                              'N/A',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blue.shade300,
                                                                            fontSize:
                                                                                12,
                                                                            fontFamily:
                                                                                'monospace',
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: widget
                                                                            .apiKey
                                                                            .startsWith(apiKey.id ??
                                                                                '')
                                                                        ? Colors.orange.withValues(
                                                                            alpha:
                                                                                0.2)
                                                                        : Colors
                                                                            .green
                                                                            .withValues(alpha: 0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: widget.apiKey.startsWith(apiKey.id ??
                                                                              '')
                                                                          ? Colors.orange.withValues(
                                                                              alpha:
                                                                                  0.3)
                                                                          : Colors
                                                                              .green
                                                                              .withValues(alpha: 0.3),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    widget.apiKey.startsWith(
                                                                            apiKey.id ??
                                                                                '')
                                                                        ? 'Current'
                                                                        : 'Active',
                                                                    style:
                                                                        TextStyle(
                                                                      color: widget.apiKey.startsWith(apiKey.id ??
                                                                              '')
                                                                          ? Colors
                                                                              .orange
                                                                              .shade300
                                                                          : Colors
                                                                              .green
                                                                              .shade300,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                widget.apiKey.startsWith(
                                                                        apiKey.id ??
                                                                            '')
                                                                    ? Tooltip(
                                                                        message:
                                                                            'Cannot delete current API key',
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              32,
                                                                          height:
                                                                              32,
                                                                          child:
                                                                              Icon(
                                                                            Icons.lock,
                                                                            color:
                                                                                Colors.grey.shade600,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : IconButton(
                                                                        onPressed: () => _deleteApiKey(
                                                                            apiKey.id ??
                                                                                '',
                                                                            apiKey.comment),
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .delete_outline,
                                                                          color: Colors
                                                                              .red
                                                                              .shade400,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        tooltip:
                                                                            'Delete API key',
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          minWidth:
                                                                              32,
                                                                          minHeight:
                                                                              32,
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                  .toList(),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.red
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red.shade400,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      'Failed to load API keys: ${snapshot.error}',
                                                      style: TextStyle(
                                                        color:
                                                            Colors.red.shade400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Loading API keys...',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Avatar Service Info Card
                            if (user.avatar != null)
                              Card(
                                color: Colors.black38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Avatar Service',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      _buildInfoRow('Service',
                                          user.avatar!.serviceName ?? 'N/A'),
                                      if (user.avatar!.serviceUrl != null)
                                        _buildInfoRow('Service URL',
                                            user.avatar!.serviceUrl!),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load user profile',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue),
                              ),
                              onPressed: () {
                                setState(() {
                                  userAccount = fetchUserAccount(
                                      widget.url, widget.apiKey);
                                  apiKeys =
                                      fetchApiKeys(widget.url, widget.apiKey);
                                });
                              },
                              child: Text('Retry'),
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
                              'Loading profile...',
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
