import 'package:flutter/material.dart';
import 'package:azuracastadmin/models/notification.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPopup extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationPopup({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 42, 42, 42),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.withAlpha(76)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Notifications List
            Flexible(
              child: notifications.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(context, notification);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type?.toLowerCase()) {
      case 'error':
        typeColor = Colors.red;
        typeIcon = Icons.error;
        break;
      case 'warning':
        typeColor = Colors.orange;
        typeIcon = Icons.warning;
        break;
      case 'success':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle;
        break;
      case 'info':
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.info;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withAlpha(76)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and type icon
            Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title ?? 'Notification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (notification.body != null && notification.body!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                notification.body!,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],

            // Action button
            if (notification.actionLabel != null && 
                notification.actionLabel!.isNotEmpty) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleActionUrl(notification.actionUrl),
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text(notification.actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleActionUrl(String? actionUrl) async {
    if (actionUrl != null && actionUrl.isNotEmpty) {
      try {
        final Uri url = Uri.parse(actionUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }
}
