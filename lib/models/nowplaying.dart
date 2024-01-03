// To parse this JSON data, do
//
//     final nowPlaying = nowPlayingFromJson(jsonString);

import 'dart:convert';

NowPlaying nowPlayingFromJson(String str) =>
    NowPlaying.fromJson(json.decode(str));

String nowPlayingToJson(NowPlaying data) => json.encode(data.toJson());

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
  Playlist? playlist;
  String? streamer;
  bool? isRequest;
  Song? song;
  int? elapsed;
  int? remaining;

  NowPlayingClass({
    this.shId,
    this.playedAt,
    this.duration,
    this.playlist,
    this.streamer,
    this.isRequest,
    this.song,
    this.elapsed,
    this.remaining,
  });

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
        "playlist": playlistValues.reverse[playlist],
        "streamer": streamer,
        "is_request": isRequest,
        "song": song?.toJson(),
        "elapsed": elapsed,
        "remaining": remaining,
      };
}

enum Playlist { DEFAULT }

final playlistValues = EnumValues({"default": Playlist.DEFAULT});

class Song {
  String? id;
  String? text;
  String? artist;
  String? title;
  String? album;
  String? genre;
  String? isrc;
  String? lyrics;
  String? art;
  List<dynamic>? customFields;

  Song({
    this.id,
    this.text,
    this.artist,
    this.title,
    this.album,
    this.genre,
    this.isrc,
    this.lyrics,
    this.art,
    this.customFields,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json["id"],
        text: json["text"],
        artist: json["artist"],
        title: json["title"],
        album: json["album"],
        genre: json["genre"],
        isrc: json["isrc"],
        lyrics: json["lyrics"],
        art: json["art"],
        customFields: json["custom_fields"] == null
            ? []
            : List<dynamic>.from(json["custom_fields"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "artist": artist,
        "title": title,
        "album": album,
        "genre": genre,
        "isrc": isrc,
        "lyrics": lyrics,
        "art": art,
        "custom_fields": customFields == null
            ? []
            : List<dynamic>.from(customFields!.map((x) => x)),
      };
}

class PlayingNext {
  int? cuedAt;
  int? playedAt;
  int? duration;
  Playlist? playlist;
  bool? isRequest;
  Song? song;

  PlayingNext({
    this.cuedAt,
    this.playedAt,
    this.duration,
    this.playlist,
    this.isRequest,
    this.song,
  });

  factory PlayingNext.fromJson(Map<String, dynamic> json) => PlayingNext(
        cuedAt: json["cued_at"],
        playedAt: json["played_at"],
        duration: json["duration"],
  
        isRequest: json["is_request"],
        song: json["song"] == null ? null : Song.fromJson(json["song"]),
      );

  Map<String, dynamic> toJson() => {
        "cued_at": cuedAt,
        "played_at": playedAt,
        "duration": duration,
        "playlist": playlistValues.reverse[playlist],
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
  String? listenUrl;
  String? url;
  String? publicPlayerUrl;
  String? playlistPlsUrl;
  String? playlistM3UUrl;
  bool? isPublic;
  List<Mount>? mounts;
  List<dynamic>? remotes;
  bool? hlsEnabled;
  dynamic hlsUrl;
  int? hlsListeners;

  Station({
    this.id,
    this.name,
    this.shortcode,
    this.description,
    this.frontend,
    this.backend,
    this.listenUrl,
    this.url,
    this.publicPlayerUrl,
    this.playlistPlsUrl,
    this.playlistM3UUrl,
    this.isPublic,
    this.mounts,
    this.remotes,
    this.hlsEnabled,
    this.hlsUrl,
    this.hlsListeners,
  });

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        id: json["id"],
        name: json["name"],
        shortcode: json["shortcode"],
        description: json["description"],
        frontend: json["frontend"],
        backend: json["backend"],
        listenUrl: json["listen_url"],
        url: json["url"],
        publicPlayerUrl: json["public_player_url"],
        playlistPlsUrl: json["playlist_pls_url"],
        playlistM3UUrl: json["playlist_m3u_url"],
        isPublic: json["is_public"],
        mounts: json["mounts"] == null
            ? []
            : List<Mount>.from(json["mounts"]!.map((x) => Mount.fromJson(x))),
        remotes: json["remotes"] == null
            ? []
            : List<dynamic>.from(json["remotes"]!.map((x) => x)),
        hlsEnabled: json["hls_enabled"],
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
        "listen_url": listenUrl,
        "url": url,
        "public_player_url": publicPlayerUrl,
        "playlist_pls_url": playlistPlsUrl,
        "playlist_m3u_url": playlistM3UUrl,
        "is_public": isPublic,
        "mounts": mounts == null
            ? []
            : List<dynamic>.from(mounts!.map((x) => x.toJson())),
        "remotes":
            remotes == null ? [] : List<dynamic>.from(remotes!.map((x) => x)),
        "hls_enabled": hlsEnabled,
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
