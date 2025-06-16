import 'dart:convert';

List<Station> stationsFromJson(String str) =>
    List<Station>.from(json.decode(str).map((x) => Station.fromJson(x)));

String stationsToJson(List<Station> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Station {
  String? name;
  String? shortName;
  bool? isEnabled;
  String? frontendType;
  FrontendConfig? frontendConfig;
  String? backendType;
  BackendConfig? backendConfig;
  String? description;
  String? url;
  String? genre;
  String? radioBaseDir;
  bool? enableRequests;
  int? requestDelay;
  int? requestThreshold;
  int? disconnectDeactivateStreamer;
  bool? enableStreamers;
  bool? isStreamerLive;
  bool? enablePublicPage;
  bool? enableOnDemand;
  bool? enableOnDemandDownload;
  bool? enableHls;
  int? apiHistoryItems;
  String? timezone;
  int? maxBitrate;
  int? maxMounts;
  int? maxHlsStreams;
  BrandingConfig? brandingConfig;
  int? mediaStorageLocation;
  int? recordingsStorageLocation;
  int? podcastsStorageLocation;
  String? fallbackPath;
  int? id;
  StationLinks? links;

  Station({
    this.name,
    this.shortName,
    this.isEnabled,
    this.frontendType,
    this.frontendConfig,
    this.backendType,
    this.backendConfig,
    this.description,
    this.url,
    this.genre,
    this.radioBaseDir,
    this.enableRequests,
    this.requestDelay,
    this.requestThreshold,
    this.disconnectDeactivateStreamer,
    this.enableStreamers,
    this.isStreamerLive,
    this.enablePublicPage,
    this.enableOnDemand,
    this.enableOnDemandDownload,
    this.enableHls,
    this.apiHistoryItems,
    this.timezone,
    this.maxBitrate,
    this.maxMounts,
    this.maxHlsStreams,
    this.brandingConfig,
    this.mediaStorageLocation,
    this.recordingsStorageLocation,
    this.podcastsStorageLocation,
    this.fallbackPath,
    this.id,
    this.links,
  });

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        name: json["name"],
        shortName: json["short_name"],
        isEnabled: json["is_enabled"],
        frontendType: json["frontend_type"],
        frontendConfig: json["frontend_config"] == null
            ? null
            : FrontendConfig.fromJson(json["frontend_config"]),
        backendType: json["backend_type"],
        backendConfig: json["backend_config"] == null
            ? null
            : BackendConfig.fromJson(json["backend_config"]),
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
        maxBitrate: json["max_bitrate"],
        maxMounts: json["max_mounts"],
        maxHlsStreams: json["max_hls_streams"],
        brandingConfig: json["branding_config"] == null
            ? null
            : BrandingConfig.fromJson(json["branding_config"]),
        mediaStorageLocation: json["media_storage_location"],
        recordingsStorageLocation: json["recordings_storage_location"],
        podcastsStorageLocation: json["podcasts_storage_location"],
        fallbackPath: json["fallback_path"],
        id: json["id"],
        links:
            json["links"] == null ? null : StationLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "short_name": shortName,
        "is_enabled": isEnabled,
        "frontend_type": frontendType,
        "frontend_config": frontendConfig?.toJson(),
        "backend_type": backendType,
        "backend_config": backendConfig?.toJson(),
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
        "max_bitrate": maxBitrate,
        "max_mounts": maxMounts,
        "max_hls_streams": maxHlsStreams,
        "branding_config": brandingConfig?.toJson(),
        "media_storage_location": mediaStorageLocation,
        "recordings_storage_location": recordingsStorageLocation,
        "podcasts_storage_location": podcastsStorageLocation,
        "fallback_path": fallbackPath,
        "id": id,
        "links": links?.toJson(),
      };
}

class FrontendConfig {
  String? adminPw;
  dynamic allowedIps;
  List<dynamic>? bannedCountries;
  dynamic bannedIps;
  dynamic bannedUserAgents;
  String? customConfig;
  dynamic maxListeners;
  int? port;
  String? relayPw;
  dynamic scLicenseId;
  dynamic scUserId;
  String? sourcePw;
  String? streamerPw;

  FrontendConfig({
    this.adminPw,
    this.allowedIps,
    this.bannedCountries,
    this.bannedIps,
    this.bannedUserAgents,
    this.customConfig,
    this.maxListeners,
    this.port,
    this.relayPw,
    this.scLicenseId,
    this.scUserId,
    this.sourcePw,
    this.streamerPw,
  });

  factory FrontendConfig.fromJson(Map<String, dynamic> json) => FrontendConfig(
        adminPw: json["admin_pw"],
        allowedIps: json["allowed_ips"],
        bannedCountries: json["banned_countries"] == null
            ? []
            : List<dynamic>.from(json["banned_countries"]!.map((x) => x)),
        bannedIps: json["banned_ips"],
        bannedUserAgents: json["banned_user_agents"],
        customConfig: json["custom_config"],
        maxListeners: json["max_listeners"],
        port: json["port"],
        relayPw: json["relay_pw"],
        scLicenseId: json["sc_license_id"],
        scUserId: json["sc_user_id"],
        sourcePw: json["source_pw"],
        streamerPw: json["streamer_pw"],
      );

  Map<String, dynamic> toJson() => {
        "admin_pw": adminPw,
        "allowed_ips": allowedIps,
        "banned_countries": bannedCountries == null
            ? []
            : List<dynamic>.from(bannedCountries!.map((x) => x)),
        "banned_ips": bannedIps,
        "banned_user_agents": bannedUserAgents,
        "custom_config": customConfig,
        "max_listeners": maxListeners,
        "port": port,
        "relay_pw": relayPw,
        "sc_license_id": scLicenseId,
        "sc_user_id": scUserId,
        "source_pw": sourcePw,
        "streamer_pw": streamerPw,
      };
}

class BackendConfig {
  String? audioProcessingMethod;
  int? autodjQueueLength;
  String? charset;
  int? crossfade;
  String? crossfadeType;
  dynamic customConfig;
  dynamic customConfigBottom;
  dynamic customConfigPreFade;
  dynamic customConfigPreLive;
  dynamic customConfigPrePlaylists;
  dynamic customConfigTop;
  int? djBuffer;
  String? djMountPoint;
  int? djPort;
  int? duplicatePreventionTimeRange;
  bool? enableAutoCue;
  bool? enableReplaygainMetadata;
  bool? hlsEnableOnPublicPlayer;
  bool? hlsIsDefault;
  int? hlsSegmentLength;
  int? hlsSegmentsInPlaylist;
  int? hlsSegmentsOverhead;
  String? liveBroadcastText;
  int? masterMeLoudnessTarget;
  String? masterMePreset;
  String? performanceMode;
  bool? postProcessingIncludeLive;
  bool? recordStreams;
  int? recordStreamsBitrate;
  String? recordStreamsFormat;
  dynamic stereoToolConfigurationPath;
  dynamic stereoToolLicenseKey;
  int? telnetPort;
  bool? useManualAutodj;
  bool? writePlaylistsToLiquidsoap;

  BackendConfig({
    this.audioProcessingMethod,
    this.autodjQueueLength,
    this.charset,
    this.crossfade,
    this.crossfadeType,
    this.customConfig,
    this.customConfigBottom,
    this.customConfigPreFade,
    this.customConfigPreLive,
    this.customConfigPrePlaylists,
    this.customConfigTop,
    this.djBuffer,
    this.djMountPoint,
    this.djPort,
    this.duplicatePreventionTimeRange,
    this.enableAutoCue,
    this.enableReplaygainMetadata,
    this.hlsEnableOnPublicPlayer,
    this.hlsIsDefault,
    this.hlsSegmentLength,
    this.hlsSegmentsInPlaylist,
    this.hlsSegmentsOverhead,
    this.liveBroadcastText,
    this.masterMeLoudnessTarget,
    this.masterMePreset,
    this.performanceMode,
    this.postProcessingIncludeLive,
    this.recordStreams,
    this.recordStreamsBitrate,
    this.recordStreamsFormat,
    this.stereoToolConfigurationPath,
    this.stereoToolLicenseKey,
    this.telnetPort,
    this.useManualAutodj,
    this.writePlaylistsToLiquidsoap,
  });

  factory BackendConfig.fromJson(Map<String, dynamic> json) => BackendConfig(
        audioProcessingMethod: json["audio_processing_method"],
        autodjQueueLength: json["autodj_queue_length"],
        charset: json["charset"],
        crossfade: json["crossfade"],
        crossfadeType: json["crossfade_type"],
        customConfig: json["custom_config"],
        customConfigBottom: json["custom_config_bottom"],
        customConfigPreFade: json["custom_config_pre_fade"],
        customConfigPreLive: json["custom_config_pre_live"],
        customConfigPrePlaylists: json["custom_config_pre_playlists"],
        customConfigTop: json["custom_config_top"],
        djBuffer: json["dj_buffer"],
        djMountPoint: json["dj_mount_point"],
        djPort: json["dj_port"],
        duplicatePreventionTimeRange: json["duplicate_prevention_time_range"],
        enableAutoCue: json["enable_auto_cue"],
        enableReplaygainMetadata: json["enable_replaygain_metadata"],
        hlsEnableOnPublicPlayer: json["hls_enable_on_public_player"],
        hlsIsDefault: json["hls_is_default"],
        hlsSegmentLength: json["hls_segment_length"],
        hlsSegmentsInPlaylist: json["hls_segments_in_playlist"],
        hlsSegmentsOverhead: json["hls_segments_overhead"],
        liveBroadcastText: json["live_broadcast_text"],
        masterMeLoudnessTarget: json["master_me_loudness_target"],
        masterMePreset: json["master_me_preset"],
        performanceMode: json["performance_mode"],
        postProcessingIncludeLive: json["post_processing_include_live"],
        recordStreams: json["record_streams"],
        recordStreamsBitrate: json["record_streams_bitrate"],
        recordStreamsFormat: json["record_streams_format"],
        stereoToolConfigurationPath: json["stereo_tool_configuration_path"],
        stereoToolLicenseKey: json["stereo_tool_license_key"],
        telnetPort: json["telnet_port"],
        useManualAutodj: json["use_manual_autodj"],
        writePlaylistsToLiquidsoap: json["write_playlists_to_liquidsoap"],
      );

  Map<String, dynamic> toJson() => {
        "audio_processing_method": audioProcessingMethod,
        "autodj_queue_length": autodjQueueLength,
        "charset": charset,
        "crossfade": crossfade,
        "crossfade_type": crossfadeType,
        "custom_config": customConfig,
        "custom_config_bottom": customConfigBottom,
        "custom_config_pre_fade": customConfigPreFade,
        "custom_config_pre_live": customConfigPreLive,
        "custom_config_pre_playlists": customConfigPrePlaylists,
        "custom_config_top": customConfigTop,
        "dj_buffer": djBuffer,
        "dj_mount_point": djMountPoint,
        "dj_port": djPort,
        "duplicate_prevention_time_range": duplicatePreventionTimeRange,
        "enable_auto_cue": enableAutoCue,
        "enable_replaygain_metadata": enableReplaygainMetadata,
        "hls_enable_on_public_player": hlsEnableOnPublicPlayer,
        "hls_is_default": hlsIsDefault,
        "hls_segment_length": hlsSegmentLength,
        "hls_segments_in_playlist": hlsSegmentsInPlaylist,
        "hls_segments_overhead": hlsSegmentsOverhead,
        "live_broadcast_text": liveBroadcastText,
        "master_me_loudness_target": masterMeLoudnessTarget,
        "master_me_preset": masterMePreset,
        "performance_mode": performanceMode,
        "post_processing_include_live": postProcessingIncludeLive,
        "record_streams": recordStreams,
        "record_streams_bitrate": recordStreamsBitrate,
        "record_streams_format": recordStreamsFormat,
        "stereo_tool_configuration_path": stereoToolConfigurationPath,
        "stereo_tool_license_key": stereoToolLicenseKey,
        "telnet_port": telnetPort,
        "use_manual_autodj": useManualAutodj,
        "write_playlists_to_liquidsoap": writePlaylistsToLiquidsoap,
      };
}

class BrandingConfig {
  dynamic defaultAlbumArtUrl;
  dynamic offlineText;
  dynamic publicCustomCss;
  dynamic publicCustomJs;

  BrandingConfig({
    this.defaultAlbumArtUrl,
    this.offlineText,
    this.publicCustomCss,
    this.publicCustomJs,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) => BrandingConfig(
        defaultAlbumArtUrl: json["default_album_art_url"],
        offlineText: json["offline_text"],
        publicCustomCss: json["public_custom_css"],
        publicCustomJs: json["public_custom_js"],
      );

  Map<String, dynamic> toJson() => {
        "default_album_art_url": defaultAlbumArtUrl,
        "offline_text": offlineText,
        "public_custom_css": publicCustomCss,
        "public_custom_js": publicCustomJs,
      };
}

class StationLinks {
  String? self;
  String? manage;
  String? clone;

  StationLinks({
    this.self,
    this.manage,
    this.clone,
  });

  factory StationLinks.fromJson(Map<String, dynamic> json) => StationLinks(
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
