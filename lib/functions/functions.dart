import 'package:http/http.dart' as http;

Future<String> getAPI({required String path}) async {
  var response =
      await http.get(Uri.parse('https://radiounicorn.eu/api/nowplaying'));
  return response.body;
}
