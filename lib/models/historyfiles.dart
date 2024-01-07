import 'dart:convert';

List<HistoryFiles> historyFilesFromJson(String str) => List<HistoryFiles>.from(json.decode(str).map((x) => HistoryFiles.fromJson(x)));

String historyFilesToJson(List<HistoryFiles> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistoryFiles {
    int? shId;
    int? playedAt;
    int? duration;
    Playlist? playlist;
    String? streamer;
    bool? isRequest;
    Song? song;
    int? listenersStart;
    int? listenersEnd;
    int? deltaTotal;
    bool? isVisible;

    HistoryFiles({
        this.shId,
        this.playedAt,
        this.duration,
        this.playlist,
        this.streamer,
        this.isRequest,
        this.song,
        this.listenersStart,
        this.listenersEnd,
        this.deltaTotal,
        this.isVisible,
    });

    factory HistoryFiles.fromJson(Map<String, dynamic> json) => HistoryFiles(
        shId: json["sh_id"],
        playedAt: json["played_at"],
        duration: json["duration"],
        playlist: playlistValues.map[json["playlist"]]!,
        streamer: json["streamer"],
        isRequest: json["is_request"],
        song: json["song"] == null ? null : Song.fromJson(json["song"]),
        listenersStart: json["listeners_start"],
        listenersEnd: json["listeners_end"],
        deltaTotal: json["delta_total"],
        isVisible: json["is_visible"],
    );

    Map<String, dynamic> toJson() => {
        "sh_id": shId,
        "played_at": playedAt,
        "duration": duration,
        "playlist": playlistValues.reverse[playlist],
        "streamer": streamer,
        "is_request": isRequest,
        "song": song?.toJson(),
        "listeners_start": listenersStart,
        "listeners_end": listenersEnd,
        "delta_total": deltaTotal,
        "is_visible": isVisible,
    };
}

enum Playlist {
    ALL,
    EMPTY
}

final playlistValues = EnumValues({
    "All": Playlist.ALL,
    "": Playlist.EMPTY
});

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
        customFields: json["custom_fields"] == null ? [] : List<dynamic>.from(json["custom_fields"]!.map((x) => x)),
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
        "custom_fields": customFields == null ? [] : List<dynamic>.from(customFields!.map((x) => x)),
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
