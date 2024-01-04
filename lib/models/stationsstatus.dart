import 'dart:convert';

StationStatus stationStatusFromJson(String str) => StationStatus.fromJson(json.decode(str));

String stationStatusToJson(StationStatus data) => json.encode(data.toJson());

class StationStatus {
    bool? backendRunning;
    bool? frontendRunning;
    bool? stationHasStarted;
    bool? stationNeedsRestart;

    StationStatus({
        this.backendRunning,
        this.frontendRunning,
        this.stationHasStarted,
        this.stationNeedsRestart,
    });

    factory StationStatus.fromJson(Map<String, dynamic> json) => StationStatus(
        backendRunning: json["backend_running"],
        frontendRunning: json["frontend_running"],
        stationHasStarted: json["station_has_started"],
        stationNeedsRestart: json["station_needs_restart"],
    );

    Map<String, dynamic> toJson() => {
        "backend_running": backendRunning,
        "frontend_running": frontendRunning,
        "station_has_started": stationHasStarted,
        "station_needs_restart": stationNeedsRestart,
    };
}
