import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/models/note.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.red.shade400,
  Colors.deepPurple.shade300,
  Colors.blue.shade600,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({
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
    final color = _lightColors[index % _lightColors.length];
    final time = DateFormat.yMMMd().add_Hm().format(note.time);

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
    final color = _lightColors[index % _lightColors.length];
    final time = DateFormat.yMMMd().format(note.time);

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