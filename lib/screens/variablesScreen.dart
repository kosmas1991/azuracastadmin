import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/step/step_cubit.dart' as step;
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VariablesScreen extends StatefulWidget {
  const VariablesScreen({super.key});

  @override
  State<VariablesScreen> createState() => _VariablesScreenState();
}

class _VariablesScreenState extends State<VariablesScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    // Initialize the text controller
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<step.StepCubit, step.StepState>(
        builder: (context, state) {
          // Debug mode prefilling logic
          if (kDebugMode) {
            if (state.step == 0 && textEditingController.text.isEmpty) {
              // Prefill server URL in debug mode
              textEditingController.text = "https://radioserver.gr";
            } else if (state.step == 1 &&
                (textEditingController.text.isEmpty ||
                    textEditingController.text == "https://radioserver.gr")) {
              // Clear previous content and prefill API key in debug mode
              textEditingController.text =
                  "7bb930a439f67cfe:e3f753dfaeaafc4a759a97653fb0e2e";
            }
          } else {
            // In production mode, clear the text field when moving to step 1
            if (state.step == 1 && textEditingController.text.contains("://")) {
              textEditingController.clear();
            }
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    state.step == 0
                        ? 'Please fill below the azuracast server URL or IP address of the server'
                        : 'Please fill below the admin API key',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: Colors.white54,
                                fontStyle: FontStyle.italic),
                            hintText: state.step == 0
                                ? 'ex. https://radioserver.gr or http://5.255.120.50'
                                : 'ex. gfdg0dfgf400gfh88'),
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                    label: Text(
                      'Next',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20),
                    ),
                    onPressed: () async {
                      final SharedPreferences prefs = await _prefs;
                      if (context.read<step.StepCubit>().state.step == 0) {
                        context
                            .read<UrlCubit>()
                            .emitNewUrl(textEditingController.text.trim());
                        prefs.setString(
                            'url', context.read<UrlCubit>().state.url);
                      } else if (context.read<step.StepCubit>().state.step ==
                          1) {
                        context
                            .read<ApiCubit>()
                            .emitNewApi(textEditingController.text.trim());
                        prefs.setString(
                            'api', textEditingController.text.trim());
                      }
                      context.read<step.StepCubit>().addOne();
                    },
                    icon: Icon(
                      Icons.navigate_next,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: 40,
                    )),
                SizedBox(
                  height: 20,
                ),
                if (state.step != 0)
                  Column(
                    children: [
                      Text(
                        'You can create an API key from the AzuraCast web interface, by clicking the user menu in the top right and clicking “My API Keys”. Any API keys you create will share the same permissions that you have as a user.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Image.asset('assets/images/clip.gif'),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
