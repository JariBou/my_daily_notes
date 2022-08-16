import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NoteNotification {
  NoteNotification({
    required this.id,
    required this.table,
  });

  final int id;
  final String table;

  static NoteNotification fromPayload(String string) {
    Map<String, dynamic> jsonData = json.decode(string);
    return NoteNotification(id: jsonData['note_id'] as int, table: jsonData['note_table'] as String);
  }

}


class NotificationService {
  // Singleton Init
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String notificationPayload = '';

  Future<void> init() async {
    /// Initialisation of all settings
    await _configureLocalTimeZone();
    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notifications');

    // iOS Settings
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification,
    );

  }

  // To avoid permissions being asked at improper times
  // Only asked when decided
  Future<void> requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Useless for now
  Future selectNotification(String? payload) async {
    // Payload as: '{note_id: note.id, note_table: note.table}'  (json format)
    notificationPayload = payload!;

  }

  /// Create a Scheduled notification
  Future zonedScheduleNotification({required String payload, required String title, required String content, required tz.TZDateTime time, required int noteId}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        noteId,
        title,
        content,
        time,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'myDailyNotesChannel_id', 'myDailyNotesChannel',
                channelDescription: 'myDailyNoesChannel')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  /// Configure TimeZone plugin
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

}

