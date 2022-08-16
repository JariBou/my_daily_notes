import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/services/helpers.dart';
import 'package:my_daily_notes/models/note.dart';

/// Widget that represents the UI of a note
class NoteWidget extends StatelessWidget {
  const NoteWidget({
    Key? key,
    required this.note,
    required this.index,
    required this.selected,
  }) : super(key: key);

  final Note note;
  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    final color = Constants.noteColors[index % Constants.noteColors.length];
    final time = DateFormat.yMMMd().add_Hm().format(note.time.toLocal());

    return Card(
      color: color,
      child: Container(
        decoration: selected
            ? BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: Colors.black))
            : BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        constraints: const BoxConstraints(maxHeight: double.infinity, maxWidth: double.infinity),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              note.author,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              note.description,
              maxLines: 10,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                color: Colors.black38,
                fontSize: 10,
              ),
            ),

          ],
        ),
      ),
    );
  }

}

