import 'package:flutter/material.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/subpages/note_detail_page.dart';
import 'package:my_daily_notes/widget/note/note_locked_widget.dart';
import 'package:my_daily_notes/widget/note/note_widget.dart';

/// Widget that appears on screen representing the note
class NoteCardWidget extends StatefulWidget {
  final int index;
  final bool longPressEnabled;
  final VoidCallback callback;
  final String table;
  final Note note;
  final bool isReadable;
  final Function refreshNotes;

  const NoteCardWidget(
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
  _NoteCardWidgetState createState() => _NoteCardWidgetState();
}

class _NoteCardWidgetState extends State<NoteCardWidget> {
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
        }
      },
      child: (table != NoteTables.receivedNotes || widget.isReadable)
          ? NoteWidget(
        note: note,
        index: index,
        selected: selected,
      )
          : NoteLockedWidget(note: note, index: index),
    );
  }
}