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
    String? client;
    bool? isBrowser;
    bool? isMobile;
    bool? isBot;
    String? browserFamily;
    String? osFamily;

    Device({
        this.client,
        this.isBrowser,
        this.isMobile,
        this.isBot,
        this.browserFamily,
        this.osFamily,
    });

    factory Device.fromJson(Map<String, dynamic> json) => Device(
        client: json["client"],
        isBrowser: json["is_browser"],
        isMobile: json["is_mobile"],
        isBot: json["is_bot"],
        browserFamily: json["browser_family"],
        osFamily: json["os_family"],
    );

    Map<String, dynamic> toJson() => {
        "client": client,
        "is_browser": isBrowser,
        "is_mobile": isMobile,
        "is_bot": isBot,
        "browser_family": browserFamily,
        "os_family": osFamily,
    };
}

class Location {
    String? description;
    String? region;
    String? city;
    String? country;
    String? lat;
    String? lon;

    Location({
        this.description,
        this.region,
        this.city,
        this.country,
        this.lat,
        this.lon,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        description: json["description"],
        region: json["region"],
        city: json["city"],
        country: json["country"],
        lat: json["lat"],
        lon: json["lon"],
    );

    Map<String, dynamic> toJson() => {
        "description": description,
        "region": region,
        "city": city,
        "country": country,
        "lat": lat,
        "lon": lon,
    };
}
