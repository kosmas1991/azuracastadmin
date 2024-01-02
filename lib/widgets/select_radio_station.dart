import 'package:flutter/material.dart';

class SelectRadioStation extends StatefulWidget {
  const SelectRadioStation({
    super.key,
  });

  @override
  State<SelectRadioStation> createState() => _SelectRadioStationState();
}

class _SelectRadioStationState extends State<SelectRadioStation> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Select radio station:',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        DropdownButton(
          underline: Container(),
          style: TextStyle(color: Colors.white, fontSize: 18),
          dropdownColor: Colors.black38,
          items: [
            DropdownMenuItem(
                child: Text(
              'unicorn',
            ))
          ],
          onChanged: (value) {},
        )
      ],
    );
  }
}
