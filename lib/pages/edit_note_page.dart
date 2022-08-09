import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/widget/note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;
  final String table;

  const AddEditNotePage({
    Key? key,
    this.note,
    required this.table
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String author;
  late String table;

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    //author = widget.note?.author ?? '';
    table = widget.table;
  }

  void setTable(String table) {
    this.table = table;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton(table)],
        ),
        body: Form(
          key: _formKey,
          child: NoteFormWidget(
            title: title,
            description: description,
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
          ),
        ),
      );

  Widget buildButton(String table) {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: () => addOrUpdateNote(table),
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateNote(String table) async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote(table);
      } else {
        await addNote(table);
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote(String table) async {
    final note = widget.note!.copy(
      title: title,
      description: description,
      time: await getDate(),
    );

    await NotesDatabase.instance.update(note, table);
  }

  Future addNote(String table) async {
    final note = Note(
      title: title,
      description: description,
      time: await getDate(),
      //author: 'TestAuthor',
    );

    await NotesDatabase.instance.create(note, table);
  }

  Future<DateTime> getDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      return pickedDate;
    } else {
      return widget.note?.time ?? DateTime.now();
    }
  }

}
