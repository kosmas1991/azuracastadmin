import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/user_account.dart';
import 'package:azuracastadmin/screens/settingsScreen.dart';
import 'package:azuracastadmin/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_image/transparent_image.dart';

class TitleSettingsAvatarWidget extends StatefulWidget {
  const TitleSettingsAvatarWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  State<TitleSettingsAvatarWidget> createState() =>
      _TitleSettingsAvatarWidgetState();
}

class _TitleSettingsAvatarWidgetState extends State<TitleSettingsAvatarWidget> {
  late Future<UserAccount> userAccount;

  @override
  void initState() {
    super.initState();
    // Initialize with empty values - will be set in build method
    userAccount = Future.value(UserAccount());
  }

  @override
  Widget build(BuildContext context) {
    String url = context.watch<UrlCubit>().state.url;
    String apiKey = context.watch<ApiCubit>().state.api;

    // Update userAccount future when URL or API key changes
    userAccount = fetchUserAccount(url, apiKey);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Azuracast Admin',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        Row(
          children: [
            // Settings Icon
            Container(
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black38,
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ));
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  )),
            ),
            // User Avatar
            FutureBuilder<UserAccount>(
              future: userAccount,
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          url: url,
                          apiKey: apiKey,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.black38,
                    ),
                    child: snapshot.hasData &&
                            snapshot.data!.avatar?.url64 != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: FadeInImage.memoryNetwork(
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              placeholder: kTransparentImage,
                              image: snapshot.data!.avatar!.url64!,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.black38,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.black38,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
