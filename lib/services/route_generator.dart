import 'package:flutter/material.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/pages/subpages/edit_note_page.dart';
import 'package:my_daily_notes/pages/subpages/note_detail_page.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';

/// Useless for now might be used later to use Routes
/// Crashed until now
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const NotesTabLayout());
      case '/home/noteEdit':
        if (args is Map) {
          return MaterialPageRoute(
              builder: (_) => args['note'] == null ? AddEditNotePage(table: args['table']) : AddEditNotePage(table: args['table'], note: args['note'],));
        }
        return _errorRoute();
      case '/noteDetail':
        if (args is Map) {
          return MaterialPageRoute(builder: (_) => NoteDetailPage(noteId: args['note_id'], table: args['table'], isModifiable: args['isModifiable'], isNotification: args['isNotification'],));
        }
        return _errorRoute();
      case '/nameSelection':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => const ChangeNameLayout(),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      default:
      // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}