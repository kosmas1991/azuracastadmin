import 'package:azuracastadmin/screens/settingsScreen.dart';
import 'package:flutter/material.dart';

class TitleAndSettingsIconButton extends StatelessWidget {
  const TitleAndSettingsIconButton({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Azuracast Admin',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        Container(
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
        )
      ],
    );
  }
}
