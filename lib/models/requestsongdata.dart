class RequestSongData {
  String? requestId;
  String? requestUrl;
  Song? song;

  RequestSongData({this.requestId, this.requestUrl, this.song});

  RequestSongData.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    requestUrl = json['request_url'];
    song = json['song'] != null ? new Song.fromJson(json['song']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = this.requestId;
    data['request_url'] = this.requestUrl;
    if (this.song != null) {
      data['song'] = this.song!.toJson();
    }
    return data;
  }
}

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
  List<Null>? customFields;

  Song(
      {this.id,
      this.text,
      this.artist,
      this.title,
      this.album,
      this.genre,
      this.isrc,
      this.lyrics,
      this.art,
      this.customFields});

  Song.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    artist = json['artist'];
    title = json['title'];
    album = json['album'];
    genre = json['genre'];
    isrc = json['isrc'];
    lyrics = json['lyrics'];
    art = json['art'];
    if (json['custom_fields'] != null) {
      customFields = <Null>[];
      json['custom_fields'].forEach((v) {});
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['artist'] = this.artist;
    data['title'] = this.title;
    data['album'] = this.album;
    data['genre'] = this.genre;
    data['isrc'] = this.isrc;
    data['lyrics'] = this.lyrics;
    data['art'] = this.art;
    if (this.customFields != null) {}
    return data;
  }
}