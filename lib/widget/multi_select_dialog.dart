import 'package:flutter/material.dart';

/// A Custom Dialog that displays a single question & list of answers.
class MultiSelectDialog extends StatelessWidget {
  /// List to display the answer.
  final List<String> answers;

  /// Widget to display the question.
  final Widget question;

  /// List to hold the selected answer
  /// i.e. ['a'] or ['a','b'] or ['a','b','c'] etc.
  final List<String> selectedItems = [];

  /// Map that holds selected option with a boolean value
  /// i.e. { 'a' : false}.
  static Map<String, bool> mappedItem = {};

  MultiSelectDialog({required this.answers, required this.question});

  /// Function that converts the list answer to a map.
  Map<String, bool> initMap() {
    return mappedItem = Map.fromIterable(answers,
        key: (k) => k.toString(),
        value: (v) {
          if (v != true && v != false)
            return false;
          else
            return v as bool;
        });
  }

  @override
  Widget build(BuildContext context) {
    if (mappedItem == null) {
      initMap();
    }
    return SimpleDialog(
      title: question,
      children: [
        ...mappedItem.keys.map((String key) {
          return StatefulBuilder(
            builder: (_, StateSetter setState) => CheckboxListTile(
                title: Text(key), // Displays the option
                value: mappedItem[key], // Displays checked or unchecked value
                controlAffinity: ListTileControlAffinity.platform,
                onChanged: (value) => setState(() => mappedItem[key] = value!)),
          );
        }).toList(),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ButtonStyle(visualDensity: VisualDensity.comfortable),
                child: Text('Confirm'),
                onPressed: () {
                  // Clear the list
                  selectedItems.clear();

                  // Traverse each map entry
                  mappedItem.forEach((key, value) {
                    if (value == true) {
                      selectedItems.add(key);
                    }
                  });

                  // Close the Dialog & return selectedItems
                  Navigator.pop(context, selectedItems);
                }))
      ],
    );
  }

  static Future<List<String>?> dialog(
      BuildContext context, String title, List<String> options) async {
    return await showDialog<List<String>>(
        context: context,
        builder: (_) =>
            MultiSelectDialog(question: Text(title), answers: options));
  }

}
