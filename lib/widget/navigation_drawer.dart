import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/pages/settings_page.dart';
import 'package:my_daily_notes/pages/subpages/notes_page.dart';
import 'package:my_daily_notes/services/helpers.dart';
import 'package:my_daily_notes/services/notes_database.dart';
import 'package:my_daily_notes/services/stored_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Main Drawer
class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              DataStorage.getData('name') ?? 'User',
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Change Name'),
            onTap: () => changeName(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () async {
              await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SettingsPageLayout()),
                  (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('[DEBUG] create note'),
            onTap: () => (NotesDatabase.instance.create(
                Note(
                    time: DateTime.now(),
                    author: 'jj',
                    title: 'test2',
                    description: 'testooo'),
                NoteTables.receivedNotes)),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('[DEBUG] save state'),
            onTap: () => (createBackup()),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('[DEBUG] remove duplicates'),
            onTap: () => (removeDuplicates(context)),
          ),
        ],
      ),
    );
  }

  /// Sends to page to change name
  changeName(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ChangeNameLayout()));
  }

  createBackup() async {
    /// Function to create backup of notes in app
    Directory directory = await getTemporaryDirectory();
    print(directory.path);
    final String fileName =
        '${DateFormat('y-m-d').format(DateTime.now())}_notesSave.json';
    File file = File('${directory.path}/$fileName');
    Map<String, List> jsonData = {
      NoteTables.sentNotes: [],
      NoteTables.receivedNotes: [],
      NoteTables.draftNotes: [],
    };

    for (String table in NoteTables.fields) {
      for (Map<String, Object?> noteJson
          in (await NotesDatabase.instance.readAllNotesAsJson(table))) {
        jsonData.update(table, (value) => value + [noteJson]);
      }
      print(jsonData[table]);
    }

    /*var notesList = await NotesDatabase.instance
        .readAllNotesAsJson(NoteTables.receivedNotes);

    for (var i = 1; i < notesList.length + 1; i++) {
      var note = notesList[i - 1];
      print(note);
      //jsonData.addAll({i.toString(): note.toJson()});
    }*/

    String jsonString = jsonEncode(jsonData);

    file.writeAsStringSync(jsonString);

    // This is for iPad but throws an error when passed to shareFiles
    //final box = context.findRenderObject() as RenderBox?;
    restoreBackup(file);
    /*await Share.shareFiles(
        [file.path],
        subject: 'App Backup',
        text: 'App Backup: $fileName',
      );*/
  }

  restoreBackup(File file) async {
    //FilePickerResult? result = await FilePicker.platform.pickFiles();

    /*if (result == null) {
      return;
    }*/

    //File tablesData = File(result.files.single.path as String);

    Map<String, dynamic> data = await json.decode(await file.readAsString());

    for (String table in NoteTables.fields) {
      List notes = data[table]!;
      for (Map<String, Object?> noteJson in notes) {
        Note note = Note.fromJson(noteJson).removeId();
        NotesDatabase.instance.create(note, table);
      }
    }
  }

  removeDuplicates(BuildContext context) async {
    AlertsManager.confirm(
      context,
      title: 'Are you sure?',
      content:
          'This option is not 100% safe and might delete non duplicate notes',
      yesText: "I know what I'm doing",
      noText: 'Cancel',
      onConfirmCallback: () async {
        Map<int, String> toRemove = {};

        for (String table in NoteTables.fields) {
          List<Note> notesList = await NotesDatabase.instance.readAllNotes(table);
          for (int i = 0; i < notesList.length-1; i++) {
            for (int j = i+1; j < notesList.length; j++) {
              if (notesList[i].equals(notesList[j])) {
                toRemove.addAll({notesList[j].id!: table});
              }
            }
          }
        }

        toRemove.forEach((id, table) {
          NotesDatabase.instance.delete(id, table);
        });

      },
    );
  }
}
