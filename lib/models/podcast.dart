// To parse this JSON data, do
//
//     final podcast = podcastFromJson(jsonString);

import 'dart:convert';

List<Podcast> podcastFromJson(String str) =>
    List<Podcast>.from(json.decode(str).map((x) => Podcast.fromJson(x)));

String podcastToJson(List<Podcast> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Podcast {
  String? id;
  int? storageLocationId;
  String? source;
  dynamic playlistId;
  bool? playlistAutoPublish;
  String? title;
  String? link;
  String? description;
  String? descriptionShort;
  bool? isEnabled;
  BrandingConfig? brandingConfig;
  String? language;
  String? languageName;
  String? author;
  String? email;
  bool? hasCustomArt;
  String? art;
  int? artUpdatedAt;
  bool? isPublished;
  int? episodes;
  List<Category>? categories;
  Links? links;

  Podcast({
    this.id,
    this.storageLocationId,
    this.source,
    this.playlistId,
    this.playlistAutoPublish,
    this.title,
    this.link,
    this.description,
    this.descriptionShort,
    this.isEnabled,
    this.brandingConfig,
    this.language,
    this.languageName,
    this.author,
    this.email,
    this.hasCustomArt,
    this.art,
    this.artUpdatedAt,
    this.isPublished,
    this.episodes,
    this.categories,
    this.links,
  });

  Podcast copyWith({
    String? id,
    int? storageLocationId,
    String? source,
    dynamic playlistId,
    bool? playlistAutoPublish,
    String? title,
    String? link,
    String? description,
    String? descriptionShort,
    bool? isEnabled,
    BrandingConfig? brandingConfig,
    String? language,
    String? languageName,
    String? author,
    String? email,
    bool? hasCustomArt,
    String? art,
    int? artUpdatedAt,
    bool? isPublished,
    int? episodes,
    List<Category>? categories,
    Links? links,
  }) =>
      Podcast(
        id: id ?? this.id,
        storageLocationId: storageLocationId ?? this.storageLocationId,
        source: source ?? this.source,
        playlistId: playlistId ?? this.playlistId,
        playlistAutoPublish: playlistAutoPublish ?? this.playlistAutoPublish,
        title: title ?? this.title,
        link: link ?? this.link,
        description: description ?? this.description,
        descriptionShort: descriptionShort ?? this.descriptionShort,
        isEnabled: isEnabled ?? this.isEnabled,
        brandingConfig: brandingConfig ?? this.brandingConfig,
        language: language ?? this.language,
        languageName: languageName ?? this.languageName,
        author: author ?? this.author,
        email: email ?? this.email,
        hasCustomArt: hasCustomArt ?? this.hasCustomArt,
        art: art ?? this.art,
        artUpdatedAt: artUpdatedAt ?? this.artUpdatedAt,
        isPublished: isPublished ?? this.isPublished,
        episodes: episodes ?? this.episodes,
        categories: categories ?? this.categories,
        links: links ?? this.links,
      );

  factory Podcast.fromJson(Map<String, dynamic> json) => Podcast(
        id: json["id"],
        storageLocationId: json["storage_location_id"],
        source: json["source"],
        playlistId: json["playlist_id"],
        playlistAutoPublish: json["playlist_auto_publish"],
        title: json["title"],
        link: json["link"],
        description: json["description"],
        descriptionShort: json["description_short"],
        isEnabled: json["is_enabled"],
        brandingConfig: json["branding_config"] == null
            ? null
            : BrandingConfig.fromJson(json["branding_config"]),
        language: json["language"],
        languageName: json["language_name"],
        author: json["author"],
        email: json["email"],
        hasCustomArt: json["has_custom_art"],
        art: json["art"],
        artUpdatedAt: json["art_updated_at"],
        isPublished: json["is_published"],
        episodes: json["episodes"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storage_location_id": storageLocationId,
        "source": source,
        "playlist_id": playlistId,
        "playlist_auto_publish": playlistAutoPublish,
        "title": title,
        "link": link,
        "description": description,
        "description_short": descriptionShort,
        "is_enabled": isEnabled,
        "branding_config": brandingConfig?.toJson(),
        "language": language,
        "language_name": languageName,
        "author": author,
        "email": email,
        "has_custom_art": hasCustomArt,
        "art": art,
        "art_updated_at": artUpdatedAt,
        "is_published": isPublished,
        "episodes": episodes,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "links": links?.toJson(),
      };
}

class BrandingConfig {
  dynamic publicCustomHtml;

  BrandingConfig({
    this.publicCustomHtml,
  });

  BrandingConfig copyWith({
    dynamic publicCustomHtml,
  }) =>
      BrandingConfig(
        publicCustomHtml: publicCustomHtml ?? this.publicCustomHtml,
      );

  factory BrandingConfig.fromJson(Map<String, dynamic> json) => BrandingConfig(
        publicCustomHtml: json["public_custom_html"],
      );

  Map<String, dynamic> toJson() => {
        "public_custom_html": publicCustomHtml,
      };
}

class Category {
  String? category;
  String? text;
  String? title;
  String? subtitle;

  Category({
    this.category,
    this.text,
    this.title,
    this.subtitle,
  });

  Category copyWith({
    String? category,
    String? text,
    String? title,
    String? subtitle,
  }) =>
      Category(
        category: category ?? this.category,
        text: text ?? this.text,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        category: json["category"],
        text: json["text"],
        title: json["title"],
        subtitle: json["subtitle"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "text": text,
        "title": title,
        "subtitle": subtitle,
      };
}

class Links {
  String? self;
  String? episodes;
  String? publicEpisodes;
  String? publicFeed;
  String? art;
  String? episodeNewArt;
  String? episodeNewMedia;
  String? batch;

  Links({
    this.self,
    this.episodes,
    this.publicEpisodes,
    this.publicFeed,
    this.art,
    this.episodeNewArt,
    this.episodeNewMedia,
    this.batch,
  });

  Links copyWith({
    String? self,
    String? episodes,
    String? publicEpisodes,
    String? publicFeed,
    String? art,
    String? episodeNewArt,
    String? episodeNewMedia,
    String? batch,
  }) =>
      Links(
        self: self ?? this.self,
        episodes: episodes ?? this.episodes,
        publicEpisodes: publicEpisodes ?? this.publicEpisodes,
        publicFeed: publicFeed ?? this.publicFeed,
        art: art ?? this.art,
        episodeNewArt: episodeNewArt ?? this.episodeNewArt,
        episodeNewMedia: episodeNewMedia ?? this.episodeNewMedia,
        batch: batch ?? this.batch,
      );

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"],
        episodes: json["episodes"],
        publicEpisodes: json["public_episodes"],
        publicFeed: json["public_feed"],
        art: json["art"],
        episodeNewArt: json["episode_new_art"],
        episodeNewMedia: json["episode_new_media"],
        batch: json["batch"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
        "episodes": episodes,
        "public_episodes": publicEpisodes,
        "public_feed": publicFeed,
        "art": art,
        "episode_new_art": episodeNewArt,
        "episode_new_media": episodeNewMedia,
        "batch": batch,
      };
}

// Storage location model for the dropdown
class StorageLocation {
  int? value;
  String? text;
  String? description;

  StorageLocation({
    this.value,
    this.text,
    this.description,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) =>
      StorageLocation(
        value: json["value"],
        text: json["text"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "text": text,
        "description": description,
      };
}

class StorageLocations {
  List<StorageLocation>? mediaStorageLocation;
  List<StorageLocation>? recordingsStorageLocation;
  List<StorageLocation>? podcastsStorageLocation;

  StorageLocations({
    this.mediaStorageLocation,
    this.recordingsStorageLocation,
    this.podcastsStorageLocation,
  });

  factory StorageLocations.fromJson(Map<String, dynamic> json) =>
      StorageLocations(
        mediaStorageLocation: json["media_storage_location"] == null
            ? []
            : List<StorageLocation>.from(json["media_storage_location"]!
                .map((x) => StorageLocation.fromJson(x))),
        recordingsStorageLocation: json["recordings_storage_location"] == null
            ? []
            : List<StorageLocation>.from(json["recordings_storage_location"]!
                .map((x) => StorageLocation.fromJson(x))),
        podcastsStorageLocation: json["podcasts_storage_location"] == null
            ? []
            : List<StorageLocation>.from(json["podcasts_storage_location"]!
                .map((x) => StorageLocation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "media_storage_location": mediaStorageLocation == null
            ? []
            : List<dynamic>.from(mediaStorageLocation!.map((x) => x.toJson())),
        "recordings_storage_location": recordingsStorageLocation == null
            ? []
            : List<dynamic>.from(
                recordingsStorageLocation!.map((x) => x.toJson())),
        "podcasts_storage_location": podcastsStorageLocation == null
            ? []
            : List<dynamic>.from(
                podcastsStorageLocation!.map((x) => x.toJson())),
      };
}
