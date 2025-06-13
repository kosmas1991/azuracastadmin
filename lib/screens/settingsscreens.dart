import 'dart:async';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/settings.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServerSettingsScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  const ServerSettingsScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  late Future<SettingsModel> settings;

  @override
  void initState() {
    settings = fetchSettings(widget.url, 'admin/settings', widget.apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Server Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: settings,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.black38,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Base url: ${data.baseUrl}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Instance name: ${data.instanceName}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'History keep days: ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          data.historyKeepDays == 0
                                              ? 'forever'
                                              : '${data.historyKeepDays}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Always use SSL: ${data.alwaysUseSsl}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Analytics: ${data.analytics}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Check for updates: ${data.checkForUpdates}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    data.updateResults != null
                                        ? Text(
                                            'Current release: ${data.updateResults!.currentRelease}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        : Container(),
                                    data.updateResults != null
                                        ? Text(
                                            'Latest release: ${data.updateResults!.latestRelease}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        : Container(),
                                    Text(
                                      'Update last run: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.updateLastRun! * 1000))}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Hide album art: ${data.hideAlbumArt}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Homepage redirect url: ${data.homepageRedirectUrl}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Use external album art when processing media: ${data.useExternalAlbumArtWhenProcessingMedia}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Use external album art in APIS: ${data.useExternalAlbumArtInApis}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'LastFM API key: ${data.lastFmApiKey}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Hide product name: ${data.hideProductName}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Backup enabled: ${data.backupEnabled}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Backup keep copies: ${data.backupKeepCopies}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Backup last run: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.backupLastRun! * 1000))}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Setup complete time: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.setupCompleteTime! * 1000))}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Sync disabled: ${data.syncDisabled}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Sync last run: ${DateFormat.yMMMEd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.syncLastRun! * 1000))}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Enabled advanced features: ${data.enableAdvancedFeatures}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Mail enabled: ${data.mailEnabled}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Mail sender name: ${data.mailSenderName}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Mail sender email: ${data.mailSenderEmail}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'SMTP host: ${data.mailSmtpHost}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'SMTP port: ${data.mailSmtpPort}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'SMTP username: ${data.mailSmtpUsername}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'SMTP password: ${data.mailSmtpPassword}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'mail smtp secure: ${data.mailSmtpSecure}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Avatar service: ${data.avatarService}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Avatar default URL: ${data.avatarDefaultUrl}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Acme email: ${data.acmeEmail}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Acme domains: ${data.acmeDomains}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'IP source: ${data.ipSource}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                )
              ],
            ),
          )
        ]),
      ),
    ));
  }
}
