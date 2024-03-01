// To parse this JSON data, do
//
//     final settingsModel = settingsModelFromJson(jsonString);

import 'dart:convert';

SettingsModel settingsModelFromJson(String str) => SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
    String? appUniqueIdentifier;
    String? baseUrl;
    String? instanceName;
    bool? preferBrowserUrl;
    bool? useRadioProxy;
    int? historyKeepDays;
    bool? alwaysUseSsl;
    String? apiAccessControl;
    bool? enableStaticNowplaying;
    String? analytics;
    bool? checkForUpdates;
    UpdateResults? updateResults;
    int? updateLastRun;
    dynamic publicTheme;
    bool? hideAlbumArt;
    String? homepageRedirectUrl;
    dynamic defaultAlbumArtUrl;
    bool? useExternalAlbumArtWhenProcessingMedia;
    bool? useExternalAlbumArtInApis;
    String? lastFmApiKey;
    bool? hideProductName;
    dynamic publicCustomCss;
    dynamic publicCustomJs;
    dynamic internalCustomCss;
    bool? backupEnabled;
    dynamic backupTimeCode;
    bool? backupExcludeMedia;
    int? backupKeepCopies;
    int? backupStorageLocation;
    dynamic backupFormat;
    int? backupLastRun;
    String? backupLastOutput;
    int? setupCompleteTime;
    bool? syncDisabled;
    int? syncLastRun;
    dynamic externalIp;
    dynamic geoliteLicenseKey;
    int? geoliteLastRun;
    bool? enableAdvancedFeatures;
    bool? mailEnabled;
    String? mailSenderName;
    String? mailSenderEmail;
    String? mailSmtpHost;
    int? mailSmtpPort;
    String? mailSmtpUsername;
    String? mailSmtpPassword;
    bool? mailSmtpSecure;
    String? avatarService;
    String? avatarDefaultUrl;
    String? acmeEmail;
    String? acmeDomains;
    String? ipSource;

    SettingsModel({
        this.appUniqueIdentifier,
        this.baseUrl,
        this.instanceName,
        this.preferBrowserUrl,
        this.useRadioProxy,
        this.historyKeepDays,
        this.alwaysUseSsl,
        this.apiAccessControl,
        this.enableStaticNowplaying,
        this.analytics,
        this.checkForUpdates,
        this.updateResults,
        this.updateLastRun,
        this.publicTheme,
        this.hideAlbumArt,
        this.homepageRedirectUrl,
        this.defaultAlbumArtUrl,
        this.useExternalAlbumArtWhenProcessingMedia,
        this.useExternalAlbumArtInApis,
        this.lastFmApiKey,
        this.hideProductName,
        this.publicCustomCss,
        this.publicCustomJs,
        this.internalCustomCss,
        this.backupEnabled,
        this.backupTimeCode,
        this.backupExcludeMedia,
        this.backupKeepCopies,
        this.backupStorageLocation,
        this.backupFormat,
        this.backupLastRun,
        this.backupLastOutput,
        this.setupCompleteTime,
        this.syncDisabled,
        this.syncLastRun,
        this.externalIp,
        this.geoliteLicenseKey,
        this.geoliteLastRun,
        this.enableAdvancedFeatures,
        this.mailEnabled,
        this.mailSenderName,
        this.mailSenderEmail,
        this.mailSmtpHost,
        this.mailSmtpPort,
        this.mailSmtpUsername,
        this.mailSmtpPassword,
        this.mailSmtpSecure,
        this.avatarService,
        this.avatarDefaultUrl,
        this.acmeEmail,
        this.acmeDomains,
        this.ipSource,
    });

    factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        appUniqueIdentifier: json["app_unique_identifier"],
        baseUrl: json["base_url"],
        instanceName: json["instance_name"],
        preferBrowserUrl: json["prefer_browser_url"],
        useRadioProxy: json["use_radio_proxy"],
        historyKeepDays: json["history_keep_days"],
        alwaysUseSsl: json["always_use_ssl"],
        apiAccessControl: json["api_access_control"],
        enableStaticNowplaying: json["enable_static_nowplaying"],
        analytics: json["analytics"],
        checkForUpdates: json["check_for_updates"],
        updateResults: json["update_results"] == null ? null : UpdateResults.fromJson(json["update_results"]),
        updateLastRun: json["update_last_run"],
        publicTheme: json["public_theme"],
        hideAlbumArt: json["hide_album_art"],
        homepageRedirectUrl: json["homepage_redirect_url"],
        defaultAlbumArtUrl: json["default_album_art_url"],
        useExternalAlbumArtWhenProcessingMedia: json["use_external_album_art_when_processing_media"],
        useExternalAlbumArtInApis: json["use_external_album_art_in_apis"],
        lastFmApiKey: json["last_fm_api_key"],
        hideProductName: json["hide_product_name"],
        publicCustomCss: json["public_custom_css"],
        publicCustomJs: json["public_custom_js"],
        internalCustomCss: json["internal_custom_css"],
        backupEnabled: json["backup_enabled"],
        backupTimeCode: json["backup_time_code"],
        backupExcludeMedia: json["backup_exclude_media"],
        backupKeepCopies: json["backup_keep_copies"],
        backupStorageLocation: json["backup_storage_location"],
        backupFormat: json["backup_format"],
        backupLastRun: json["backup_last_run"],
        backupLastOutput: json["backup_last_output"],
        setupCompleteTime: json["setup_complete_time"],
        syncDisabled: json["sync_disabled"],
        syncLastRun: json["sync_last_run"],
        externalIp: json["external_ip"],
        geoliteLicenseKey: json["geolite_license_key"],
        geoliteLastRun: json["geolite_last_run"],
        enableAdvancedFeatures: json["enable_advanced_features"],
        mailEnabled: json["mail_enabled"],
        mailSenderName: json["mail_sender_name"],
        mailSenderEmail: json["mail_sender_email"],
        mailSmtpHost: json["mail_smtp_host"],
        mailSmtpPort: json["mail_smtp_port"],
        mailSmtpUsername: json["mail_smtp_username"],
        mailSmtpPassword: json["mail_smtp_password"],
        mailSmtpSecure: json["mail_smtp_secure"],
        avatarService: json["avatar_service"],
        avatarDefaultUrl: json["avatar_default_url"],
        acmeEmail: json["acme_email"],
        acmeDomains: json["acme_domains"],
        ipSource: json["ip_source"],
    );

    Map<String, dynamic> toJson() => {
        "app_unique_identifier": appUniqueIdentifier,
        "base_url": baseUrl,
        "instance_name": instanceName,
        "prefer_browser_url": preferBrowserUrl,
        "use_radio_proxy": useRadioProxy,
        "history_keep_days": historyKeepDays,
        "always_use_ssl": alwaysUseSsl,
        "api_access_control": apiAccessControl,
        "enable_static_nowplaying": enableStaticNowplaying,
        "analytics": analytics,
        "check_for_updates": checkForUpdates,
        "update_results": updateResults?.toJson(),
        "update_last_run": updateLastRun,
        "public_theme": publicTheme,
        "hide_album_art": hideAlbumArt,
        "homepage_redirect_url": homepageRedirectUrl,
        "default_album_art_url": defaultAlbumArtUrl,
        "use_external_album_art_when_processing_media": useExternalAlbumArtWhenProcessingMedia,
        "use_external_album_art_in_apis": useExternalAlbumArtInApis,
        "last_fm_api_key": lastFmApiKey,
        "hide_product_name": hideProductName,
        "public_custom_css": publicCustomCss,
        "public_custom_js": publicCustomJs,
        "internal_custom_css": internalCustomCss,
        "backup_enabled": backupEnabled,
        "backup_time_code": backupTimeCode,
        "backup_exclude_media": backupExcludeMedia,
        "backup_keep_copies": backupKeepCopies,
        "backup_storage_location": backupStorageLocation,
        "backup_format": backupFormat,
        "backup_last_run": backupLastRun,
        "backup_last_output": backupLastOutput,
        "setup_complete_time": setupCompleteTime,
        "sync_disabled": syncDisabled,
        "sync_last_run": syncLastRun,
        "external_ip": externalIp,
        "geolite_license_key": geoliteLicenseKey,
        "geolite_last_run": geoliteLastRun,
        "enable_advanced_features": enableAdvancedFeatures,
        "mail_enabled": mailEnabled,
        "mail_sender_name": mailSenderName,
        "mail_sender_email": mailSenderEmail,
        "mail_smtp_host": mailSmtpHost,
        "mail_smtp_port": mailSmtpPort,
        "mail_smtp_username": mailSmtpUsername,
        "mail_smtp_password": mailSmtpPassword,
        "mail_smtp_secure": mailSmtpSecure,
        "avatar_service": avatarService,
        "avatar_default_url": avatarDefaultUrl,
        "acme_email": acmeEmail,
        "acme_domains": acmeDomains,
        "ip_source": ipSource,
    };
}

class UpdateResults {
    String? currentRelease;
    String? latestRelease;
    bool? needsRollingUpdate;
    int? rollingUpdatesAvailable;
    List<dynamic>? rollingUpdatesList;
    bool? needsReleaseUpdate;
    bool? canSwitchToStable;

    UpdateResults({
        this.currentRelease,
        this.latestRelease,
        this.needsRollingUpdate,
        this.rollingUpdatesAvailable,
        this.rollingUpdatesList,
        this.needsReleaseUpdate,
        this.canSwitchToStable,
    });

    factory UpdateResults.fromJson(Map<String, dynamic> json) => UpdateResults(
        currentRelease: json["currentRelease"],
        latestRelease: json["latestRelease"],
        needsRollingUpdate: json["needs_rolling_update"],
        rollingUpdatesAvailable: json["rolling_updates_available"],
        rollingUpdatesList: json["rolling_updates_list"] == null ? [] : List<dynamic>.from(json["rolling_updates_list"]!.map((x) => x)),
        needsReleaseUpdate: json["needs_release_update"],
        canSwitchToStable: json["can_switch_to_stable"],
    );

    Map<String, dynamic> toJson() => {
        "currentRelease": currentRelease,
        "latestRelease": latestRelease,
        "needs_rolling_update": needsRollingUpdate,
        "rolling_updates_available": rollingUpdatesAvailable,
        "rolling_updates_list": rollingUpdatesList == null ? [] : List<dynamic>.from(rollingUpdatesList!.map((x) => x)),
        "needs_release_update": needsReleaseUpdate,
        "can_switch_to_stable": canSwitchToStable,
    };
}
