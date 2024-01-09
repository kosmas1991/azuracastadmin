import 'dart:convert';

List<FtpUsers> ftpUsersFromJson(String str) => List<FtpUsers>.from(json.decode(str).map((x) => FtpUsers.fromJson(x)));

String ftpUsersToJson(List<FtpUsers> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FtpUsers {
    String? username;
    String? password;
    dynamic publicKeys;
    int? id;
    Links? links;

    FtpUsers({
        this.username,
        this.password,
        this.publicKeys,
        this.id,
        this.links,
    });

    factory FtpUsers.fromJson(Map<String, dynamic> json) => FtpUsers(
        username: json["username"],
        password: json["password"],
        publicKeys: json["publicKeys"],
        id: json["id"],
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "publicKeys": publicKeys,
        "id": id,
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
