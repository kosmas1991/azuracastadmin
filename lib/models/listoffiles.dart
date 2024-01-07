import 'dart:convert';

List<ListOfFiles> listOfFilesFromJson(String str) => List<ListOfFiles>.from(json.decode(str).map((x) => ListOfFiles.fromJson(x)));

String listOfFilesToJson(List<ListOfFiles> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListOfFiles {
    String? uniqueId;
    dynamic album;
    dynamic genre;
    dynamic lyrics;
    dynamic isrc;
    double? length;
    String? lengthText;
    String? path;
    int? mtime;
    dynamic amplify;
    dynamic fadeOverlap;
    dynamic fadeIn;
    dynamic fadeOut;
    dynamic cueIn;
    dynamic cueOut;
    int? artUpdatedAt;

    int? id;
    String? songId;
    String? text;
    String? artist;
    String? title;
    List<dynamic>? customFields;
    Links? links;

    ListOfFiles({
        this.uniqueId,
        this.album,
        this.genre,
        this.lyrics,
        this.isrc,
        this.length,
        this.lengthText,
        this.path,
        this.mtime,
        this.amplify,
        this.fadeOverlap,
        this.fadeIn,
        this.fadeOut,
        this.cueIn,
        this.cueOut,
        this.artUpdatedAt,

        this.id,
        this.songId,
        this.text,
        this.artist,
        this.title,
        this.customFields,
        this.links,
    });

    factory ListOfFiles.fromJson(Map<String, dynamic> json) => ListOfFiles(
        uniqueId: json["unique_id"],
        album: json["album"],
        genre: json["genre"],
        lyrics: json["lyrics"],
        isrc: json["isrc"],
        length: json["length"]?.toDouble(),
        lengthText: json["length_text"],
        path: json["path"],
        mtime: json["mtime"],
        amplify: json["amplify"],
        fadeOverlap: json["fade_overlap"],
        fadeIn: json["fade_in"],
        fadeOut: json["fade_out"],
        cueIn: json["cue_in"],
        cueOut: json["cue_out"],
        artUpdatedAt: json["art_updated_at"],
    
        id: json["id"],
        songId: json["song_id"],
        text: json["text"],
        artist: json["artist"],
        title: json["title"],
        customFields: json["custom_fields"] == null ? [] : List<dynamic>.from(json["custom_fields"]!.map((x) => x)),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "unique_id": uniqueId,
        "album": album,
        "genre": genre,
        "lyrics": lyrics,
        "isrc": isrc,
        "length": length,
        "length_text": lengthText,
        "path": path,
        "mtime": mtime,
        "amplify": amplify,
        "fade_overlap": fadeOverlap,
        "fade_in": fadeIn,
        "fade_out": fadeOut,
        "cue_in": cueIn,
        "cue_out": cueOut,
        "art_updated_at": artUpdatedAt,

        "id": id,
        "song_id": songId,
        "text": text,
        "artist": artist,
        "title": title,
        "custom_fields": customFields == null ? [] : List<dynamic>.from(customFields!.map((x) => x)),
        "links": links?.toJson(),
    };
}

class Links {
    String? self;

    Links({
        this.self,
    });

    factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
    );

    Map<String, dynamic> toJson() => {
        "self": self,
    };
}

enum Name {
    ALL
}

final nameValues = EnumValues({
    "All": Name.ALL
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
