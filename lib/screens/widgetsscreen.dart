import 'package:azuracastadmin/cubits/api/api_cubit.dart';
import 'package:azuracastadmin/cubits/radioID/radio_id_cubit.dart';
import 'package:azuracastadmin/cubits/url/url_cubit.dart';
import 'package:azuracastadmin/models/stationsstatus.dart';
import 'package:azuracastadmin/screens/settingsScreen.dart';
import 'package:azuracastadmin/widgets/station_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/c_p_u_stats_widget.dart';
import '../widgets/select_radio_station.dart';
import '../widgets/station_info.dart';

class WidgetsScreen extends StatefulWidget {
  const WidgetsScreen({super.key});

  @override
  State<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends State<WidgetsScreen> {
  @override
  Widget build(BuildContext context) {
    String url = context.read<UrlCubit>().state.url;
    String apiKey = context.read<ApiCubit>().state.api;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TitleAndSettingsIconButton(),
            SizedBox(
              height: 10,
            ),
            CPUMemoryDiskStatsWidget(
              url: url,
              apiKey: apiKey,
            ),
            SizedBox(
              height: 10,
            ),
            SelectRadioStation(url: url),
            SizedBox(
              height: 10,
            ),
            BlocBuilder<RadioIdCubit, RadioIdState>(
              builder: (context, state) {
                return StationInfo(
                    url: url, apiKey: apiKey, stationID: state.id);
              },
            ),
            SizedBox(
              height: 10,
            ),
            BlocBuilder<RadioIdCubit, RadioIdState>(
              builder: (context, state) {
                return StationStatusWidget(
                    url: url, apiKey: apiKey, stationID: state.id);
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Row TitleAndSettingsIconButton() {
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
