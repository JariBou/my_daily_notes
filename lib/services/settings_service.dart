import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {

  static List settingsFields = ['1', '2'];
  static Map<String, dynamic> settings = {};

  static Future initSettings() async {
    final prefs = await SharedPreferences.getInstance();

    for (String field in settingsFields) {
        settings.addAll({field: prefs.get(field) ?? ''});
    }

  }

}