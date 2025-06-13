import 'dart:convert';

List<RoleModel> rolesFromJson(String str) =>
    List<RoleModel>.from(json.decode(str).map((x) => RoleModel.fromJson(x)));

String rolesToJson(List<RoleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RoleModel {
  int? id;
  String? name;
  RolePermissions? permissions;
  bool? isSuperAdmin;
  RoleLinks? links;

  RoleModel({
    this.id,
    this.name,
    this.permissions,
    this.isSuperAdmin,
    this.links,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        id: json["id"],
        name: json["name"],
        permissions: json["permissions"] == null
            ? null
            : RolePermissions.fromJson(json["permissions"]),
        isSuperAdmin: json["is_super_admin"],
        links: json["links"] == null ? null : RoleLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "permissions": permissions?.toJson(),
        "is_super_admin": isSuperAdmin,
        "links": links?.toJson(),
      };
}

class RoleLinks {
  String? self;

  RoleLinks({
    this.self,
  });

  factory RoleLinks.fromJson(Map<String, dynamic> json) => RoleLinks(
        self: json["self"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
      };
}

class RolePermissions {
  List<String>? global;
  List<StationPermission>? station;

  RolePermissions({
    this.global,
    this.station,
  });

  factory RolePermissions.fromJson(Map<String, dynamic> json) =>
      RolePermissions(
        global: json["global"] == null
            ? []
            : List<String>.from(json["global"]!.map((x) => x)),
        station: json["station"] == null
            ? []
            : List<StationPermission>.from(
                json["station"]!.map((x) => StationPermission.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "global":
            global == null ? [] : List<dynamic>.from(global!.map((x) => x)),
        "station": station == null
            ? []
            : List<dynamic>.from(station!.map((x) => x.toJson())),
      };
}

class StationPermission {
  int? id;
  List<String>? permissions;

  StationPermission({
    this.id,
    this.permissions,
  });

  factory StationPermission.fromJson(Map<String, dynamic> json) =>
      StationPermission(
        id: json["id"],
        permissions: json["permissions"] == null
            ? []
            : List<String>.from(json["permissions"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "permissions": permissions == null
            ? []
            : List<dynamic>.from(permissions!.map((x) => x)),
      };
}
