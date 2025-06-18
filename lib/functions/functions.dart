import 'dart:convert';
import 'dart:io';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:azuracastadmin/models/backup.dart';
import 'package:azuracastadmin/models/charts.dart';
import 'package:azuracastadmin/models/cpustats.dart';
import 'package:azuracastadmin/models/ftpusers.dart';
import 'package:azuracastadmin/models/historyfiles.dart';
import 'package:azuracastadmin/models/listeners.dart';
import 'package:azuracastadmin/models/listoffiles.dart';
import 'package:azuracastadmin/models/nextsongs.dart';
import 'package:azuracastadmin/models/notification.dart';
import 'package:azuracastadmin/models/nowplaying.dart';
import 'package:azuracastadmin/models/radiostations.dart';
import 'package:azuracastadmin/models/requestsongdata.dart';
import 'package:azuracastadmin/models/settings.dart';
import 'package:azuracastadmin/models/station_playlist.dart';
import 'package:azuracastadmin/models/stationsstatus.dart';
import 'package:azuracastadmin/models/user_account.dart';
import 'package:azuracastadmin/models/users.dart';
import 'package:azuracastadmin/models/roles.dart';
import 'package:azuracastadmin/models/permissions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

Future<Charts> fetchCharts(String url, String apiKey, int id) async {
  final headers = {
    'accept': 'application/json',
    'X-API-Key': '${apiKey}',
  };
  Response response = await http.get(
      Uri.parse('${url}/api/station/${id}/reports/overview/charts'),
      headers: headers);
  if (response.statusCode == 200) {
    Charts charts = Charts.fromJson(json.decode(response.body));
    return charts;
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
    String url, int stationID, String path, String apiKey) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
    };

    final response = await http.get(
      Uri.parse('$url/api/station/$stationID/$path'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<FtpUsers> ftpUsers = (json.decode(response.body) as List)
          .map((i) => FtpUsers.fromJson(i))
          .toList();
      return ftpUsers;
    } else {
      throw Exception('Failed to fetch FTP users: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch FTP users: $e');
  }
}

Future<ApiResponse> updateFTPUser({
  required String url,
  required String apiKey,
  required int stationID,
  required int userID,
  required String username,
  required String password,
}) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.put(
      Uri.parse('$url/api/station/$stationID/sftp-user/$userID'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? true,
        message: responseData['message'] ?? 'User updated successfully',
        code: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to update user: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Update failed: $e',
      code: 500,
    );
  }
}

Future<ApiResponse> deleteFTPUser({
  required String url,
  required String apiKey,
  required int stationID,
  required int userID,
}) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
    };

    final response = await http.delete(
      Uri.parse('$url/api/station/$stationID/sftp-user/$userID'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? true,
        message: responseData['message'] ?? 'User deleted successfully',
        code: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to delete user: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete failed: $e',
      code: 500,
    );
  }
}

Future<ApiResponse> createFTPUser({
  required String url,
  required String apiKey,
  required int stationID,
  required String username,
  required String password,
}) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      Uri.parse('$url/api/station/$stationID/sftp-users'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return ApiResponse(
        success: true,
        message: 'User "${responseData['username']}" created successfully',
        code: response.statusCode,
        extraData: responseData,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to create user: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Create failed: $e',
      code: 500,
    );
  }
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

Future<ApiResponse> updateSettings({
  required String url,
  required String apiKey,
  required Map<String, dynamic> settingsData,
}) async {
  try {
    var response = await http.put(
      Uri.parse('$url/api/admin/settings'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(settingsData),
    );

    if (response.statusCode == 200) {
      return ApiResponse(
        success: true,
        message: 'Settings updated successfully',
        code: 200,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to update settings: ${response.body}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Update failed: $e',
      code: 500,
    );
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

// Upload file to AzuraCast server
Future<ApiResponse> uploadFile({
  required String url,
  required String apiKey,
  required int stationID,
  required File audioFile,
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/api/station/$stationID/files/upload'),
    );

    request.headers.addAll({
      'accept': 'application/json',
      'X-API-Key': apiKey,
    });

    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(
        success: false,
        message: 'Upload failed with status code: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Upload failed: $e',
      code: 500,
    );
  }
}

// Helper function to request storage permissions for Android
Future<bool> _requestStoragePermission() async {
  if (!Platform.isAndroid) return true;

  try {
    // Check Android version to determine which permissions to request
    const int androidSdk = 33; // Default to newer Android for safety

    // For Android 13+ (API 33+), we need different permissions
    if (androidSdk >= 33) {
      // For Android 13+, check media permissions
      PermissionStatus audioStatus = await Permission.audio.status;
      if (audioStatus != PermissionStatus.granted) {
        audioStatus = await Permission.audio.request();
        if (audioStatus != PermissionStatus.granted) {
          return false;
        }
      }

      // Try to get manage external storage permission for broader access
      PermissionStatus manageStorageStatus =
          await Permission.manageExternalStorage.status;
      if (manageStorageStatus != PermissionStatus.granted) {
        manageStorageStatus = await Permission.manageExternalStorage.request();
        // For Android 13+, this might not be granted for regular apps, that's okay
      }

      return true; // Audio permission is sufficient for downloads on Android 13+
    } else {
      // For Android 12 and below, use traditional storage permissions
      PermissionStatus manageStorageStatus =
          await Permission.manageExternalStorage.status;

      if (manageStorageStatus == PermissionStatus.granted) {
        return true;
      }

      // If manage external storage is not granted, check regular storage permission
      PermissionStatus storageStatus = await Permission.storage.status;

      if (storageStatus == PermissionStatus.granted) {
        return true;
      }

      // Request regular storage permission first
      storageStatus = await Permission.storage.request();

      if (storageStatus == PermissionStatus.granted) {
        return true;
      }

      // If regular storage permission is denied, try requesting manage external storage
      if (manageStorageStatus != PermissionStatus.permanentlyDenied) {
        manageStorageStatus = await Permission.manageExternalStorage.request();
        return manageStorageStatus == PermissionStatus.granted;
      }

      return false;
    }
  } catch (e) {
    // If permission request fails, return false
    print('Permission request error: $e');
    return false;
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
    // Check and request storage permissions for Android
    if (Platform.isAndroid) {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return ApiResponse(
          success: false,
          message:
              'Storage permission is required to download files. Please enable storage access in app settings.',
          code: 403,
        );
      }
    }

    // Make the HTTP request to download the file
    var response = await http.get(
      Uri.parse(
          '$url/api/station/$stationID/files/download?file=${Uri.encodeComponent(filePath)}'),
      headers: {
        'accept': 'application/octet-stream',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      // Get the downloads directory
      Directory downloadsDirectory;

      if (Platform.isAndroid) {
        // For Android, try multiple approaches to save to Downloads folder
        try {
          // First try: Use the public Downloads directory
          const String publicDownloadsPath = '/storage/emulated/0/Download';
          Directory publicDownloads = Directory(publicDownloadsPath);

          if (await publicDownloads.exists()) {
            // Test write access
            try {
              final testPath = '${publicDownloads.path}/.azuracast_write_test';
              final testFile = File(testPath);
              await testFile.writeAsString('test');
              await testFile.delete();
              downloadsDirectory = publicDownloads;
            } catch (e) {
              throw Exception('No write access to public Downloads');
            }
          } else {
            throw Exception('Public Downloads directory not found');
          }
        } catch (e) {
          // Second try: Use external storage Downloads
          try {
            Directory? externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // Create a Downloads subdirectory in external storage
              downloadsDirectory = Directory('${externalDir.path}/Downloads');
              if (!await downloadsDirectory.exists()) {
                await downloadsDirectory.create(recursive: true);
              }
            } else {
              throw Exception('External storage not available');
            }
          } catch (e) {
            // Final fallback: Use documents directory
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, save directly to the Documents directory to make files visible in Files app
        // The Info.plist has been configured with LSSupportsOpeningDocumentsInPlace and UIFileSharingEnabled
        try {
          downloadsDirectory = await getApplicationDocumentsDirectory();
          // Don't create a Downloads subfolder - save directly to Documents for better visibility
        } catch (e) {
          // Fallback to documents directory (same as above, but explicit)
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For other platforms, try to use downloads directory
        downloadsDirectory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      // Create the full file path
      final String fullPath = '${downloadsDirectory.path}/$fileName';
      final File file = File(fullPath);

      // Write the file
      await file.writeAsBytes(response.bodyBytes);

      // Determine the appropriate success message based on where the file was saved
      String platformMessage;
      if (Platform.isIOS) {
        platformMessage = 'File saved to Documents (visible in Files app)';
      } else if (Platform.isAndroid) {
        if (downloadsDirectory.path.contains('/storage/emulated/0/Download')) {
          platformMessage = 'File downloaded to Downloads folder';
        } else if (downloadsDirectory.path.contains('Downloads')) {
          platformMessage = 'File saved to app Downloads folder';
        } else {
          platformMessage = 'File saved to app storage';
        }
      } else {
        platformMessage = 'File downloaded successfully';
      }

      return ApiResponse(
        success: true,
        message: '$platformMessage: $fileName',
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

// Fetch station playlists
Future<List<StationPlaylist>> fetchStationPlaylists({
  required String url,
  required String apiKey,
  required int stationID,
}) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/station/$stationID/playlists'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      List<StationPlaylist> playlists = (json.decode(response.body) as List)
          .map((i) => StationPlaylist.fromJson(i))
          .toList();
      return playlists;
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch playlists: $e');
  }
}

// Fetch single file details
Future<ListOfFiles> fetchSingleFileDetails({
  required String url,
  required String apiKey,
  required int stationID,
  required int fileID,
}) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/station/$stationID/file/$fileID'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return ListOfFiles.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch file details: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch file details: $e');
  }
}

// Fetch user account information
Future<UserAccount> fetchUserAccount(String url, String apiKey) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/frontend/account/me'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return UserAccount.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user account: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch user account: $e');
  }
}

// Fetch roles
Future<List<RoleModel>> fetchRoles(String url, String apiKey) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/admin/roles'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      List<RoleModel> roles = (json.decode(response.body) as List)
          .map((i) => RoleModel.fromJson(i))
          .toList();
      return roles;
    } else {
      throw Exception('Failed to fetch roles: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch roles: $e');
  }
}

// Update user
Future<ApiResponse> updateUser({
  required String url,
  required String apiKey,
  required int userId,
  required Map<String, dynamic> userData,
}) async {
  try {
    var response = await http.put(
      Uri.parse('$url/api/admin/user/$userId'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(
        success: false,
        message: 'Update failed with status code: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Update failed: $e',
      code: 500,
    );
  }
}

Future<ApiResponse> deleteUser({
  required String url,
  required String apiKey,
  required int userId,
}) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
    };

    final response = await http.delete(
      Uri.parse('$url/api/admin/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'User deleted successfully',
        code: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to delete user: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete failed: $e',
      code: 500,
    );
  }
}

Future<ApiResponse> createUser({
  required String url,
  required String apiKey,
  required Map<String, dynamic> userData,
}) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('$url/api/admin/users'),
      headers: headers,
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return ApiResponse(
        success: true,
        message: 'User created successfully',
        code: response.statusCode,
        extraData: responseData,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to create user: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Create failed: $e',
      code: 500,
    );
  }
}

// Function to fetch notifications from the dashboard endpoint
Future<List<NotificationItem>> fetchNotifications(
    String url, String apiKey) async {
  try {
    final response = await http.get(
      Uri.parse('$url/api/frontend/dashboard/notifications'),
      headers: <String, String>{
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return notificationFromJson(response.body);
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching notifications: $e');
  }
}

// Function to change user password
Future<Map<String, dynamic>> changePassword(String url, String apiKey,
    String currentPassword, String newPassword) async {
  try {
    final response = await http.put(
      Uri.parse('$url/api/frontend/account/password'),
      headers: <String, String>{
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Password changed successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to change password',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

// Fetch API keys for the user
Future<List<ApiKey>> fetchApiKeys(String url, String apiKey) async {
  try {
    final response = await http.get(
      Uri.parse('$url/api/frontend/account/api-keys'),
      headers: <String, String>{
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      List<ApiKey> apiKeys = (json.decode(response.body) as List)
          .map((i) => ApiKey.fromJson(i))
          .toList();
      return apiKeys;
    } else {
      throw Exception('Failed to load API keys: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching API keys: $e');
  }
}

// Function to delete an API key
Future<Map<String, dynamic>> deleteApiKey(
    String url, String apiKey, String keyId) async {
  try {
    final response = await http.delete(
      Uri.parse('$url/api/frontend/account/api-key/$keyId'),
      headers: <String, String>{
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'API key deleted successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to delete API key',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

// Station management functions
Future<List<dynamic>> fetchStations(String url, String apiKey) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
    };

    final response = await http.get(
      Uri.parse('$url/api/admin/stations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stations: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<Map<String, dynamic>> createStation(
  String url,
  String apiKey,
  Map<String, dynamic> stationData,
) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('$url/api/admin/stations'),
      headers: headers,
      body: json.encode(stationData),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Station created successfully',
        'data': responseData,
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to create station',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

Future<Map<String, dynamic>> updateStation(
  String url,
  String apiKey,
  int stationId,
  Map<String, dynamic> stationData,
) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final response = await http.put(
      Uri.parse('$url/api/admin/station/$stationId'),
      headers: headers,
      body: json.encode(stationData),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Station updated successfully',
        'data': responseData,
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to update station',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

Future<Map<String, dynamic>> cloneStation(
  String url,
  String apiKey,
  int stationId,
  String name,
  String description,
) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
    };

    final cloneData = {
      'name': name,
      'description': description,
      'clone': ['media_storage'], // Fixed as per requirements
    };

    final response = await http.post(
      Uri.parse('$url/api/admin/station/$stationId/clone'),
      headers: headers,
      body: json.encode(cloneData),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Station cloned successfully',
        'data': responseData,
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to clone station',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

Future<Map<String, dynamic>> deleteStation(
  String url,
  String apiKey,
  int stationId,
) async {
  try {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': apiKey,
    };

    final response = await http.delete(
      Uri.parse('$url/api/admin/station/$stationId'),
      headers: headers,
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Station deleted successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to delete station',
        'code': responseData['code'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

// Role Management Functions

// Fetch all available permissions
Future<PermissionsModel> fetchPermissions(String url, String apiKey) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/admin/permissions'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return PermissionsModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch permissions: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch permissions: $e');
  }
}

// Create a new role
Future<ApiResponse> createRole({
  required String url,
  required String apiKey,
  required String name,
  required RolePermissions permissions,
}) async {
  try {
    final roleData = {
      'name': name,
      'permissions': permissions.toJson(),
    };

    var response = await http.post(
      Uri.parse('$url/api/admin/roles'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(roleData),
    );

    if (response.statusCode == 200) {
      return ApiResponse(
        success: true,
        message: 'Role created successfully',
        code: response.statusCode,
        extraData: json.decode(response.body),
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to create role: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Create role failed: $e',
      code: 500,
    );
  }
}

// Update an existing role
Future<ApiResponse> updateRole({
  required String url,
  required String apiKey,
  required int roleId,
  required String name,
  required RolePermissions permissions,
}) async {
  try {
    final roleData = {
      'name': name,
      'permissions': permissions.toJson(),
    };

    var response = await http.put(
      Uri.parse('$url/api/admin/role/$roleId'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(roleData),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to update role: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Update role failed: $e',
      code: 500,
    );
  }
}

// Delete a role
Future<ApiResponse> deleteRole({
  required String url,
  required String apiKey,
  required int roleId,
}) async {
  try {
    var response = await http.delete(
      Uri.parse('$url/api/admin/role/$roleId'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to delete role: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete role failed: $e',
      code: 500,
    );
  }
}

// Backup Management Functions

// Fetch all backups
Future<List<Backup>> fetchBackups(String url, String apiKey) async {
  try {
    var response = await http.get(
      Uri.parse('$url/api/admin/backups'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      List<Backup> backups = (json.decode(response.body) as List)
          .map((i) => Backup.fromJson(i))
          .toList();
      return backups;
    } else {
      throw Exception('Failed to fetch backups: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch backups: $e');
  }
}

// Delete a backup
Future<ApiResponse> deleteBackup({
  required String url,
  required String apiKey,
  required String pathEncoded,
}) async {
  try {
    var response = await http.delete(
      Uri.parse('$url/api/admin/backups/delete/$pathEncoded'),
      headers: {
        'accept': 'application/json',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(
        success: false,
        message: 'Failed to delete backup: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Delete backup failed: $e',
      code: 500,
    );
  }
}

// Download a backup
Future<ApiResponse> downloadBackup({
  required String url,
  required String apiKey,
  required String pathEncoded,
  required String fileName,
}) async {
  try {
    // Check and request storage permissions for Android
    if (Platform.isAndroid) {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return ApiResponse(
          success: false,
          message:
              'Storage permission is required to download backups. Please enable storage access in app settings.',
          code: 403,
        );
      }
    }

    // Make the HTTP request to download the backup
    var response = await http.get(
      Uri.parse('$url/api/admin/backups/download/$pathEncoded'),
      headers: {
        'accept': 'application/octet-stream',
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      // Get the downloads directory
      Directory downloadsDirectory;

      if (Platform.isAndroid) {
        // For Android, try multiple approaches to save to Downloads folder
        try {
          // First try: Use the public Downloads directory
          const String publicDownloadsPath = '/storage/emulated/0/Download';
          Directory publicDownloads = Directory(publicDownloadsPath);

          if (await publicDownloads.exists()) {
            // Test write access
            try {
              final testPath = '${publicDownloads.path}/.azuracast_write_test';
              final testFile = File(testPath);
              await testFile.writeAsString('test');
              await testFile.delete();
              downloadsDirectory = publicDownloads;
            } catch (e) {
              throw Exception('No write access to public Downloads');
            }
          } else {
            throw Exception('Public Downloads directory not found');
          }
        } catch (e) {
          // Second try: Use external storage Downloads
          try {
            Directory? externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // Create a Downloads subdirectory in external storage
              downloadsDirectory = Directory('${externalDir.path}/Downloads');
              if (!await downloadsDirectory.exists()) {
                await downloadsDirectory.create(recursive: true);
              }
            } else {
              throw Exception('External storage not available');
            }
          } catch (e) {
            // Final fallback: Use documents directory
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, save directly to the Documents directory to make files visible in Files app
        try {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        } catch (e) {
          // Fallback to documents directory (same as above, but explicit)
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For other platforms, try to use downloads directory
        downloadsDirectory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      // Create the full file path
      final String fullPath = '${downloadsDirectory.path}/$fileName';
      final File file = File(fullPath);

      // Write the file
      await file.writeAsBytes(response.bodyBytes);

      // Determine the appropriate success message based on where the file was saved
      String platformMessage;
      if (Platform.isIOS) {
        platformMessage = 'Backup saved to Documents (visible in Files app)';
      } else if (Platform.isAndroid) {
        if (downloadsDirectory.path.contains('/storage/emulated/0/Download')) {
          platformMessage = 'Backup downloaded to Downloads folder';
        } else if (downloadsDirectory.path.contains('Downloads')) {
          platformMessage = 'Backup saved to app Downloads folder';
        } else {
          platformMessage = 'Backup saved to app storage';
        }
      } else {
        platformMessage = 'Backup downloaded successfully';
      }

      return ApiResponse(
        success: true,
        message: '$platformMessage: $fileName',
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
