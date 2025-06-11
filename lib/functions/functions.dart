import 'dart:convert';
import 'dart:io';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:azuracastadmin/models/cpustats.dart';
import 'package:azuracastadmin/models/ftpusers.dart';
import 'package:azuracastadmin/models/historyfiles.dart';
import 'package:azuracastadmin/models/listeners.dart';
import 'package:azuracastadmin/models/listoffiles.dart';
import 'package:azuracastadmin/models/nextsongs.dart';
import 'package:azuracastadmin/models/nowplaying.dart';
import 'package:azuracastadmin/models/radiostations.dart';
import 'package:azuracastadmin/models/requestsongdata.dart';
import 'package:azuracastadmin/models/settings.dart';
import 'package:azuracastadmin/models/stationsstatus.dart';
import 'package:azuracastadmin/models/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

Future<Response> getResponse({
  required String url,
  required String path,
  String? apiKey,
  int? id,
}) async {
  Response response;
  if (apiKey != null && id == null) {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': '${apiKey}',
    };
    response =
        await http.get(Uri.parse('${url}/api/${path}'), headers: headers);
  } else if (id != null && apiKey == null) {
    response = await http.get(Uri.parse('${url}/api/${path}/${id}'));
  } else if (apiKey != null && id != null) {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': '${apiKey}',
    };
    response = await http.get(Uri.parse('${url}/api/station/${id}/${path}'),
        headers: headers);
  } else {
    response = await http.get(Uri.parse('${url}/api/${path}'));
  }
  return response;
}

Future<CpuStats> fetchCpuStats(String url, String path, String apiKey) async {
  Response response = await getResponse(url: url, path: path, apiKey: apiKey);
  if (response.statusCode == 200) {
    CpuStats cpuStats = CpuStats.fromJson(jsonDecode(response.body));
    return cpuStats;
  } else {
    throw Exception('Failed');
  }
}

Future<List<RadioStations>> fetchRadioStations(String url, String path) async {
  Response response = await getResponse(url: url, path: path);
  if (response.statusCode == 200) {
    List<RadioStations> radioStations = (json.decode(response.body) as List)
        .map((i) => RadioStations.fromJson(i))
        .toList();

    return radioStations;
  } else {
    throw Exception('Failed');
  }
}

Future<NowPlaying> fetchNowPlaying(String url, String path, int id) async {
  Response response = await getResponse(url: url, path: path, id: id);
  if (response.statusCode == 200) {
    return NowPlaying.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed');
  }
}

Future<List<NextSongs>> fetchNextSongs(
    String url, String path, String apiKey, int id) async {
  Response response =
      await getResponse(url: url, path: path, apiKey: apiKey, id: id);
  if (response.statusCode == 200) {
    List<NextSongs> nextSongs = (json.decode(response.body) as List)
        .map((i) => NextSongs.fromJson(i))
        .toList();

    return nextSongs;
  } else {
    throw Exception('Failed');
  }
}

Future<StationStatus> fetchStatus(
    String url, String path, String apiKey, int id) async {
  final headers = {
    'accept': 'application/json',
    'X-API-Key': '${apiKey}',
  };
  var response = await http.get(Uri.parse('${url}/api/station/${id}/${path}'),
      headers: headers);
  if (response.statusCode == 200) {
    return StationStatus.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed');
  }
}

Future<Response> postAdminActions(
    String url, String path, String apiKey, int id, String action) async {
  var response = await http.post(headers: <String, String>{
    'accept': 'application/json',
    'X-API-Key': '${apiKey}',
  }, Uri.parse('${url}/api/station/${id}/${path}/${action}'));
  return response;
}

Future<List<ActiveListeners>> fetchListeners(
    String url, String path, String apiKey, int id) async {
  Response response =
      await getResponse(url: url, path: path, apiKey: apiKey, id: id);
  if (response.statusCode == 200) {
    List<ActiveListeners> activeListeners = (json.decode(response.body) as List)
        .map((i) => ActiveListeners.fromJson(i))
        .toList();

    return activeListeners;
  } else {
    throw Exception('Failed');
  }
}

Future<List<ListOfFiles>> fetchListOfFiles(
    String url, String path, String apiKey, int id) async {
  Response response =
      await getResponse(url: url, path: path, apiKey: apiKey, id: id);

  if (response.statusCode == 200) {
    List<ListOfFiles> listOfFiles = listOfFilesFromJson(response.body);


    return listOfFiles;
  } else {
 
    throw Exception('Failed');
  }
}

Future<List<HistoryFiles>> fetchHistoryFiles(
    String url, String apiKey, int id, String startDate, String endDate) async {
  final headers = {
    'accept': 'application/json',
    'X-API-Key': '${apiKey}',
  };
  Response response = await http.get(
      Uri.parse(
          '${url}/api/station/${id}/history?start=${startDate}&end=${endDate}'),
      headers: headers);
  if (response.statusCode == 200) {
    List<HistoryFiles> historyFiles = (json.decode(response.body) as List)
        .map((i) => HistoryFiles.fromJson(i))
        .toList();

    return historyFiles;
  } else {
    throw Exception('Failed');
  }
}

Future<List<Users>> fetchUsers(String url, String path, String apiKey) async {
  Response response = await getResponse(url: url, path: path, apiKey: apiKey);
  if (response.statusCode == 200) {
    List<Users> users = (json.decode(response.body) as List)
        .map((i) => Users.fromJson(i))
        .toList();
    return users;
  } else {
    throw Exception('Failed');
  }
}

Future<List<FtpUsers>> fetchFTPUsers(
    String url, int id, String path, String apiKey) async {
  Response response =
      await getResponse(url: url, id: id, path: path, apiKey: apiKey);
  if (response.statusCode == 200) {
    List<FtpUsers> FTPusers = (json.decode(response.body) as List)
        .map((i) => FtpUsers.fromJson(i))
        .toList();
    return FTPusers;
  } else {
    throw Exception('Failed');
  }
}

Future<Response> putFTPUser(
    {required String url,
    required String path,
    required String apiKey,
    required int stationID,
    required int userID,
    required String pass,
    required String username}) async {
  var response = await http.put(
      body: jsonEncode(<String, dynamic>{
        "id": userID,
        "username": username,
        "password": pass,
        "publicKeys": "",
      }),
      headers: <String, String>{
        'accept': 'application/json',
        'X-API-Key': '${apiKey}',
      },
      Uri.parse('${url}/api/station/${stationID}/${path}/${userID}'));

  return response;
}

Future<SettingsModel> fetchSettings(
    String url, String path, String apiKey) async {
  Response response = await getResponse(url: url, path: path, apiKey: apiKey);
  if (response.statusCode == 200) {
    SettingsModel settings = SettingsModel.fromJson(jsonDecode(response.body));
    return settings;
  } else {
    throw Exception('Failed');
  }
}

void requestNewSong(String theURL, String url, BuildContext context) async {
  var response = await http.get(Uri.parse('${theURL}${url}'));
  if (response.body.contains('"success":true')) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      'Song just added to the song queue',
      style: TextStyle(color: Colors.green),
    )));
  } else if (response.body.contains('Duplicate request')) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      'Failed! Song already requested!',
      style: TextStyle(color: Colors.red),
    )));
  } else if (response.body.contains('played too recently')) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      'Failed! Same song or artist played too recently!',
      style: TextStyle(color: Colors.red),
    )));
  } else if (response.body.contains('a request too recently')) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      'Failed! You asked for another request too recently!',
      style: TextStyle(color: Colors.red),
    )));
  } else {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      'Failed!',
      style: TextStyle(color: Colors.red),
    )));
  }
}

Future<List<RequestSongData>> fetchSongRequestList(
    String theURL, int theStationID) async {
  var response = await http
      .get(Uri.parse('${theURL}/api/station/${theStationID}/requests'));

  if (response.statusCode == 200) {
    List<RequestSongData> data = (json.decode(response.body) as List)
        .map((i) => RequestSongData.fromJson(i))
        .toList();
    return data;
  } else {
    throw Exception('Failed');
  }
}

// Upload art for a file
Future<ApiResponse> uploadFileArt({
  required String url,
  required String apiKey,
  required int stationID,
  required int fileID,
  required File imageFile,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$url/api/station/$stationID/art/$fileID'),
  );

  request.headers.addAll({
    'accept': 'application/json',
    'X-API-Key': apiKey,
  });

  request.files.add(
    await http.MultipartFile.fromPath('file', imageFile.path),
  );

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    return ApiResponse.fromJson(json.decode(response.body));
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Upload failed: $e',
      code: 500,
    );
  }
}

// Delete art for a file
Future<ApiResponse> deleteFileArt({
  required String url,
  required String apiKey,
  required int stationID,
  required int fileID,
}) async {
  try {
    var response = await http.delete(
      Uri.parse('$url/api/station/$stationID/art/$fileID'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    return ApiResponse.fromJson(json.decode(response.body));
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete failed: $e',
      code: 500,
    );
  }
}

// Update file details
Future<ApiResponse> updateFileDetails({
  required String url,
  required String apiKey,
  required int stationID,
  required int fileID,
  required Map<String, dynamic> fileData,
}) async {
  try {
    var response = await http.put(
      Uri.parse('$url/api/station/$stationID/file/$fileID'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(fileData),
    );

    return ApiResponse.fromJson(json.decode(response.body));
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Update failed: $e',
      code: 500,
    );
  }
}

// Delete file
Future<ApiResponse> deleteFile({
  required String url,
  required String apiKey,
  required int stationID,
  required int fileID,
}) async {
  try {
    var response = await http.delete(
      Uri.parse('$url/api/station/$stationID/file/$fileID'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    return ApiResponse.fromJson(json.decode(response.body));
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete failed: $e',
      code: 500,
    );
  }
}

// Download file from AzuraCast server
Future<ApiResponse> downloadFile({
  required String url,
  required String apiKey,
  required int stationID,
  required String filePath,
  required String fileName,
}) async {
  try {
    // Make the HTTP request to download the file
    var response = await http.get(
      Uri.parse('$url/api/station/$stationID/files/download?file=${Uri.encodeComponent(filePath)}'),
      headers: {
        'accept': 'application/octet-stream',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      // Get the downloads directory
      Directory downloadsDirectory;
      
      if (Platform.isAndroid) {
        // For Android, use external storage Downloads folder
        Directory androidDownloads = Directory('/storage/emulated/0/Download');
        if (androidDownloads.existsSync()) {
          downloadsDirectory = androidDownloads;
        } else {
          // Fallback to app documents directory if Downloads folder is not accessible
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        downloadsDirectory = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms, use downloads directory
        downloadsDirectory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      // Create the full file path
      final String fullPath = '${downloadsDirectory.path}/$fileName';
      final File file = File(fullPath);

      // Write the file
      await file.writeAsBytes(response.bodyBytes);

      return ApiResponse(
        success: true,
        message: 'File downloaded successfully to: $fullPath',
        code: 200,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Download failed with status code: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Download failed: $e',
      code: 500,
    );
  }
}
