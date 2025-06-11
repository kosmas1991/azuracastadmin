import 'dart:convert';

class ApiResponse {
  bool success;
  String message;
  String? formattedMessage;
  int? code;
  String? type;
  Map<String, dynamic>? extraData;

  ApiResponse({
    required this.success,
    required this.message,
    this.formattedMessage,
    this.code,
    this.type,
    this.extraData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      formattedMessage: json['formatted_message'],
      code: json['code'],
      type: json['type'],
      extraData: json['extra_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'formatted_message': formattedMessage,
      'code': code,
      'type': type,
      'extra_data': extraData,
    };
  }
}

ApiResponse apiResponseFromJson(String str) => ApiResponse.fromJson(json.decode(str));

String apiResponseToJson(ApiResponse data) => json.encode(data.toJson());
