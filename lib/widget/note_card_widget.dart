import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/models/note.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
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
    final time = DateFormat.yMMMd().format(note.time);
    final minHeight = getMinHeight(index);

    return Card(
      shape:selected ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
              style: TextStyle(color: Colors.grey.shade700),
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

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
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
              style: TextStyle(color: Colors.grey.shade700),
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