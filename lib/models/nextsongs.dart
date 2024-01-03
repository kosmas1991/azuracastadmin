import 'dart:convert';

List<NextSongs> nextSongsFromJson(String str) => List<NextSongs>.from(json.decode(str).map((x) => NextSongs.fromJson(x)));

String nextSongsToJson(List<NextSongs> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NextSongs {
    int cuedAt;
    int playedAt;
    int duration;
    String playlist;
    bool isRequest;
    Song song;
    bool sentToAutodj;
    bool isPlayed;
    dynamic autodjCustomUri;
    List<String> log;
    Links links;

    NextSongs({
        required this.cuedAt,
        required this.playedAt,
        required this.duration,
        required this.playlist,
        required this.isRequest,
        required this.song,
        required this.sentToAutodj,
        required this.isPlayed,
        required this.autodjCustomUri,
        required this.log,
        required this.links,
    });

    factory NextSongs.fromJson(Map<String, dynamic> json) => NextSongs(
        cuedAt: json["cued_at"],
        playedAt: json["played_at"],
        duration: json["duration"],
        playlist: json["playlist"],
        isRequest: json["is_request"],
        song: Song.fromJson(json["song"]),
        sentToAutodj: json["sent_to_autodj"],
        isPlayed: json["is_played"],
        autodjCustomUri: json["autodj_custom_uri"],
        log: List<String>.from(json["log"].map((x) => x)),
        links: Links.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "cued_at": cuedAt,
        "played_at": playedAt,
        "duration": duration,
        "playlist": playlist,
        "is_request": isRequest,
        "song": song.toJson(),
        "sent_to_autodj": sentToAutodj,
        "is_played": isPlayed,
        "autodj_custom_uri": autodjCustomUri,
        "log": List<dynamic>.from(log.map((x) => x)),
        "links": links.toJson(),
    };
}

class Links {
    String self;

    Links({
        required this.self,
    });

    factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
    );

    Map<String, dynamic> toJson() => {
        "self": self,
    };
}

class Song {
    String id;
    String text;
    String artist;
    String title;
    String album;
    String genre;
    String isrc;
    String lyrics;
    String art;
    List<dynamic> customFields;

    Song({
        required this.id,
        required this.text,
        required this.artist,
        required this.title,
        required this.album,
        required this.genre,
        required this.isrc,
        required this.lyrics,
        required this.art,
        required this.customFields,
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
        customFields: List<dynamic>.from(json["custom_fields"].map((x) => x)),
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
        "custom_fields": List<dynamic>.from(customFields.map((x) => x)),
    };
}
