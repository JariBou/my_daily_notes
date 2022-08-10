import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final String? title;
  final String? description;
  final String? author;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const NoteFormWidget({
    Key? key,
    this.title = '',
    this.description = '',
    this.author = '',
    required this.onChangedTitle,
    required this.onChangedDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              buildTitle(),
              const SizedBox(height: 4),
              Expanded(
                  child: buildDescription()),
            ],
          ),
      );


  Widget buildTitle() => TextFormField(
        maxLines: 1,
        initialValue: title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Title',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The title cannot be empty' : null,
        onChanged: onChangedTitle,
      );

  Widget buildDescription() => TextFormField(
        maxLines: 30,
        initialValue: description,
        style: const TextStyle(color: Colors.black54, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Type something...',
          hintStyle: TextStyle(color: Colors.black54),
        ),
        validator: (title) => title != null && title.isEmpty
            ? 'The description cannot be empty'
            : null,
        onChanged: onChangedDescription,
      );
}
