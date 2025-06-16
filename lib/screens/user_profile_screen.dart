import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/user_account.dart';
import 'package:azuracastadmin/models/notification.dart';
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

  @override
  void initState() {
    userAccount = fetchUserAccount(widget.url, widget.apiKey);
    notifications = fetchNotifications(widget.url, widget.apiKey);
    super.initState();
  }

  void _showNotifications() async {
    try {
      final notificationList = await notifications;
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => NotificationPopup(notifications: notificationList),
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
