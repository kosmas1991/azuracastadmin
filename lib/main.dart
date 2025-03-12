import 'dart:io';

import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/filteredlist/filteredlist_cubit.dart';
import 'package:azuracastadmin/cubits/radioID/radio_id_cubit.dart';
import 'package:azuracastadmin/cubits/requestsonglist/requestsonglist_cubit.dart';
import 'package:azuracastadmin/cubits/retry/retry_cubit.dart';
import 'package:azuracastadmin/cubits/searchstring/searchstring_cubit.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:azuracastadmin/firebase_options.dart';
import 'package:azuracastadmin/screens/homescreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart' as step;

/* 
Flutter 3.29.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 09de023485 (10 days ago) • 2025-02-28 13:44:05 -0800
Engine • revision 871f65ac1b
Tools • Dart 3.7.0 • DevTools 2.42.2
*/

//TODO fix loading indicators with one, inform users that only works with admins, base url to add https if not entered

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //allows IP as server name instead of only domain value
  HttpOverrides.global = MyHttpOverrides();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'gr.techzombie.azuracastadmin.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logEvent(
    name: "launch",
    parameters: {
      "screen": "home",
      "action": "a user launched the app",
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
        future: _preferences,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => StepCubit(),
                ),
                BlocProvider(
                  create: (context) => UrlCubit(
                      initialUrl: snapshot.data!.getString('url') ?? ''),
                ),
                BlocProvider(
                  create: (context) =>
                      ApiCubit(initAPI: snapshot.data!.getString('api') ?? ''),
                ),
                BlocProvider(
                  create: (context) => RadioIdCubit(),
                ),
                BlocProvider(
                  create: (context) =>
                      RetryCubit(stepCubit: context.read<step.StepCubit>()),
                ),
                BlocProvider(
                  create: (context) => SearchstringCubit(),
                ),
                BlocProvider(
                  create: (context) => RequestsonglistCubit(),
                ),
                BlocProvider(
                  create: (context) => FilteredlistCubit(
                      requestsonglistCubit:
                          context.read<RequestsonglistCubit>(),
                      searchstringCubit: context.read<SearchstringCubit>(),
                      initialList:
                          context.read<RequestsonglistCubit>().state.list),
                )
              ],
              child: MaterialApp(
                title: 'Azuracast Admin',
                home: HomeScreen(),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
