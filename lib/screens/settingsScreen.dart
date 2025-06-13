import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();
  bool _obscureApiKey = true;

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController =
        TextEditingController(text: context.read<UrlCubit>().state.url);
    TextEditingController textEditingController2 =
        TextEditingController(text: context.read<ApiCubit>().state.api);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/azu.png',
                  fit: BoxFit.fill,
                ),
              ).blurred(blur: 10, blurColor: Colors.black),
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Server URL Card
                      Card(
                        color: Colors.black38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Azuracast Server URL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  onChanged: (value) async {
                                    SharedPreferences prefs =
                                        await _preferences;
                                    prefs.setString('url', value);
                                    context.read<UrlCubit>().emitNewUrl(value);
                                  },
                                  controller: textEditingController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    border: InputBorder.none,
                                    hintText:
                                        'ex. https://radioserver.gr or http://5.255.120.50',
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.link,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  cursorColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Admin API Card
                      Card(
                        color: Colors.black38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin API Key',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  onChanged: (value) async {
                                    SharedPreferences prefs =
                                        await _preferences;
                                    prefs.setString('api', value);
                                    context.read<ApiCubit>().emitNewApi(value);
                                  },
                                  controller: textEditingController2,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    border: InputBorder.none,
                                    hintText: 'ex. gfdg0dfgf400gfh88',
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.key,
                                      color: Colors.white70,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureApiKey
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureApiKey = !_obscureApiKey;
                                        });
                                      },
                                    ),
                                  ),
                                  cursorColor: Colors.blue,
                                  obscureText: _obscureApiKey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Disclaimer Card
                      Card(
                        color: Colors.amber.withAlpha(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.amber, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Disclaimer',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Please note that this application is fully compatible with the latest stable release of AzuraCast software. Using this app with older or newer (rolling beta) versions may create malfunctions.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Ko-fi Donate Button
                      Card(
                        color: Colors.pink.withAlpha(25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.pink, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.pink,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Support the Developer',
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                'If you find this app useful, consider supporting the developer with a small donation. Your support helps keep the app updated and maintained!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final Uri url = Uri.parse(
                                        'https://ko-fi.com/kosmas1991');

                                    // Try to launch with external application mode first
                                    bool launched = await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );

                                    if (!launched) {
                                      // Fallback to platform default mode
                                      launched = await launchUrl(url);
                                    }

                                    if (!launched) {
                                      // Final fallback - show error message
                                      throw Exception('Could not launch URL');
                                    }
                                  } catch (e) {
                                    // Show error message with the URL so user can copy it
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Could not open Ko-fi link automatically'),
                                            SizedBox(height: 4),
                                            Text(
                                              'Please copy this URL: https://ko-fi.com/kosmas1991',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 5),
                                        action: SnackBarAction(
                                          label: 'Copy URL',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text:
                                                      'https://ko-fi.com/kosmas1991'),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.coffee,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Buy me a coffee ☕',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
