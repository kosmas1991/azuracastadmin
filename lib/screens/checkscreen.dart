import 'package:azuracastadmin/cubits/retry/retry_cubit.dart';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart' as step;
import 'package:azuracastadmin/screens/widgetsscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class CheckScreen extends StatefulWidget {
  final String url;
  final String apiKey;

  const CheckScreen({super.key, required this.url, required this.apiKey});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  late Future<Response> response;
  @override
  void initState() {
    response = getResponse(
        url: widget.url, apiKey: widget.apiKey, path: 'admin/server/stats');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<RetryCubit>().emitNewState(false);

    return FutureBuilder(
      future: response,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data!;
          if (data.statusCode == 200) {
            if (!data.body.contains('"status":"error"') &&
                data.body.contains('cpu')) {
              return WidgetsScreen();
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Invalid server or API',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FilledButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.blue)),
                        onPressed: () {
                          context.read<step.StepCubit>().setZero();
                          context.read<RetryCubit>().emitNewState(true);
                        },
                        child: Text('Try again'))
                  ],
                ),
              );
            }
          } else {
            //404 for example
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Invalid server or API',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FilledButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      onPressed: () {
                        context.read<step.StepCubit>().setZero();
                        context.read<RetryCubit>().emitNewState(true);
                      },
                      child: Text('Try again'))
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Invalid server or API',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                FilledButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                    onPressed: () {
                      context.read<step.StepCubit>().setZero();
                      context.read<RetryCubit>().emitNewState(true);
                    },
                    child: Text('Try again'))
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }
}
