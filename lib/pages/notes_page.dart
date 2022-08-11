import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/edit_note_page.dart';
import 'package:my_daily_notes/pages/note_detail_page.dart';
import 'package:my_daily_notes/widget/note_card_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers.dart';

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
    if (table == NoteTables.draftNotes) {
      return longPressFlag
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.send),
              onPressed: () => sendNotes(),
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

    print(data.toString());

    for (var i = 1; i < data.length + 1; i++) {
      print(data[i.toString()]);
      final note = Note.fromJson(data[i.toString()]).removeId();
      try {
        await NotesDatabase.instance.create(note, table);
      } catch (e) {
        print('exception $e');
      } // Note already exists
    }
  }

  void longPress() {
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

        return CustomWidget(
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

  sendNotes() async {
    await FilePicker.platform.clearTemporaryFiles();
    Directory directory = await getTemporaryDirectory();
    File file = File('${directory.path}/noteBundle.json');
    //file.create();
    Map<String, dynamic> _json = {};

    for (var i = 1; i < notesList.length + 1; i++) {
      Note note = notesList[i-1];
      _json.addAll({i.toString(): note.toJson()});
      NotesDatabase.instance.delete(note.id as int, widget.table);
      NotesDatabase.instance.create(note.removeId(), NoteTables.sentNotes);
    }
    notesList = [];
    longPress();

    String _jsonString = jsonEncode(_json);
    print(_jsonString);

    file.writeAsStringSync(_jsonString);
    print(await file.readAsString());

    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: [],
      cc: [],
      bcc: [],
      attachmentPaths: [file.path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    refreshNotes(widget.table);
  }
}

class CustomWidget extends StatefulWidget {
  final int index;
  final bool longPressEnabled;
  final VoidCallback callback;
  final String table;
  final Note note;
  final bool isReadable;
  final Function refreshNotes;

  const CustomWidget(
      {Key? key,
      required this.index,
      required this.longPressEnabled,
      required this.callback,
      required this.table,
      required this.note,
      required this.isReadable,
      required this.refreshNotes})
      : super(key: key);

  @override
  _CustomWidgetState createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  bool selected = false;
  late final Note note;
  late final String table;
  late final int index;

  @override
  void initState() {
    super.initState();

    note = widget.note;
    table = widget.table;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          selected = !selected;
        });
        widget.callback();
      },
      onTap: () async {
        if (widget.longPressEnabled) {
          setState(() {
            selected = !selected;
          });
          widget.callback();
        } else {
          if (table != NoteTables.receivedNotes || widget.isReadable) {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  NoteDetailPage(noteId: note.id!, table: table, isModifiable: table == NoteTables.draftNotes,),
            ));

            widget.refreshNotes(table);
          }
          ;
        }
      },
      child: (table != NoteTables.receivedNotes || widget.isReadable)
          ? NoteCardWidget(
              note: note,
              index: index,
              selected: selected,
            )
          : NoteLockedWidget(note: note, index: index),
    );
  }
}
