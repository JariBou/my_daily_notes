import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_daily_notes/pages/subpages/note_detail_page.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
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


  Future selectNotification(String? payload) async {
    // Payload as: '{note_id: note.id, note_table: note.table}'  (json format)
    notificationPayload = payload!;
    NoteNotification notification = NoteNotification.fromPayload(payload);

    Builder(
      builder: (context) => NoteDetailPage(noteId: notification.id, table: notification.table, isModifiable: false, isNotification: true,)

    );
  }

  Future zonedScheduleNotification({required String payload}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

}

