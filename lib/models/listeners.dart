// To parse this JSON data, do
//
//     final activeListeners = activeListenersFromJson(jsonString);

import 'dart:convert';

List<ActiveListeners> activeListenersFromJson(String str) => List<ActiveListeners>.from(json.decode(str).map((x) => ActiveListeners.fromJson(x)));

String activeListenersToJson(List<ActiveListeners> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActiveListeners {
    String? ip;
    String? userAgent;
    String? hash;
    bool? mountIsLocal;
    String? mountName;
    int? connectedOn;
    int? connectedUntil;
    int? connectedTime;
    Device? device;
    Location? location;

    ActiveListeners({
        this.ip,
        this.userAgent,
        this.hash,
        this.mountIsLocal,
        this.mountName,
        this.connectedOn,
        this.connectedUntil,
        this.connectedTime,
        this.device,
        this.location,
    });

    factory ActiveListeners.fromJson(Map<String, dynamic> json) => ActiveListeners(
        ip: json["ip"],
        userAgent: json["user_agent"],
        hash: json["hash"],
        mountIsLocal: json["mount_is_local"],
        mountName: json["mount_name"],
        connectedOn: json["connected_on"],
        connectedUntil: json["connected_until"],
        connectedTime: json["connected_time"],
        device: json["device"] == null ? null : Device.fromJson(json["device"]),
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
    );

    Map<String, dynamic> toJson() => {
        "ip": ip,
        "user_agent": userAgent,
        "hash": hash,
        "mount_is_local": mountIsLocal,
        "mount_name": mountName,
        "connected_on": connectedOn,
        "connected_until": connectedUntil,
        "connected_time": connectedTime,
        "device": device?.toJson(),
        "location": location?.toJson(),
    };
}

class Device {
    bool? isBrowser;
    bool? isMobile;
    bool? isBot;
    String? client;
    String? browserFamily;
    String? osFamily;

    Device({
        this.isBrowser,
        this.isMobile,
        this.isBot,
        this.client,
        this.browserFamily,
        this.osFamily,
    });

    factory Device.fromJson(Map<String, dynamic> json) => Device(
        isBrowser: json["is_browser"],
        isMobile: json["is_mobile"],
        isBot: json["is_bot"],
        client: json["client"],
        browserFamily: json["browser_family"],
        osFamily: json["os_family"],
    );

    Map<String, dynamic> toJson() => {
        "is_browser": isBrowser,
        "is_mobile": isMobile,
        "is_bot": isBot,
        "client": client,
        "browser_family": browserFamily,
        "os_family": osFamily,
    };
}

class Location {
    String? city;
    String? region;
    String? country;
    String? description;
    double? lat;
    double? lon;

    Location({
        this.city,
        this.region,
        this.country,
        this.description,
        this.lat,
        this.lon,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        city: json["city"],
        region: json["region"],
        country: json["country"],
        description: json["description"],
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "city": city,
        "region": region,
        "country": country,
        "description": description,
        "lat": lat,
        "lon": lon,
    };
}
