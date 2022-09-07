import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
import 'package:my_daily_notes/services/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page of settings
class SettingsPageLayout extends StatefulWidget {
  const SettingsPageLayout({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPageLayout> {
  @override
  void initState() {
    super.initState();
  }

  List settingsFields = ['1', '2'];
  Map settings = {};

  void initSettings() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Daily Notes'),
          backgroundColor: Colors.blue,
          actions: [
            ButtonBar(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await saveSettings();
                      await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => NotesTabLayout()),
                          (Route<dynamic> route) => false);
                    },
                    child: const Icon(Icons.done)),
                ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => NotesTabLayout()),
                          (Route<dynamic> route) => false);
                    },
                    child: const Icon(Icons.cancel)),
              ],
            )
          ],
        ),
        body: Column(
          children: List.generate(
            settingsFields.length,
            (index) {
              return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(settingsFields[index], style: const TextStyle(fontSize: 20),),
                      Text('-------', style: TextStyle(fontSize: 20))
                    ],
                  ));
              return Text(settingsFields[index]);
            },
          ),
        ));
  }

  saveSettings() async {}
}
