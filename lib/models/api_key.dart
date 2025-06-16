import 'dart:convert';

List<ApiKey> apiKeyFromJson(String str) =>
    List<ApiKey>.from(json.decode(str).map((x) => ApiKey.fromJson(x)));

String apiKeyToJson(List<ApiKey> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ApiKey {
  String? comment;
  String? id;
  ApiKeyLinks? links;

  ApiKey({
    this.comment,
    this.id,
    this.links,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        comment: json["comment"],
        id: json["id"],
        links:
            json["links"] == null ? null : ApiKeyLinks.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "comment": comment,
        "id": id,
        "links": links?.toJson(),
      };
}

class ApiKeyLinks {
  String? self;

  ApiKeyLinks({
    this.self,
  });

  factory ApiKeyLinks.fromJson(Map<String, dynamic> json) => ApiKeyLinks(
        self: json["self"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
      };
}
