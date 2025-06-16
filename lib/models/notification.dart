import 'dart:convert';

List<NotificationItem> notificationFromJson(String str) =>
    List<NotificationItem>.from(
        json.decode(str).map((x) => NotificationItem.fromJson(x)));

String notificationToJson(List<NotificationItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationItem {
  String? title;
  String? body;
  String? type;
  String? actionLabel;
  String? actionUrl;

  NotificationItem({
    this.title,
    this.body,
    this.type,
    this.actionLabel,
    this.actionUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        title: json["title"],
        body: json["body"],
        type: json["type"],
        actionLabel: json["actionLabel"],
        actionUrl: json["actionUrl"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "body": body,
        "type": type,
        "actionLabel": actionLabel,
        "actionUrl": actionUrl,
      };
}
