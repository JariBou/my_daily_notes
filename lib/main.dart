import 'package:flutter/material.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  // Put here everything that should be done before the app launches
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name') ?? '';

  DataStorage.storeData('name', name);

  bool isLogged = name != '';
  // ---------------------------------------------------------------

  runApp(MyApp(isLogged: isLogged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    if (isLogged) {
      return const MaterialApp(
        title: 'My Daily Notes',
        color: Colors.blue,
        home: NotesTabLayout(),
      );
    } else { // User has to select a name
      return const MaterialApp(
        title: 'My Daily Notes',
        color: Colors.blue,
        home: ChangeNameLayout(),
      );
    }
  }
}
