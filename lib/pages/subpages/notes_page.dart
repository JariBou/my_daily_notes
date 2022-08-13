import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/subpages/edit_note_page.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:my_daily_notes/widget/note/note_card_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../helpers.dart';

/// Page that displays noteWidgets
class NotesPage extends StatefulWidget {
  final String table;

  const NotesPage({
    Key? key,
    required this.table,
  }) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  bool longPressFlag = false;
  List<Note> notesList = [];

  @override
  void initState() {
    super.initState();

    refreshNotes(widget.table);
  }

  @override
  void dispose() {
    //NotesDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes(String table) async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes(table);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : notes.isEmpty
                  ? const Text(
                      'No Notes',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : buildNotes(widget.table),
        ),
        floatingActionButton: buildFloatingButton(widget.table),
      );

  Widget? buildFloatingButton(String table) {
    /// Giga function that handles Floating buttons for each page
    if (table == NoteTables.draftNotes) {
      return longPressFlag
          ? Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(Icons.send),
            onPressed: () => sendNotes(context),
          );
        },
      )
          : FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          AddEditNotePage(table: widget.table)),
                );
                refreshNotes(widget.table);
              },
            );
    }
    else if (table == NoteTables.receivedNotes) {
      return longPressFlag
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete_forever),
              onPressed: () => {
                confirm(context, 'Confirm?',
                    'Are you sure you want to delete all of the selected notes?',
                    () async {
                  for (var i = 1; i < notesList.length + 1; i++) {
                    await NotesDatabase.instance
                        .delete(notesList[i - 1].id as int, widget.table);
                    refreshNotes(widget.table);
                  }
                  notesList = [];
                  longPress();
                },
                    () => {})
              },
            )
          : FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(Icons.download),
              onPressed: () async {
                await importNotes(widget.table);
                refreshNotes(widget.table);
              },
            );
    }
    else if (table == NoteTables.sentNotes) {
      return longPressFlag
      ? FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete_forever),
        onPressed: () => {
          confirm(context, 'Confirm?',
              'Are you sure you want to delete all of the selected notes?',
                  () async {
                for (var i = 1; i < notesList.length + 1; i++) {
                  await NotesDatabase.instance
                      .delete(notesList[i - 1].id as int, widget.table);
                  refreshNotes(widget.table);
                }
                notesList = [];
                longPress();
              },
                  () => {})
        },
      )
          : null;
    }
    return null;
  }

  Future importNotes(String table) async {
    //await FilePicker.platform.clearTemporaryFiles();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }
    //var data = null;
    File notes = File(result.files.single.path as String);
    final data = await json.decode(await notes.readAsString());

    for (var i = 1; i < data.length + 1; i++) {
      final note = Note.fromJson(data[i.toString()]).removeId();
      await NotesDatabase.instance.create(note, table);
    }
  }

  void longPress() {
    /// Checks if user is still selecting notes
    setState(() {
      if (notesList.isEmpty) {
        longPressFlag = false;
      } else {
        longPressFlag = true;
      }
    });
  }

  Widget buildNotes(String table) => MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 3,
      crossAxisSpacing: 1,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isReadable = note.time.isBefore(DateTime.now());

        return NoteCardWidget(
          index: index,
          longPressEnabled: longPressFlag,
          callback: () {
            if (notesList.contains(note)) {
              notesList.remove(note);
            } else {
              notesList.add(note);
            }

            longPress();
          },
          refreshNotes: (table) => {refreshNotes(table)},
          table: table,
          isReadable: isReadable,
          note: note,
        );
      });

  sendNotes(BuildContext context) async {
    /// Function to send Notes
    await FilePicker.platform.clearTemporaryFiles();
    Directory directory = await getTemporaryDirectory();
    File file = File('${directory.path}/noteBundle.json');
    //file.create();
    Map<String, dynamic> jsonData = {};

    for (var i = 1; i < notesList.length + 1; i++) {
      Note note = notesList[i-1];
      jsonData.addAll({i.toString(): note.toJson()});
      NotesDatabase.instance.delete(note.id as int, widget.table);
      NotesDatabase.instance.create(note.removeId(), NoteTables.sentNotes);
    }

    String jsonString = jsonEncode(jsonData);

    file.writeAsStringSync(jsonString);

    // This is for iPad but throws an error when passed to shareFiles
    //final box = context.findRenderObject() as RenderBox?;

    await Share.shareFiles([file.path],
        subject: 'New Notes!',
        text: '${DataStorage.getData('name')} just sent you new notes!',
    );

    notesList = [];
    longPress();
    refreshNotes(widget.table);
  }
}


