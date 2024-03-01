import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController =
        TextEditingController(text: context.read<UrlCubit>().state.url);
    TextEditingController textEditingController2 =
        TextEditingController(text: context.read<ApiCubit>().state.api);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Color.fromARGB(241, 1, 1, 18)])),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'Azuracast server URL',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                TextField(
                  onChanged: (value) async {
                    SharedPreferences prefs = await _preferences;
                    prefs.setString('url', value);
                    context.read<UrlCubit>().emitNewUrl(value);
                  },
                  controller: textEditingController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      border: InputBorder.none,
                      filled: false,
                      fillColor: Colors.white),
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Admin API',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                TextField(
                  onChanged: (value) async {
                    SharedPreferences prefs = await _preferences;
                    prefs.setString('api', value);
                    context.read<ApiCubit>().emitNewApi(value);
                  },
                  controller: textEditingController2,
                  decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      border: InputBorder.none,
                      filled: false,
                      fillColor: Colors.white),
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Disclaimer: Please note that this application is fully compatible with the latest stable release of azuracast software. Current version tested is v0.19.5 Stable. Using this app with older or newer versions may create malfunctions.',
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
