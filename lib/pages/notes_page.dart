import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/edit_note_page.dart';
import 'package:my_daily_notes/pages/note_detail_page.dart';
import 'package:my_daily_notes/widget/note_card_widget.dart';

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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditNotePage(table: widget.table)),
            );

            refreshNotes(widget.table);
          },
        ),
      );

  Widget buildNotes(String table) => MasonryGridView.count(
    crossAxisCount: 3,
    mainAxisSpacing: 3,
    crossAxisSpacing: 1,
    itemCount: notes.length,
    itemBuilder: (context, index) {
      final note = notes[index];
      final isReadable = note.time.isBefore(DateTime.now());

      return GestureDetector(
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
      );
    },
  );
}
