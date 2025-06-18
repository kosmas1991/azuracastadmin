import 'dart:convert';

List<Backup> backupsFromJson(String str) =>
    List<Backup>.from(json.decode(str).map((x) => Backup.fromJson(x)));

String backupsToJson(List<Backup> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Backup {
  String? path;
  String? basename;
  String? pathEncoded;
  int? timestamp;
  int? size;
  int? storageLocationId;
  BackupLinks? links;

  Backup({
    this.path,
    this.basename,
    this.pathEncoded,
    this.timestamp,
    this.size,
    this.storageLocationId,
    this.links,
  });

  factory Backup.fromJson(Map<String, dynamic> json) => Backup(
        path: json["path"],
        basename: json["basename"],
        pathEncoded: json["pathEncoded"],
        timestamp: json["timestamp"],
        size: json["size"],
        storageLocationId: json["storageLocationId"],
        links:
            json["links"] == null ? null : BackupLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "path": path,
        "basename": basename,
        "pathEncoded": pathEncoded,
        "timestamp": timestamp,
        "size": size,
        "storageLocationId": storageLocationId,
        "links": links?.toJson(),
      };
}

class BackupLinks {
  String? download;
  String? delete;

  BackupLinks({
    this.download,
    this.delete,
  });

  factory BackupLinks.fromJson(Map<String, dynamic> json) => BackupLinks(
        download: json["download"],
        delete: json["delete"],
      );

  Map<String, dynamic> toJson() => {
        "download": download,
        "delete": delete,
      };
}
