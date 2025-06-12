// To parse this JSON data, do
//
//     final userAccount = userAccountFromJson(jsonString);

import 'dart:convert';

UserAccount userAccountFromJson(String str) => UserAccount.fromJson(json.decode(str));

String userAccountToJson(UserAccount data) => json.encode(data.toJson());

class UserAccount {
  String? email;
  String? name;
  String? locale;
  bool? show24HourTime;
  int? id;
  List<Role>? roles;
  Avatar? avatar;

  UserAccount({
    this.email,
    this.name,
    this.locale,
    this.show24HourTime,
    this.id,
    this.roles,
    this.avatar,
  });

  UserAccount copyWith({
    String? email,
    String? name,
    String? locale,
    bool? show24HourTime,
    int? id,
    List<Role>? roles,
    Avatar? avatar,
  }) =>
      UserAccount(
        email: email ?? this.email,
        name: name ?? this.name,
        locale: locale ?? this.locale,
        show24HourTime: show24HourTime ?? this.show24HourTime,
        id: id ?? this.id,
        roles: roles ?? this.roles,
        avatar: avatar ?? this.avatar,
      );

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        email: json["email"],
        name: json["name"],
        locale: json["locale"],
        show24HourTime: json["show_24_hour_time"],
        id: json["id"],
        roles: json["roles"] == null ? [] : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "locale": locale,
        "show_24_hour_time": show24HourTime,
        "id": id,
        "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x.toJson())),
        "avatar": avatar?.toJson(),
      };
}

class Avatar {
  String? url32;
  String? url64;
  String? url128;
  String? serviceName;
  String? serviceUrl;

  Avatar({
    this.url32,
    this.url64,
    this.url128,
    this.serviceName,
    this.serviceUrl,
  });

  Avatar copyWith({
    String? url32,
    String? url64,
    String? url128,
    String? serviceName,
    String? serviceUrl,
  }) =>
      Avatar(
        url32: url32 ?? this.url32,
        url64: url64 ?? this.url64,
        url128: url128 ?? this.url128,
        serviceName: serviceName ?? this.serviceName,
        serviceUrl: serviceUrl ?? this.serviceUrl,
      );

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        url32: json["url_32"],
        url64: json["url_64"],
        url128: json["url_128"],
        serviceName: json["service_name"],
        serviceUrl: json["service_url"],
      );

  Map<String, dynamic> toJson() => {
        "url_32": url32,
        "url_64": url64,
        "url_128": url128,
        "service_name": serviceName,
        "service_url": serviceUrl,
      };
}

class Role {
  int? id;
  String? name;

  Role({
    this.id,
    this.name,
  });

  Role copyWith({
    int? id,
    String? name,
  }) =>
      Role(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
