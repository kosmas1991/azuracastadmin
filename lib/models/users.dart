import 'dart:convert';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  String? email;
  String? name;
  String? locale;
  dynamic show24HourTime;
  dynamic twoFactorSecret;
  int? createdAt;
  int? updatedAt;
  List<Role>? roles;
  List<ApiKey>? apiKeys;
  List<dynamic>? passkeys;
  int? id;
  bool? isMe;
  Avatar? avatar;
  Links? links;

  Users({
    this.email,
    this.name,
    this.locale,
    this.show24HourTime,
    this.twoFactorSecret,
    this.createdAt,
    this.updatedAt,
    this.roles,
    this.apiKeys,
    this.passkeys,
    this.id,
    this.isMe,
    this.avatar,
    this.links,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        email: json["email"],
        name: json["name"],
        locale: json["locale"],
        show24HourTime: json["show_24_hour_time"],
        twoFactorSecret: json["two_factor_secret"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        roles: json["roles"] == null
            ? []
            : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
        apiKeys: json["api_keys"] == null
            ? []
            : List<ApiKey>.from(
                json["api_keys"]!.map((x) => ApiKey.fromJson(x))),
        passkeys: json["passkeys"] == null
            ? []
            : List<dynamic>.from(json["passkeys"]!.map((x) => x)),
        id: json["id"],
        isMe: json["is_me"],
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "locale": locale,
        "show_24_hour_time": show24HourTime,
        "two_factor_secret": twoFactorSecret,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "roles": roles == null
            ? []
            : List<dynamic>.from(roles!.map((x) => x.toJson())),
        "api_keys": apiKeys == null
            ? []
            : List<dynamic>.from(apiKeys!.map((x) => x.toJson())),
        "passkeys":
            passkeys == null ? [] : List<dynamic>.from(passkeys!.map((x) => x)),
        "id": id,
        "is_me": isMe,
        "avatar": avatar?.toJson(),
        "links": links?.toJson(),
      };
}

class ApiKey {
  String? user;
  String? comment;
  String? id;
  ApiKeyLinks? links;

  ApiKey({
    this.user,
    this.comment,
    this.id,
    this.links,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        user: json["user"],
        comment: json["comment"],
        id: json["id"],
        links:
            json["links"] == null ? null : ApiKeyLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "comment": comment,
        "id": id,
        "links": links?.toJson(),
      };
}

class ApiKeyLinks {
  String? self;

  ApiKeyLinks({
    this.self,
  });

  factory ApiKeyLinks.fromJson(Map<String, dynamic> json) => ApiKeyLinks(
        self: json["self"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
      };
}

class Links {
  String? self;
  String? masquerade;

  Links({
    this.self,
    this.masquerade,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
        masquerade: json["masquerade"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
        "masquerade": masquerade,
      };
}

class Role {
  int? id;
  String? name;
  Permissions? permissions;

  Role({
    this.id,
    this.name,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        permissions: json["permissions"] == null
            ? null
            : Permissions.fromJson(json["permissions"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "permissions": permissions?.toJson(),
      };
}

class Permissions {
  List<String>? global;
  dynamic station;

  Permissions({
    this.global,
    this.station,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
        global: json["global"] == null
            ? []
            : List<String>.from(json["global"]!.map((x) => x)),
        station: json["station"],
      );

  Map<String, dynamic> toJson() => {
        "global":
            global == null ? [] : List<dynamic>.from(global!.map((x) => x)),
        "station": station,
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
