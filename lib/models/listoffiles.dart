import 'dart:convert';

class ListOfFiles {
  int id;
  String uniqueId;
  String songId;
  String? art; // Nullable
  String? path; // Nullable
  int? mtime; // Nullable
  int? uploadedAt; // Nullable
  int? artUpdatedAt; // Nullable
  int? length; // Nullable
  String? lengthText; // Nullable
  Map<String, dynamic> customFields;
  ExtraMetadata? extraMetadata; // Nullable
  List<Playlist>? playlists; // Nullable
  String? text; // Nullable
  String? artist; // Nullable
  String? title; // Nullable
  String? album; // Nullable
  String? genre; // Nullable
  String? isrc; // Nullable
  String? lyrics; // Nullable
  Links? links; // Nullable

  ListOfFiles({
    required this.id,
    required this.uniqueId,
    required this.songId,
    this.art,
    this.path,
    this.mtime,
    this.uploadedAt,
    this.artUpdatedAt,
    this.length,
    this.lengthText,
    required this.customFields,
    this.extraMetadata,
    this.playlists,
    this.text,
    this.artist,
    this.title,
    this.album,
    this.genre,
    this.isrc,
    this.lyrics,
    this.links,
  });

  factory ListOfFiles.fromJson(Map<String, dynamic> json) {
    return ListOfFiles(
      id: json['id'],
      uniqueId: json['unique_id'],
      songId: json['song_id'],
      art: json['art'],
      path: json['path'],
      mtime: json['mtime'],
      uploadedAt: json['uploaded_at'],
      artUpdatedAt: json['art_updated_at'],
      length: json['length'],
      lengthText: json['length_text'],
      customFields: json['custom_fields'] ?? {},
      extraMetadata: json['extra_metadata'] != null
          ? ExtraMetadata.fromJson(json['extra_metadata'])
          : null,
      playlists: json['playlists'] != null
          ? List<Playlist>.from(json['playlists'].map((x) => Playlist.fromJson(x)))
          : null,
      text: json['text'],
      artist: json['artist'],
      title: json['title'],
      album: json['album'],
      genre: json['genre'],
      isrc: json['isrc'],
      lyrics: json['lyrics'],
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
    );
  }
}

class ExtraMetadata {
  dynamic amplify;
  dynamic crossStartNext;
  dynamic cueIn;
  dynamic cueOut;
  dynamic fadeIn;
  dynamic fadeOut;

  ExtraMetadata({
    this.amplify,
    this.crossStartNext,
    this.cueIn,
    this.cueOut,
    this.fadeIn,
    this.fadeOut,
  });

  factory ExtraMetadata.fromJson(Map<String, dynamic> json) {
    return ExtraMetadata(
      amplify: json['amplify'],
      crossStartNext: json['cross_start_next'],
      cueIn: json['cue_in'],
      cueOut: json['cue_out'],
      fadeIn: json['fade_in'],
      fadeOut: json['fade_out'],
    );
  }
}

class Playlist {
  int id;
  String name;
  String shortName;
  int count;

  Playlist({
    required this.id,
    required this.name,
    required this.shortName,
    required this.count,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      count: json['count'],
    );
  }
}

class Links {
  String? self; // Nullable
  String? play; // Nullable
  String? art; // Nullable
  String? waveform; // Nullable
  String? waveformCache; // Nullable

  Links({
    this.self,
    this.play,
    this.art,
    this.waveform,
    this.waveformCache,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      self: json['self'],
      play: json['play'],
      art: json['art'],
      waveform: json['waveform'],
      waveformCache: json['waveform_cache'],
    );
  }
}

List<ListOfFiles> listOfFilesFromJson(String str) {
  final jsonData = json.decode(str);
  return List<ListOfFiles>.from(jsonData.map((x) => ListOfFiles.fromJson(x)));
}
