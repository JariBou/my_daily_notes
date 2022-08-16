import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
import 'package:my_daily_notes/services/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/subpages/edit_note_page.dart';
import 'package:my_daily_notes/services/helpers.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;
  final String table;
  final bool isModifiable;
  final bool isNotification;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
    required this.table,
    required this.isModifiable,
    this.isNotification = false,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote(widget.table);
  }

  Future refreshNote(String table) async {
    setState(() => isLoading = true);

    note = await NotesDatabase.instance.readNote(widget.noteId, widget.table);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: widget.isModifiable ? [editButton(), deleteButton()] : [],
          leading: widget.isNotification ? homeButton() : null,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    SelectableText(
                      note.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat.yMMMd().add_Hm().format(note.time.toLocal())}  -  ${note.author}',
                      style: const TextStyle(color: Colors.black26),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      note.description,
                      minLines: 30,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 18),
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(
            note: note,
            table: widget.table,
          ),
        ));

        refreshNote(widget.table);
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          AlertsManager.confirm(
              context, title: 'Confirm?', content: 'Are you sure you want to delete this note?',
              onConfirmCallback: () async {
            await NotesDatabase.instance.delete(widget.noteId, widget.table);
            Navigator.of(context).pop();
          }, onCancelCallback: () => {});

          //await NotesDatabase.instance.delete(widget.noteId, widget.table);
        },
      );

  homeButton() => IconButton(
    icon: const Icon(Icons.home_outlined),
    onPressed: () async {
      await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const NotesTabLayout()), (route) => false);
      },
  );
}
