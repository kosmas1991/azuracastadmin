import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/retry/retry_cubit.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart' as step;
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:azuracastadmin/screens/checkscreen.dart';
import 'package:azuracastadmin/screens/variablesScreen.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Stack(children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/azu.png',
              fit: BoxFit.fill,
            ),
          ).blurred(blur: 10, blurColor: Colors.black),
          FutureBuilder(
            future: _prefs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return BlocBuilder<step.StepCubit, step.StepState>(
                  builder: (context, state) {
                    if (!context.read<RetryCubit>().state.retry) {
                      if (state.step == 2 ||
                          (snapshot.data!.getString('url') != null &&
                              snapshot.data!.getString('api') != null)) {
                        return CheckScreen(
                            url: context.watch<UrlCubit>().state.url,
                            apiKey: context.watch<ApiCubit>().state.api);
                      } else {
                        return VariablesScreen();
                      }
                    } else {
                      return VariablesScreen();
                    }
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        ]),
      ),
    ));
  }
}
