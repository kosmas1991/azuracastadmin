import 'dart:async';
import 'dart:convert';

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
    return FutureBuilder(
      future: radiostations,
      builder: (context2, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length == 0) {
            return Container();
          }
          // context.read<RadioIdCubit>().emitNewID(snapshot.data![0].id!);
          return SizedBox(
            width: double.infinity,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Text(
                  'Select radio:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                DropdownButton<String>(
                  value: dropDownValue ??
                      (snapshot.data![0].name != null
                          ? utf8.decode(snapshot.data![0].name!.codeUnits)
                          : snapshot.data![0].name),
                  underline: Container(),
                  style: TextStyle(
                    fontFamily: 'Schyler',
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                  dropdownColor: Colors.black38,
                  items: [
                    ...snapshot.data!.map((e) {
                      if (isTheFirstElement) {
                        context.read<RadioIdCubit>().emitNewID(e.id!);
                        isTheFirstElement = false;
                      }
                      return DropdownMenuItem<String>(
                        value: e.name != null
                            ? utf8.decode(e.name!.codeUnits)
                            : e.name,
                        child: Text(e.name != null
                            ? utf8.decode(e.name!.codeUnits)
                            : 'Unknown'),
                      );
                    }).toList()
                  ],
                  onChanged: (value) {
                    setState(() {
                      dropDownValue = value;
                      RadioStations radio;
                      radio = snapshot.data!.firstWhere((element) {
                        String decodedName = element.name != null
                            ? utf8.decode(element.name!.codeUnits)
                            : '';
                        if (decodedName == value) {
                          return true;
                        } else {
                          return false;
                        }
                      });
                      context.read<RadioIdCubit>().emitNewID(radio.id!);
                    });
                  },
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }
      },
    );
  }
}
