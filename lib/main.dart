import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/filteredlist/filteredlist_cubit.dart';
import 'package:azuracastadmin/cubits/radioID/radio_id_cubit.dart';
import 'package:azuracastadmin/cubits/requestsonglist/requestsonglist_cubit.dart';
import 'package:azuracastadmin/cubits/retry/retry_cubit.dart';
import 'package:azuracastadmin/cubits/searchstring/searchstring_cubit.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:azuracastadmin/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart' as step;

void main() {
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
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
