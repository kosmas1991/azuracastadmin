// To parse this JSON data, do
//
//     final nowPlaying = nowPlayingFromJson(jsonString);

import 'dart:convert';

List<NowPlaying> nowPlayingFromJson(String str) =>
    List<NowPlaying>.from(json.decode(str).map((x) => NowPlaying.fromJson(x)));

String nowPlayingToJson(List<NowPlaying> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NowPlaying {
  Station? station;
  Listeners? listeners;
  Live? live;
  NowPlayingClass? nowPlaying;
  PlayingNext? playingNext;
  List<NowPlayingClass>? songHistory;
  bool? isOnline;
  dynamic cache;

  NowPlaying({
    this.station,
    this.listeners,
    this.live,
    this.nowPlaying,
    this.playingNext,
    this.songHistory,
    this.isOnline,
    this.cache,
  });

  NowPlaying copyWith({
    Station? station,
    Listeners? listeners,
    Live? live,
    NowPlayingClass? nowPlaying,
    PlayingNext? playingNext,
    List<NowPlayingClass>? songHistory,
    bool? isOnline,
    dynamic cache,
  }) =>
      NowPlaying(
        station: station ?? this.station,
        listeners: listeners ?? this.listeners,
        live: live ?? this.live,
        nowPlaying: nowPlaying ?? this.nowPlaying,
        playingNext: playingNext ?? this.playingNext,
        songHistory: songHistory ?? this.songHistory,
        isOnline: isOnline ?? this.isOnline,
        cache: cache ?? this.cache,
      );

  factory NowPlaying.fromJson(Map<String, dynamic> json) => NowPlaying(
        station:
            json["station"] == null ? null : Station.fromJson(json["station"]),
        listeners: json["listeners"] == null
            ? null
            : Listeners.fromJson(json["listeners"]),
        live: json["live"] == null ? null : Live.fromJson(json["live"]),
        nowPlaying: json["now_playing"] == null
            ? null
            : NowPlayingClass.fromJson(json["now_playing"]),
        playingNext: json["playing_next"] == null
            ? null
            : PlayingNext.fromJson(json["playing_next"]),
        songHistory: json["song_history"] == null
            ? []
            : List<NowPlayingClass>.from(
                json["song_history"]!.map((x) => NowPlayingClass.fromJson(x))),
        isOnline: json["is_online"],
        cache: json["cache"],
      );

  Map<String, dynamic> toJson() => {
        "station": station?.toJson(),
        "listeners": listeners?.toJson(),
        "live": live?.toJson(),
        "now_playing": nowPlaying?.toJson(),
        "playing_next": playingNext?.toJson(),
        "song_history": songHistory == null
            ? []
            : List<dynamic>.from(songHistory!.map((x) => x.toJson())),
        "is_online": isOnline,
        "cache": cache,
      };
}

class Listeners {
  int? total;
  int? unique;
  int? current;

  Listeners({
    this.total,
    this.unique,
    this.current,
  });

  Listeners copyWith({
    int? total,
    int? unique,
    int? current,
  }) =>
      Listeners(
        total: total ?? this.total,
        unique: unique ?? this.unique,
        current: current ?? this.current,
      );

  factory Listeners.fromJson(Map<String, dynamic> json) => Listeners(
        total: json["total"],
        unique: json["unique"],
        current: json["current"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "unique": unique,
        "current": current,
      };
}

class Live {
  bool? isLive;
  String? streamerName;
  dynamic broadcastStart;
  dynamic art;

  Live({
    this.isLive,
    this.streamerName,
    this.broadcastStart,
    this.art,
  });

  Live copyWith({
    bool? isLive,
    String? streamerName,
    dynamic broadcastStart,
    dynamic art,
  }) =>
      Live(
        isLive: isLive ?? this.isLive,
        streamerName: streamerName ?? this.streamerName,
        broadcastStart: broadcastStart ?? this.broadcastStart,
        art: art ?? this.art,
      );

  factory Live.fromJson(Map<String, dynamic> json) => Live(
        isLive: json["is_live"],
        streamerName: json["streamer_name"],
        broadcastStart: json["broadcast_start"],
        art: json["art"],
      );

  Map<String, dynamic> toJson() => {
        "is_live": isLive,
        "streamer_name": streamerName,
        "broadcast_start": broadcastStart,
        "art": art,
      };
}

class NowPlayingClass {
  int? shId;
  int? playedAt;
  int? duration;
  String? streamer;
  bool? isRequest;
  Song? song;
  int? elapsed;
  int? remaining;

  NowPlayingClass({
    this.shId,
    this.playedAt,
    this.duration,
    this.streamer,
    this.isRequest,
    this.song,
    this.elapsed,
    this.remaining,
  });

  NowPlayingClass copyWith({
    int? shId,
    int? playedAt,
    int? duration,
    String? streamer,
    bool? isRequest,
    Song? song,
    int? elapsed,
    int? remaining,
  }) =>
      NowPlayingClass(
        shId: shId ?? this.shId,
        playedAt: playedAt ?? this.playedAt,
        duration: duration ?? this.duration,
        streamer: streamer ?? this.streamer,
        isRequest: isRequest ?? this.isRequest,
        song: song ?? this.song,
        elapsed: elapsed ?? this.elapsed,
        remaining: remaining ?? this.remaining,
      );

  factory NowPlayingClass.fromJson(Map<String, dynamic> json) =>
      NowPlayingClass(
        shId: json["sh_id"],
        playedAt: json["played_at"],
        duration: json["duration"],
        streamer: json["streamer"],
        isRequest: json["is_request"],
        song: json["song"] == null ? null : Song.fromJson(json["song"]),
        elapsed: json["elapsed"],
        remaining: json["remaining"],
      );

  Map<String, dynamic> toJson() => {
        "sh_id": shId,
        "played_at": playedAt,
        "duration": duration,
        "streamer": streamer,
        "is_request": isRequest,
        "song": song?.toJson(),
        "elapsed": elapsed,
        "remaining": remaining,
      };
}

class Song {
  String? id;
  String? art;
  List<dynamic>? customFields;
  String? text;
  String? artist;
  String? title;
  Album? album;
  Genre? genre;
  Isrc? isrc;
  String? lyrics;

  Song({
    this.id,
    this.art,
    this.customFields,
    this.text,
    this.artist,
    this.title,
    this.album,
    this.genre,
    this.isrc,
    this.lyrics,
  });

  Song copyWith({
    String? id,
    String? art,
    List<dynamic>? customFields,
    String? text,
    String? artist,
    String? title,
    Album? album,
    Genre? genre,
    Isrc? isrc,
    String? lyrics,
  }) =>
      Song(
        id: id ?? this.id,
        art: art ?? this.art,
        customFields: customFields ?? this.customFields,
        text: text ?? this.text,
        artist: artist ?? this.artist,
        title: title ?? this.title,
        album: album ?? this.album,
        genre: genre ?? this.genre,
        isrc: isrc ?? this.isrc,
        lyrics: lyrics ?? this.lyrics,
      );

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json["id"],
        art: json["art"],
        customFields: json["custom_fields"] == null
            ? []
            : List<dynamic>.from(json["custom_fields"]!.map((x) => x)),
        text: json["text"],
        artist: json["artist"],
        title: json["title"],
        album: albumValues.map[json["album"]]!,
        genre: genreValues.map[json["genre"]]!,
        isrc: isrcValues.map[json["isrc"]]!,
        lyrics: json["lyrics"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "art": art,
        "custom_fields": customFields == null
            ? []
            : List<dynamic>.from(customFields!.map((x) => x)),
        "text": text,
        "artist": artist,
        "title": title,
        "album": albumValues.reverse[album],
        "genre": genreValues.reverse[genre],
        "isrc": isrcValues.reverse[isrc],
        "lyrics": lyrics,
      };
}

enum Album { DARK_BEFORE_DAWN, EMPTY, TRANSIT_OF_VENUS }

final albumValues = EnumValues({
  "Dark Before Dawn": Album.DARK_BEFORE_DAWN,
  "": Album.EMPTY,
  "Transit Of Venus": Album.TRANSIT_OF_VENUS
});

enum Genre { ALTERNATIVE_METAL, EMPTY, ROCK }

final genreValues = EnumValues({
  "Alternative Metal": Genre.ALTERNATIVE_METAL,
  "": Genre.EMPTY,
  "Rock": Genre.ROCK
});

enum Isrc { EMPTY, USRC11200916 }

final isrcValues =
    EnumValues({"": Isrc.EMPTY, "USRC11200916": Isrc.USRC11200916});

class PlayingNext {
  int? cuedAt;
  int? playedAt;
  double? duration;
  bool? isRequest;
  Song? song;

  PlayingNext({
    this.cuedAt,
    this.playedAt,
    this.duration,
    this.isRequest,
    this.song,
  });

  PlayingNext copyWith({
    int? cuedAt,
    int? playedAt,
    double? duration,
    bool? isRequest,
    Song? song,
  }) =>
      PlayingNext(
        cuedAt: cuedAt ?? this.cuedAt,
        playedAt: playedAt ?? this.playedAt,
        duration: duration ?? this.duration,
        isRequest: isRequest ?? this.isRequest,
        song: song ?? this.song,
      );

  factory PlayingNext.fromJson(Map<String, dynamic> json) => PlayingNext(
        cuedAt: json["cued_at"],
        playedAt: json["played_at"],
        duration: json["duration"]?.toDouble(),
        isRequest: json["is_request"],
        song: json["song"] == null ? null : Song.fromJson(json["song"]),
      );

  Map<String, dynamic> toJson() => {
        "cued_at": cuedAt,
        "played_at": playedAt,
        "duration": duration,
        "is_request": isRequest,
        "song": song?.toJson(),
      };
}

class Station {
  int? id;
  String? name;
  String? shortcode;
  String? description;
  String? frontend;
  String? backend;
  String? timezone;
  String? listenUrl;
  String? url;
  String? publicPlayerUrl;
  bool? isPublic;
  List<Mount>? mounts;
  List<dynamic>? remotes;
  bool? hlsEnabled;
  bool? hlsIsDefault;
  dynamic hlsUrl;
  int? hlsListeners;

  Station({
    this.id,
    this.name,
    this.shortcode,
    this.description,
    this.frontend,
    this.backend,
    this.timezone,
    this.listenUrl,
    this.url,
    this.publicPlayerUrl,
    this.isPublic,
    this.mounts,
    this.remotes,
    this.hlsEnabled,
    this.hlsIsDefault,
    this.hlsUrl,
    this.hlsListeners,
  });

  Station copyWith({
    int? id,
    String? name,
    String? shortcode,
    String? description,
    String? frontend,
    String? backend,
    String? timezone,
    String? listenUrl,
    String? url,
    String? publicPlayerUrl,
    bool? isPublic,
    List<Mount>? mounts,
    List<dynamic>? remotes,
    bool? hlsEnabled,
    bool? hlsIsDefault,
    dynamic hlsUrl,
    int? hlsListeners,
  }) =>
      Station(
        id: id ?? this.id,
        name: name ?? this.name,
        shortcode: shortcode ?? this.shortcode,
        description: description ?? this.description,
        frontend: frontend ?? this.frontend,
        backend: backend ?? this.backend,
        timezone: timezone ?? this.timezone,
        listenUrl: listenUrl ?? this.listenUrl,
        url: url ?? this.url,
        publicPlayerUrl: publicPlayerUrl ?? this.publicPlayerUrl,
        isPublic: isPublic ?? this.isPublic,
        mounts: mounts ?? this.mounts,
        remotes: remotes ?? this.remotes,
        hlsEnabled: hlsEnabled ?? this.hlsEnabled,
        hlsIsDefault: hlsIsDefault ?? this.hlsIsDefault,
        hlsUrl: hlsUrl ?? this.hlsUrl,
        hlsListeners: hlsListeners ?? this.hlsListeners,
      );

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        id: json["id"],
        name: json["name"],
        shortcode: json["shortcode"],
        description: json["description"],
        frontend: json["frontend"],
        backend: json["backend"],
        timezone: json["timezone"],
        listenUrl: json["listen_url"],
        url: json["url"],
        publicPlayerUrl: json["public_player_url"],
        isPublic: json["is_public"],
        mounts: json["mounts"] == null
            ? []
            : List<Mount>.from(json["mounts"]!.map((x) => Mount.fromJson(x))),
        remotes: json["remotes"] == null
            ? []
            : List<dynamic>.from(json["remotes"]!.map((x) => x)),
        hlsEnabled: json["hls_enabled"],
        hlsIsDefault: json["hls_is_default"],
        hlsUrl: json["hls_url"],
        hlsListeners: json["hls_listeners"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "shortcode": shortcode,
        "description": description,
        "frontend": frontend,
        "backend": backend,
        "timezone": timezone,
        "listen_url": listenUrl,
        "url": url,
        "public_player_url": publicPlayerUrl,
        "is_public": isPublic,
        "mounts": mounts == null
            ? []
            : List<dynamic>.from(mounts!.map((x) => x.toJson())),
        "remotes":
            remotes == null ? [] : List<dynamic>.from(remotes!.map((x) => x)),
        "hls_enabled": hlsEnabled,
        "hls_is_default": hlsIsDefault,
        "hls_url": hlsUrl,
        "hls_listeners": hlsListeners,
      };
}

class Mount {
  int? id;
  String? name;
  String? url;
  int? bitrate;
  String? format;
  Listeners? listeners;
  String? path;
  bool? isDefault;

  Mount({
    this.id,
    this.name,
    this.url,
    this.bitrate,
    this.format,
    this.listeners,
    this.path,
    this.isDefault,
  });

  Mount copyWith({
    int? id,
    String? name,
    String? url,
    int? bitrate,
    String? format,
    Listeners? listeners,
    String? path,
    bool? isDefault,
  }) =>
      Mount(
        id: id ?? this.id,
        name: name ?? this.name,
        url: url ?? this.url,
        bitrate: bitrate ?? this.bitrate,
        format: format ?? this.format,
        listeners: listeners ?? this.listeners,
        path: path ?? this.path,
        isDefault: isDefault ?? this.isDefault,
      );

  factory Mount.fromJson(Map<String, dynamic> json) => Mount(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        bitrate: json["bitrate"],
        format: json["format"],
        listeners: json["listeners"] == null
            ? null
            : Listeners.fromJson(json["listeners"]),
        path: json["path"],
        isDefault: json["is_default"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
        "bitrate": bitrate,
        "format": format,
        "listeners": listeners?.toJson(),
        "path": path,
        "is_default": isDefault,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
