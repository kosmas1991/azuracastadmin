// To parse this JSON data, do
//
//     final radioStations = radioStationsFromJson(jsonString);

import 'dart:convert';

List<RadioStations> radioStationsFromJson(String str) => List<RadioStations>.from(json.decode(str).map((x) => RadioStations.fromJson(x)));

String radioStationsToJson(List<RadioStations> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RadioStations {
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

    RadioStations({
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

    factory RadioStations.fromJson(Map<String, dynamic> json) => RadioStations(
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
        mounts: json["mounts"] == null ? [] : List<Mount>.from(json["mounts"]!.map((x) => Mount.fromJson(x))),
        remotes: json["remotes"] == null ? [] : List<dynamic>.from(json["remotes"]!.map((x) => x)),
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
        "mounts": mounts == null ? [] : List<dynamic>.from(mounts!.map((x) => x.toJson())),
        "remotes": remotes == null ? [] : List<dynamic>.from(remotes!.map((x) => x)),
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
        listeners: json["listeners"] == null ? null : Listeners.fromJson(json["listeners"]),
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
