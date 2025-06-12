import 'dart:convert';

List<StationPlaylist> stationPlaylistFromJson(String str) =>
    List<StationPlaylist>.from(
        json.decode(str).map((x) => StationPlaylist.fromJson(x)));

String stationPlaylistToJson(List<StationPlaylist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StationPlaylist {
  String name;
  String type;
  String source;
  String order;
  String? remoteUrl;
  String remoteType;
  int remoteBuffer;
  bool isEnabled;
  bool isJingle;
  int playPerSongs;
  int playPerMinutes;
  int playPerHourMinute;
  int weight;
  bool includeInRequests;
  bool includeInOnDemand;
  List<String> backendOptions;
  bool avoidDuplicates;
  String? playedAt;
  String? queueResetAt;
  List<ScheduleItem> scheduleItems;
  List<dynamic> podcasts;
  int id;
  String shortName;
  int numSongs;
  int totalLength;
  PlaylistLinks links;

  StationPlaylist({
    required this.name,
    required this.type,
    required this.source,
    required this.order,
    this.remoteUrl,
    required this.remoteType,
    required this.remoteBuffer,
    required this.isEnabled,
    required this.isJingle,
    required this.playPerSongs,
    required this.playPerMinutes,
    required this.playPerHourMinute,
    required this.weight,
    required this.includeInRequests,
    required this.includeInOnDemand,
    required this.backendOptions,
    required this.avoidDuplicates,
    this.playedAt,
    this.queueResetAt,
    required this.scheduleItems,
    required this.podcasts,
    required this.id,
    required this.shortName,
    required this.numSongs,
    required this.totalLength,
    required this.links,
  });

  factory StationPlaylist.fromJson(Map<String, dynamic> json) =>
      StationPlaylist(
        name: json["name"],
        type: json["type"],
        source: json["source"],
        order: json["order"],
        remoteUrl: json["remote_url"],
        remoteType: json["remote_type"],
        remoteBuffer: json["remote_buffer"],
        isEnabled: json["is_enabled"],
        isJingle: json["is_jingle"],
        playPerSongs: json["play_per_songs"],
        playPerMinutes: json["play_per_minutes"],
        playPerHourMinute: json["play_per_hour_minute"],
        weight: json["weight"],
        includeInRequests: json["include_in_requests"],
        includeInOnDemand: json["include_in_on_demand"],
        backendOptions:
            List<String>.from(json["backend_options"].map((x) => x)),
        avoidDuplicates: json["avoid_duplicates"],
        playedAt: json["played_at"],
        queueResetAt: json["queue_reset_at"],
        scheduleItems: List<ScheduleItem>.from(
            json["schedule_items"].map((x) => ScheduleItem.fromJson(x))),
        podcasts: List<dynamic>.from(json["podcasts"].map((x) => x)),
        id: json["id"],
        shortName: json["short_name"],
        numSongs: json["num_songs"],
        totalLength: json["total_length"],
        links: PlaylistLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "source": source,
        "order": order,
        "remote_url": remoteUrl,
        "remote_type": remoteType,
        "remote_buffer": remoteBuffer,
        "is_enabled": isEnabled,
        "is_jingle": isJingle,
        "play_per_songs": playPerSongs,
        "play_per_minutes": playPerMinutes,
        "play_per_hour_minute": playPerHourMinute,
        "weight": weight,
        "include_in_requests": includeInRequests,
        "include_in_on_demand": includeInOnDemand,
        "backend_options": List<dynamic>.from(backendOptions.map((x) => x)),
        "avoid_duplicates": avoidDuplicates,
        "played_at": playedAt,
        "queue_reset_at": queueResetAt,
        "schedule_items":
            List<dynamic>.from(scheduleItems.map((x) => x.toJson())),
        "podcasts": List<dynamic>.from(podcasts.map((x) => x)),
        "id": id,
        "short_name": shortName,
        "num_songs": numSongs,
        "total_length": totalLength,
        "links": links.toJson(),
      };
}

class ScheduleItem {
  int startTime;
  int endTime;
  String? startDate;
  String? endDate;
  List<int> days;
  bool loopOnce;
  int id;

  ScheduleItem({
    required this.startTime,
    required this.endTime,
    this.startDate,
    this.endDate,
    required this.days,
    required this.loopOnce,
    required this.id,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        startTime: json["start_time"],
        endTime: json["end_time"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        days: List<int>.from(json["days"].map((x) => x)),
        loopOnce: json["loop_once"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "end_time": endTime,
        "start_date": startDate,
        "end_date": endDate,
        "days": List<dynamic>.from(days.map((x) => x)),
        "loop_once": loopOnce,
        "id": id,
      };
}

class PlaylistLinks {
  String self;
  String toggle;
  String clone;
  String queue;
  String import;
  String reshuffle;
  String applyto;
  String empty;
  ExportLinks export;

  PlaylistLinks({
    required this.self,
    required this.toggle,
    required this.clone,
    required this.queue,
    required this.import,
    required this.reshuffle,
    required this.applyto,
    required this.empty,
    required this.export,
  });

  factory PlaylistLinks.fromJson(Map<String, dynamic> json) => PlaylistLinks(
        self: json["self"],
        toggle: json["toggle"],
        clone: json["clone"],
        queue: json["queue"],
        import: json["import"],
        reshuffle: json["reshuffle"],
        applyto: json["applyto"],
        empty: json["empty"],
        export: ExportLinks.fromJson(json["export"]),
      );

  Map<String, dynamic> toJson() => {
        "self": self,
        "toggle": toggle,
        "clone": clone,
        "queue": queue,
        "import": import,
        "reshuffle": reshuffle,
        "applyto": applyto,
        "empty": empty,
        "export": export.toJson(),
      };
}

class ExportLinks {
  String pls;
  String m3u;

  ExportLinks({
    required this.pls,
    required this.m3u,
  });

  factory ExportLinks.fromJson(Map<String, dynamic> json) => ExportLinks(
        pls: json["pls"],
        m3u: json["m3u"],
      );

  Map<String, dynamic> toJson() => {
        "pls": pls,
        "m3u": m3u,
      };
}
