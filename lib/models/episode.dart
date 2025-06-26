class Episode {
  final String id;
  final String title;
  final String? link;
  final String description;
  final String descriptionShort;
  final bool explicit;
  final int? seasonNumber;
  final int? episodeNumber;
  final int createdAt;
  final int publishAt;
  final bool isPublished;
  final bool hasMedia;
  final String? playlistMediaId;
  final PlaylistMedia? playlistMedia;
  final EpisodeMedia? media;
  final bool hasCustomArt;
  final String? art;
  final int artUpdatedAt;
  final EpisodeLinks links;

  Episode({
    required this.id,
    required this.title,
    this.link,
    required this.description,
    required this.descriptionShort,
    required this.explicit,
    this.seasonNumber,
    this.episodeNumber,
    required this.createdAt,
    required this.publishAt,
    required this.isPublished,
    required this.hasMedia,
    this.playlistMediaId,
    this.playlistMedia,
    this.media,
    required this.hasCustomArt,
    this.art,
    required this.artUpdatedAt,
    required this.links,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'],
      description: json['description'] ?? '',
      descriptionShort: json['description_short'] ?? '',
      explicit: json['explicit'] ?? false,
      seasonNumber: json['season_number'],
      episodeNumber: json['episode_number'],
      createdAt: json['created_at'] ?? 0,
      publishAt: json['publish_at'] ?? 0,
      isPublished: json['is_published'] ?? false,
      hasMedia: json['has_media'] ?? false,
      playlistMediaId: json['playlist_media_id'],
      playlistMedia: json['playlist_media'] != null
          ? PlaylistMedia.fromJson(json['playlist_media'])
          : null,
      media:
          json['media'] != null ? EpisodeMedia.fromJson(json['media']) : null,
      hasCustomArt: json['has_custom_art'] ?? false,
      art: json['art'],
      artUpdatedAt: json['art_updated_at'] ?? 0,
      links: EpisodeLinks.fromJson(json['links'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'description': description,
      'description_short': descriptionShort,
      'explicit': explicit,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'created_at': createdAt,
      'publish_at': publishAt,
      'is_published': isPublished,
      'has_media': hasMedia,
      'playlist_media_id': playlistMediaId,
      'playlist_media': playlistMedia?.toJson(),
      'media': media?.toJson(),
      'has_custom_art': hasCustomArt,
      'art': art,
      'art_updated_at': artUpdatedAt,
    };
  }
}

class PlaylistMedia {
  final String text;
  final String? artist;
  final String? title;
  final String? album;
  final String? genre;
  final String? isrc;
  final String? lyrics;
  final String id;
  final String? art;
  final List<String>? customFields;

  PlaylistMedia({
    required this.text,
    this.artist,
    this.title,
    this.album,
    this.genre,
    this.isrc,
    this.lyrics,
    required this.id,
    this.art,
    this.customFields,
  });

  factory PlaylistMedia.fromJson(Map<String, dynamic> json) {
    return PlaylistMedia(
      text: json['text'] ?? '',
      artist: json['artist'],
      title: json['title'],
      album: json['album'],
      genre: json['genre'],
      isrc: json['isrc'],
      lyrics: json['lyrics'],
      id: json['id'] ?? '',
      art: json['art'],
      customFields: json['custom_fields'] != null
          ? List<String>.from(json['custom_fields'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'artist': artist,
      'title': title,
      'album': album,
      'genre': genre,
      'isrc': isrc,
      'lyrics': lyrics,
      'id': id,
      'art': art,
      'custom_fields': customFields,
    };
  }
}

class EpisodeMedia {
  final String? id;
  final String? originalName;
  final double? length;
  final String? lengthText;
  final String? path;

  EpisodeMedia({
    this.id,
    this.originalName,
    this.length,
    this.lengthText,
    this.path,
  });

  factory EpisodeMedia.fromJson(Map<String, dynamic> json) {
    return EpisodeMedia(
      id: json['id'],
      originalName: json['original_name'],
      length: json['length']?.toDouble(),
      lengthText: json['length_text'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_name': originalName,
      'length': length,
      'length_text': lengthText,
      'path': path,
    };
  }
}

class EpisodeLinks {
  final String? self;
  final String? public;
  final String? download;
  final String? art;
  final String? media;

  EpisodeLinks({
    this.self,
    this.public,
    this.download,
    this.art,
    this.media,
  });

  factory EpisodeLinks.fromJson(Map<String, dynamic> json) {
    return EpisodeLinks(
      self: json['self'],
      public: json['public'],
      download: json['download'],
      art: json['art'],
      media: json['media'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'self': self,
      'public': public,
      'download': download,
      'art': art,
      'media': media,
    };
  }
}
