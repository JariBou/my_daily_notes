import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/helpers.dart';
import 'package:my_daily_notes/models/note.dart';


/// Widget that represents the UI of a locked note
class NoteLockedWidget extends StatelessWidget {
  const NoteLockedWidget({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Note note;
  final int index;

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    final color = Constants.noteColors[index % Constants.noteColors.length];
    final time = DateFormat.yMMMd().add_Hm().format(note.time.toLocal());

    return Card(
      color: color,
      child: Container(
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
            const Center(
                child: Icon(Icons.lock_clock))
          ],
        ),
      ),
    );
  }
}