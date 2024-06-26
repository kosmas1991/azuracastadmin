import 'dart:async';

import 'package:azuracastadmin/cubits/radioID/radio_id_cubit.dart';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/radiostations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectRadioStation extends StatefulWidget {
  final String url;
  const SelectRadioStation({
    required this.url,
    super.key,
  });

  @override
  State<SelectRadioStation> createState() => _SelectRadioStationState();
}

class _SelectRadioStationState extends State<SelectRadioStation> {
  late Future<List<RadioStations>> radiostations;
  bool isTheFirstElement = true;
  String? dropDownValue;
  @override
  void initState() {
    radiostations = fetchRadioStations(widget.url, 'stations');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select radio station:',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        FutureBuilder(
          future: radiostations,
          builder: (context2, snapshot) {
            if (snapshot.hasData) {
              return DropdownButton<String>(
                value: dropDownValue ?? snapshot.data![0].name,
                underline: Container(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                dropdownColor: Colors.black38,
                items: [
                  ...snapshot.data!.map((e) {
                    if (isTheFirstElement) {
                      context.read<RadioIdCubit>().emitNewID(e.id!);
                      isTheFirstElement = false;
                    }
                    return DropdownMenuItem<String>(
                      value: e.name,
                      child: Text(e.name!),
                    );
                  }).toList()
                ],
                onChanged: (value) {
                  setState(() {
                    dropDownValue = value;
                    RadioStations radio;
                    radio = snapshot.data!.firstWhere((element) {
                      if (element.name == value) {
                        return true;
                      } else {
                        return false;
                      }
                    });
                    context.read<RadioIdCubit>().emitNewID(radio.id!);
                  });
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
          },
        )
      ],
    );
  }
}
