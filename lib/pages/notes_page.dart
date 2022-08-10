import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/edit_note_page.dart';
import 'package:my_daily_notes/pages/note_detail_page.dart';
import 'package:my_daily_notes/widget/note_card_widget.dart';
import 'package:path_provider/path_provider.dart';

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
        floatingActionButton: longPressFlag ? FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(Icons.send),
          onPressed: () => sendNotes(),
        ) : FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => AddEditNotePage(table: widget.table)),
            );

            refreshNotes(widget.table);
          },
        ),
      );

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

            /*return GestureDetector(
  onTap: () async {
  if (table != NoteTables.receivedNotes || isReadable) {
  await Navigator.of(context).push(MaterialPageRoute(
  builder: (context) =>
  NoteDetailPage(noteId: note.id!, table: table),
  ));

  refreshNotes(table);
  }
  },
  child: (table != NoteTables.receivedNotes || isReadable) ? NoteCardWidget(note: note, index: index) : NoteLockedWidget(note: note, index: index),
  );*/
          }, refreshNotes: (table) => { refreshNotes(table) }, table: table, isReadable: isReadable, note: note,
        );
      });

  sendNotes() async {
    Directory directory = await getTemporaryDirectory();
    File file = File('${directory.path}/noteBundle.json');
    //file.create();
    Map<String, dynamic> _json = {};


    for (var i; i < notesList.length; i++) {
      _json.addAll({i.toString(): notesList[i].toJson()});
    }

    String _jsonString = jsonEncode(_json);

    file.writeAsStringSync(_jsonString);

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
        print(widget.longPressEnabled);
        if (widget.longPressEnabled) {
          setState(() {
            selected = !selected;
          });
          widget.callback();
        }
        else {
                print("lol");
            if (table != NoteTables.receivedNotes || widget.isReadable) {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NoteDetailPage(noteId: note.id!, table: table),
              ));

              widget.refreshNotes(table);
            }
          ;
        }
      },

      child: (table != NoteTables.receivedNotes || widget.isReadable) ? NoteCardWidget(note: note, index: index, selected: selected,) : NoteLockedWidget(note: note, index: index),
    );
  }
}
