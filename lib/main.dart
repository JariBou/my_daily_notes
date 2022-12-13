import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
import 'package:my_daily_notes/services/notifications_service.dart';
import 'package:my_daily_notes/services/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  // Put here everything that should be done before the app launches
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); //
  await NotificationService().requestIOSPermissions();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =  await NotificationService().flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  bool notificationLaunch = notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  if (notificationLaunch) {
    NotificationService().notificationPayload =
        notificationAppLaunchDetails!.payload!;
  }
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name') ?? '';

  DataStorage.storeData('name', name);

  bool isLogged = name != '';




  // ---------------------------------------------------------------
  runApp(MyApp(isLogged: isLogged, notificationLaunch: notificationLaunch));
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  final bool notificationLaunch;

  const MyApp({super.key, required this.isLogged, required this.notificationLaunch});

  @override
  Widget build(BuildContext context) {
    if (notificationLaunch) {
      NoteNotification notification = NoteNotification.fromPayload(NotificationService().notificationPayload);
      return MaterialApp(
        title: 'My Daily Notes',
        color: Colors.blue,
        home: NotesTabLayout(notification: notification),
        debugShowCheckedModeBanner: false, // Removes the debug banner
      );
    }


    else if (isLogged) {
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
