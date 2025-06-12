// To parse this JSON data, do
//
//     final charts = chartsFromJson(jsonString);

import 'dart:convert';

Charts chartsFromJson(String str) => Charts.fromJson(json.decode(str));

String chartsToJson(Charts data) => json.encode(data.toJson());

class Charts {
  Daily? daily;
  DayOfWeek? dayOfWeek;
  Hourly? hourly;

  Charts({
    this.daily,
    this.dayOfWeek,
    this.hourly,
  });

  Charts copyWith({
    Daily? daily,
    DayOfWeek? dayOfWeek,
    Hourly? hourly,
  }) =>
      Charts(
        daily: daily ?? this.daily,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        hourly: hourly ?? this.hourly,
      );

  factory Charts.fromJson(Map<String, dynamic> json) => Charts(
        daily: json["daily"] == null ? null : Daily.fromJson(json["daily"]),
        dayOfWeek: json["day_of_week"] == null
            ? null
            : DayOfWeek.fromJson(json["day_of_week"]),
        hourly: json["hourly"] == null ? null : Hourly.fromJson(json["hourly"]),
      );

  Map<String, dynamic> toJson() => {
        "daily": daily?.toJson(),
        "day_of_week": dayOfWeek?.toJson(),
        "hourly": hourly?.toJson(),
      };
}

class Daily {
  List<DailyMetric>? metrics;
  List<Alt>? alt;

  Daily({
    this.metrics,
    this.alt,
  });

  Daily copyWith({
    List<DailyMetric>? metrics,
    List<Alt>? alt,
  }) =>
      Daily(
        metrics: metrics ?? this.metrics,
        alt: alt ?? this.alt,
      );

  factory Daily.fromJson(Map<String, dynamic> json) => Daily(
        metrics: json["metrics"] == null
            ? []
            : List<DailyMetric>.from(
                json["metrics"]!.map((x) => DailyMetric.fromJson(x))),
        alt: json["alt"] == null
            ? []
            : List<Alt>.from(json["alt"]!.map((x) => Alt.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "metrics": metrics == null
            ? []
            : List<dynamic>.from(metrics!.map((x) => x.toJson())),
        "alt":
            alt == null ? [] : List<dynamic>.from(alt!.map((x) => x.toJson())),
      };
}

class Alt {
  String? label;
  List<AltValue>? values;

  Alt({
    this.label,
    this.values,
  });

  Alt copyWith({
    String? label,
    List<AltValue>? values,
  }) =>
      Alt(
        label: label ?? this.label,
        values: values ?? this.values,
      );

  factory Alt.fromJson(Map<String, dynamic> json) => Alt(
        label: json["label"],
        values: json["values"] == null
            ? []
            : List<AltValue>.from(
                json["values"]!.map((x) => AltValue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "values": values == null
            ? []
            : List<dynamic>.from(values!.map((x) => x.toJson())),
      };
}

class AltValue {
  String? label;
  String? type;
  int? original;
  String? value;

  AltValue({
    this.label,
    this.type,
    this.original,
    this.value,
  });

  AltValue copyWith({
    String? label,
    String? type,
    int? original,
    String? value,
  }) =>
      AltValue(
        label: label ?? this.label,
        type: type ?? this.type,
        original: original ?? this.original,
        value: value ?? this.value,
      );

  factory AltValue.fromJson(Map<String, dynamic> json) => AltValue(
        label: json["label"],
        type: json["type"],
        original: json["original"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "type": type,
        "original": original,
        "value": value,
      };
}

class DailyMetric {
  String? label;
  String? type;
  bool? fill;
  List<DataPoint>? data;

  DailyMetric({
    this.label,
    this.type,
    this.fill,
    this.data,
  });

  DailyMetric copyWith({
    String? label,
    String? type,
    bool? fill,
    List<DataPoint>? data,
  }) =>
      DailyMetric(
        label: label ?? this.label,
        type: type ?? this.type,
        fill: fill ?? this.fill,
        data: data ?? this.data,
      );

  factory DailyMetric.fromJson(Map<String, dynamic> json) => DailyMetric(
        label: json["label"],
        type: json["type"],
        fill: json["fill"],
        data: json["data"] == null
            ? []
            : List<DataPoint>.from(
                json["data"]!.map((x) => DataPoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "type": type,
        "fill": fill,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DataPoint {
  int? x;
  int? y;

  DataPoint({
    this.x,
    this.y,
  });

  DataPoint copyWith({
    int? x,
    int? y,
  }) =>
      DataPoint(
        x: x ?? this.x,
        y: y ?? this.y,
      );

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}

class DayOfWeek {
  List<String>? labels;
  List<DayOfWeekMetric>? metrics;
  List<Alt>? alt;

  DayOfWeek({
    this.labels,
    this.metrics,
    this.alt,
  });

  DayOfWeek copyWith({
    List<String>? labels,
    List<DayOfWeekMetric>? metrics,
    List<Alt>? alt,
  }) =>
      DayOfWeek(
        labels: labels ?? this.labels,
        metrics: metrics ?? this.metrics,
        alt: alt ?? this.alt,
      );

  factory DayOfWeek.fromJson(Map<String, dynamic> json) => DayOfWeek(
        labels: json["labels"] == null
            ? []
            : List<String>.from(json["labels"]!.map((x) => x)),
        metrics: json["metrics"] == null
            ? []
            : List<DayOfWeekMetric>.from(
                json["metrics"]!.map((x) => DayOfWeekMetric.fromJson(x))),
        alt: json["alt"] == null
            ? []
            : List<Alt>.from(json["alt"]!.map((x) => Alt.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "labels":
            labels == null ? [] : List<dynamic>.from(labels!.map((x) => x)),
        "metrics": metrics == null
            ? []
            : List<dynamic>.from(metrics!.map((x) => x.toJson())),
        "alt":
            alt == null ? [] : List<dynamic>.from(alt!.map((x) => x.toJson())),
      };
}

class DayOfWeekMetric {
  String? label;
  List<int>? data;

  DayOfWeekMetric({
    this.label,
    this.data,
  });

  DayOfWeekMetric copyWith({
    String? label,
    List<int>? data,
  }) =>
      DayOfWeekMetric(
        label: label ?? this.label,
        data: data ?? this.data,
      );

  factory DayOfWeekMetric.fromJson(Map<String, dynamic> json) =>
      DayOfWeekMetric(
        label: json["label"],
        data: json["data"] == null
            ? []
            : List<int>.from(json["data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
      };
}

class Hourly {
  HourlyData? all;
  HourlyData? day0;
  HourlyData? day1;
  HourlyData? day2;
  HourlyData? day3;
  HourlyData? day4;
  HourlyData? day5;
  HourlyData? day6;

  Hourly({
    this.all,
    this.day0,
    this.day1,
    this.day2,
    this.day3,
    this.day4,
    this.day5,
    this.day6,
  });

  Hourly copyWith({
    HourlyData? all,
    HourlyData? day0,
    HourlyData? day1,
    HourlyData? day2,
    HourlyData? day3,
    HourlyData? day4,
    HourlyData? day5,
    HourlyData? day6,
  }) =>
      Hourly(
        all: all ?? this.all,
        day0: day0 ?? this.day0,
        day1: day1 ?? this.day1,
        day2: day2 ?? this.day2,
        day3: day3 ?? this.day3,
        day4: day4 ?? this.day4,
        day5: day5 ?? this.day5,
        day6: day6 ?? this.day6,
      );

  factory Hourly.fromJson(Map<String, dynamic> json) => Hourly(
        all: json["all"] == null ? null : HourlyData.fromJson(json["all"]),
        day0: json["day0"] == null ? null : HourlyData.fromJson(json["day0"]),
        day1: json["day1"] == null ? null : HourlyData.fromJson(json["day1"]),
        day2: json["day2"] == null ? null : HourlyData.fromJson(json["day2"]),
        day3: json["day3"] == null ? null : HourlyData.fromJson(json["day3"]),
        day4: json["day4"] == null ? null : HourlyData.fromJson(json["day4"]),
        day5: json["day5"] == null ? null : HourlyData.fromJson(json["day5"]),
        day6: json["day6"] == null ? null : HourlyData.fromJson(json["day6"]),
      );

  Map<String, dynamic> toJson() => {
        "all": all?.toJson(),
        "day0": day0?.toJson(),
        "day1": day1?.toJson(),
        "day2": day2?.toJson(),
        "day3": day3?.toJson(),
        "day4": day4?.toJson(),
        "day5": day5?.toJson(),
        "day6": day6?.toJson(),
      };
}

class HourlyData {
  List<String>? labels;
  List<DayOfWeekMetric>? metrics;
  List<Alt>? alt;

  HourlyData({
    this.labels,
    this.metrics,
    this.alt,
  });

  HourlyData copyWith({
    List<String>? labels,
    List<DayOfWeekMetric>? metrics,
    List<Alt>? alt,
  }) =>
      HourlyData(
        labels: labels ?? this.labels,
        metrics: metrics ?? this.metrics,
        alt: alt ?? this.alt,
      );

  factory HourlyData.fromJson(Map<String, dynamic> json) => HourlyData(
        labels: json["labels"] == null
            ? []
            : List<String>.from(json["labels"]!.map((x) => x)),
        metrics: json["metrics"] == null
            ? []
            : List<DayOfWeekMetric>.from(
                json["metrics"]!.map((x) => DayOfWeekMetric.fromJson(x))),
        alt: json["alt"] == null
            ? []
            : List<Alt>.from(json["alt"]!.map((x) => Alt.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "labels":
            labels == null ? [] : List<dynamic>.from(labels!.map((x) => x)),
        "metrics": metrics == null
            ? []
            : List<dynamic>.from(metrics!.map((x) => x.toJson())),
        "alt":
            alt == null ? [] : List<dynamic>.from(alt!.map((x) => x.toJson())),
      };
}
