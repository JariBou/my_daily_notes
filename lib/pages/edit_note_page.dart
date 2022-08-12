import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_daily_notes/database/notes_database.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:my_daily_notes/widget/note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;
  final String table;

  const AddEditNotePage({Key? key, this.note, required this.table})
      : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String author;
  late String table;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    author = widget.note?.author ?? DataStorage.getData('name');
    table = widget.table;
    titleController = TextEditingController(text: title);
    descriptionController = TextEditingController(text: description);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton(table)],
        ),
        body: Form(
          key: _formKey,
          child: buildTextArea(),
        ),
      );

  Widget buildTextArea() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: ListView(
              children: [
                buildTitle(),

                const SizedBox(
                  height: 16,
                ),

                buildDescription(),

              ],
            ));
  }

  Widget buildTitle() {
    return TextField(
        onChanged: (title) =>
            setState(() => this.title = title),
        controller: titleController,
      textCapitalization: TextCapitalization.sentences,

        decoration: widget.note?.title != null ? null
            : const InputDecoration.collapsed(
            hintText: 'Title',
            hintStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),

        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  Widget buildDescription() {
    bool isNew = widget.note?.description == null;
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      minLines: isNew ? 30 : null,
      maxLines: null,
      decoration: isNew ?const InputDecoration.collapsed(
        hintText: 'description',
      ) : null,
      onChanged: (description) =>
          setState(() => this.description = description),
      controller: descriptionController,
      expands: isNew ? false : true,
    );
  }

  /*@override
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
      );*/

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
      author: author,
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
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      await getTime(widget.note?.time);
      pickedDate = DateTime.parse('${_dateController.text}T${_timeController.text}');
      return pickedDate;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await setTimeController(const TimeOfDay(hour: 00, minute: 00));
      pickedDate = DateTime.parse('${_dateController.text}T${_timeController.text}');
      return pickedDate;
    }
  }

  Future<Null> setTimeController(TimeOfDay time) async {
    String hour;
    String minutes;
    hour = time.hour.toString().padLeft(2, '0');
    minutes = time.minute.toString().padLeft(2, '0');
    _timeController.text = '$hour:$minutes';
  }

  Future<Null> getTime(DateTime? dateTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),

    );

    if (pickedTime != null) {
        await setTimeController(pickedTime);
    } else {
      if (dateTime != null) {
        await setTimeController(TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
      } else {
        await setTimeController(const TimeOfDay(hour: 0, minute: 0));
      }
    }



  }

}
