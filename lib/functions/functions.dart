import 'dart:convert';
import 'package:azuracastadmin/models/cpustats.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<Response> getResponse({
  required String url,
  required String path,
  String? apiKey,
}) async {
  var response;
  if (apiKey != null) {
    final headers = {
      'accept': 'application/json',
      'X-API-Key': '${apiKey}',
    };
    response =
        await http.get(Uri.parse('${url}/api/${path}'), headers: headers);
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
