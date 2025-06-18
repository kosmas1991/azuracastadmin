import 'dart:convert';

PermissionsModel permissionsFromJson(String str) =>
    PermissionsModel.fromJson(json.decode(str));

String permissionsToJson(PermissionsModel data) => json.encode(data.toJson());

class PermissionsModel {
  List<PermissionItem>? global;
  List<PermissionItem>? station;

  PermissionsModel({
    this.global,
    this.station,
  });

  factory PermissionsModel.fromJson(Map<String, dynamic> json) =>
      PermissionsModel(
        global: json["global"] == null
            ? []
            : List<PermissionItem>.from(
                json["global"]!.map((x) => PermissionItem.fromJson(x))),
        station: json["station"] == null
            ? []
            : List<PermissionItem>.from(
                json["station"]!.map((x) => PermissionItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "global": global == null
            ? []
            : List<dynamic>.from(global!.map((x) => x.toJson())),
        "station": station == null
            ? []
            : List<dynamic>.from(station!.map((x) => x.toJson())),
      };
}

class PermissionItem {
  String? id;
  String? name;

  PermissionItem({
    this.id,
    this.name,
  });

  factory PermissionItem.fromJson(Map<String, dynamic> json) => PermissionItem(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
