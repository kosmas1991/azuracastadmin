import 'dart:convert';

List<RadioStations> radioStationsFromJson(String str) => List<RadioStations>.from(json.decode(str).map((x) => RadioStations.fromJson(x)));

String radioStationsToJson(List<RadioStations> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RadioStations {
    String name;
    String shortName;
    bool isEnabled;
    String frontendType;
    FrontendConfig frontendConfig;
    String backendType;
    BackendConfig backendConfig;
    String description;
    String url;
    String genre;
    String radioBaseDir;
    bool enableRequests;
    int requestDelay;
    int requestThreshold;
    int disconnectDeactivateStreamer;
    bool enableStreamers;
    bool isStreamerLive;
    bool enablePublicPage;
    bool enableOnDemand;
    bool enableOnDemandDownload;
    bool enableHls;
    int apiHistoryItems;
    String timezone;
    BrandingConfig brandingConfig;
    int mediaStorageLocation;
    int recordingsStorageLocation;
    int podcastsStorageLocation;
    dynamic fallbackPath;
    int id;
    Links links;

    RadioStations({
        required this.name,
        required this.shortName,
        required this.isEnabled,
        required this.frontendType,
        required this.frontendConfig,
        required this.backendType,
        required this.backendConfig,
        required this.description,
        required this.url,
        required this.genre,
        required this.radioBaseDir,
        required this.enableRequests,
        required this.requestDelay,
        required this.requestThreshold,
        required this.disconnectDeactivateStreamer,
        required this.enableStreamers,
        required this.isStreamerLive,
        required this.enablePublicPage,
        required this.enableOnDemand,
        required this.enableOnDemandDownload,
        required this.enableHls,
        required this.apiHistoryItems,
        required this.timezone,
        required this.brandingConfig,
        required this.mediaStorageLocation,
        required this.recordingsStorageLocation,
        required this.podcastsStorageLocation,
        required this.fallbackPath,
        required this.id,
        required this.links,
    });

    factory RadioStations.fromJson(Map<String, dynamic> json) => RadioStations(
        name: json["name"],
        shortName: json["short_name"],
        isEnabled: json["is_enabled"],
        frontendType: json["frontend_type"],
        frontendConfig: FrontendConfig.fromJson(json["frontend_config"]),
        backendType: json["backend_type"],
        backendConfig: BackendConfig.fromJson(json["backend_config"]),
        description: json["description"],
        url: json["url"],
        genre: json["genre"],
        radioBaseDir: json["radio_base_dir"],
        enableRequests: json["enable_requests"],
        requestDelay: json["request_delay"],
        requestThreshold: json["request_threshold"],
        disconnectDeactivateStreamer: json["disconnect_deactivate_streamer"],
        enableStreamers: json["enable_streamers"],
        isStreamerLive: json["is_streamer_live"],
        enablePublicPage: json["enable_public_page"],
        enableOnDemand: json["enable_on_demand"],
        enableOnDemandDownload: json["enable_on_demand_download"],
        enableHls: json["enable_hls"],
        apiHistoryItems: json["api_history_items"],
        timezone: json["timezone"],
        brandingConfig: BrandingConfig.fromJson(json["branding_config"]),
        mediaStorageLocation: json["media_storage_location"],
        recordingsStorageLocation: json["recordings_storage_location"],
        podcastsStorageLocation: json["podcasts_storage_location"],
        fallbackPath: json["fallback_path"],
        id: json["id"],
        links: Links.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "short_name": shortName,
        "is_enabled": isEnabled,
        "frontend_type": frontendType,
        "frontend_config": frontendConfig.toJson(),
        "backend_type": backendType,
        "backend_config": backendConfig.toJson(),
        "description": description,
        "url": url,
        "genre": genre,
        "radio_base_dir": radioBaseDir,
        "enable_requests": enableRequests,
        "request_delay": requestDelay,
        "request_threshold": requestThreshold,
        "disconnect_deactivate_streamer": disconnectDeactivateStreamer,
        "enable_streamers": enableStreamers,
        "is_streamer_live": isStreamerLive,
        "enable_public_page": enablePublicPage,
        "enable_on_demand": enableOnDemand,
        "enable_on_demand_download": enableOnDemandDownload,
        "enable_hls": enableHls,
        "api_history_items": apiHistoryItems,
        "timezone": timezone,
        "branding_config": brandingConfig.toJson(),
        "media_storage_location": mediaStorageLocation,
        "recordings_storage_location": recordingsStorageLocation,
        "podcasts_storage_location": podcastsStorageLocation,
        "fallback_path": fallbackPath,
        "id": id,
        "links": links.toJson(),
    };
}

class BackendConfig {
    String charset;
    int djPort;
    int telnetPort;
    bool recordStreams;
    String recordStreamsFormat;
    int recordStreamsBitrate;
    bool useManualAutodj;
    int autodjQueueLength;
    String djMountPoint;
    int djBuffer;
    String audioProcessingMethod;
    bool postProcessingIncludeLive;
    String stereoToolLicenseKey;
    String masterMePreset;
    int masterMeLoudnessTarget;
    bool enableReplaygainMetadata;
    String crossfadeType;
    int crossfade;
    int duplicatePreventionTimeRange;
    String performanceMode;
    int hlsSegmentLength;
    int hlsSegmentsInPlaylist;
    int hlsSegmentsOverhead;
    bool hlsEnableOnPublicPlayer;
    bool hlsIsDefault;
    String liveBroadcastText;

    BackendConfig({
        required this.charset,
        required this.djPort,
        required this.telnetPort,
        required this.recordStreams,
        required this.recordStreamsFormat,
        required this.recordStreamsBitrate,
        required this.useManualAutodj,
        required this.autodjQueueLength,
        required this.djMountPoint,
        required this.djBuffer,
        required this.audioProcessingMethod,
        required this.postProcessingIncludeLive,
        required this.stereoToolLicenseKey,
        required this.masterMePreset,
        required this.masterMeLoudnessTarget,
        required this.enableReplaygainMetadata,
        required this.crossfadeType,
        required this.crossfade,
        required this.duplicatePreventionTimeRange,
        required this.performanceMode,
        required this.hlsSegmentLength,
        required this.hlsSegmentsInPlaylist,
        required this.hlsSegmentsOverhead,
        required this.hlsEnableOnPublicPlayer,
        required this.hlsIsDefault,
        required this.liveBroadcastText,
    });

    factory BackendConfig.fromJson(Map<String, dynamic> json) => BackendConfig(
        charset: json["charset"],
        djPort: json["dj_port"],
        telnetPort: json["telnet_port"],
        recordStreams: json["record_streams"],
        recordStreamsFormat: json["record_streams_format"],
        recordStreamsBitrate: json["record_streams_bitrate"],
        useManualAutodj: json["use_manual_autodj"],
        autodjQueueLength: json["autodj_queue_length"],
        djMountPoint: json["dj_mount_point"],
        djBuffer: json["dj_buffer"],
        audioProcessingMethod: json["audio_processing_method"],
        postProcessingIncludeLive: json["post_processing_include_live"],
        stereoToolLicenseKey: json["stereo_tool_license_key"],
        masterMePreset: json["master_me_preset"],
        masterMeLoudnessTarget: json["master_me_loudness_target"],
        enableReplaygainMetadata: json["enable_replaygain_metadata"],
        crossfadeType: json["crossfade_type"],
        crossfade: json["crossfade"],
        duplicatePreventionTimeRange: json["duplicate_prevention_time_range"],
        performanceMode: json["performance_mode"],
        hlsSegmentLength: json["hls_segment_length"],
        hlsSegmentsInPlaylist: json["hls_segments_in_playlist"],
        hlsSegmentsOverhead: json["hls_segments_overhead"],
        hlsEnableOnPublicPlayer: json["hls_enable_on_public_player"],
        hlsIsDefault: json["hls_is_default"],
        liveBroadcastText: json["live_broadcast_text"],
    );

    Map<String, dynamic> toJson() => {
        "charset": charset,
        "dj_port": djPort,
        "telnet_port": telnetPort,
        "record_streams": recordStreams,
        "record_streams_format": recordStreamsFormat,
        "record_streams_bitrate": recordStreamsBitrate,
        "use_manual_autodj": useManualAutodj,
        "autodj_queue_length": autodjQueueLength,
        "dj_mount_point": djMountPoint,
        "dj_buffer": djBuffer,
        "audio_processing_method": audioProcessingMethod,
        "post_processing_include_live": postProcessingIncludeLive,
        "stereo_tool_license_key": stereoToolLicenseKey,
        "master_me_preset": masterMePreset,
        "master_me_loudness_target": masterMeLoudnessTarget,
        "enable_replaygain_metadata": enableReplaygainMetadata,
        "crossfade_type": crossfadeType,
        "crossfade": crossfade,
        "duplicate_prevention_time_range": duplicatePreventionTimeRange,
        "performance_mode": performanceMode,
        "hls_segment_length": hlsSegmentLength,
        "hls_segments_in_playlist": hlsSegmentsInPlaylist,
        "hls_segments_overhead": hlsSegmentsOverhead,
        "hls_enable_on_public_player": hlsEnableOnPublicPlayer,
        "hls_is_default": hlsIsDefault,
        "live_broadcast_text": liveBroadcastText,
    };
}

class BrandingConfig {
    String defaultAlbumArtUrl;
    String publicCustomCss;
    String publicCustomJs;
    String offlineText;

    BrandingConfig({
        required this.defaultAlbumArtUrl,
        required this.publicCustomCss,
        required this.publicCustomJs,
        required this.offlineText,
    });

    factory BrandingConfig.fromJson(Map<String, dynamic> json) => BrandingConfig(
        defaultAlbumArtUrl: json["default_album_art_url"],
        publicCustomCss: json["public_custom_css"],
        publicCustomJs: json["public_custom_js"],
        offlineText: json["offline_text"],
    );

    Map<String, dynamic> toJson() => {
        "default_album_art_url": defaultAlbumArtUrl,
        "public_custom_css": publicCustomCss,
        "public_custom_js": publicCustomJs,
        "offline_text": offlineText,
    };
}

class FrontendConfig {
    String customConfig;
    String sourcePw;
    String adminPw;
    String relayPw;
    String streamerPw;
    int port;
    String maxListeners;
    String bannedIps;
    String bannedUserAgents;
    List<dynamic> bannedCountries;
    String allowedIps;
    String scLicenseId;
    String scUserId;

    FrontendConfig({
        required this.customConfig,
        required this.sourcePw,
        required this.adminPw,
        required this.relayPw,
        required this.streamerPw,
        required this.port,
        required this.maxListeners,
        required this.bannedIps,
        required this.bannedUserAgents,
        required this.bannedCountries,
        required this.allowedIps,
        required this.scLicenseId,
        required this.scUserId,
    });

    factory FrontendConfig.fromJson(Map<String, dynamic> json) => FrontendConfig(
        customConfig: json["custom_config"],
        sourcePw: json["source_pw"],
        adminPw: json["admin_pw"],
        relayPw: json["relay_pw"],
        streamerPw: json["streamer_pw"],
        port: json["port"],
        maxListeners: json["max_listeners"],
        bannedIps: json["banned_ips"],
        bannedUserAgents: json["banned_user_agents"],
        bannedCountries: List<dynamic>.from(json["banned_countries"].map((x) => x)),
        allowedIps: json["allowed_ips"],
        scLicenseId: json["sc_license_id"],
        scUserId: json["sc_user_id"],
    );

    Map<String, dynamic> toJson() => {
        "custom_config": customConfig,
        "source_pw": sourcePw,
        "admin_pw": adminPw,
        "relay_pw": relayPw,
        "streamer_pw": streamerPw,
        "port": port,
        "max_listeners": maxListeners,
        "banned_ips": bannedIps,
        "banned_user_agents": bannedUserAgents,
        "banned_countries": List<dynamic>.from(bannedCountries.map((x) => x)),
        "allowed_ips": allowedIps,
        "sc_license_id": scLicenseId,
        "sc_user_id": scUserId,
    };
}

class Links {
    String self;
    String manage;
    String clone;

    Links({
        required this.self,
        required this.manage,
        required this.clone,
    });

    factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
        manage: json["manage"],
        clone: json["clone"],
    );

    Map<String, dynamic> toJson() => {
        "self": self,
        "manage": manage,
        "clone": clone,
    };
}
