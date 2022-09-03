import 'package:flutter/material.dart';

/// Class that will hold shared static constants
class Constants {

  /// List of possible note widget colors
  static final List<Color> noteColors = [
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

}

class AlertsManager {

  /// Function to alert user of smth
  static void alert(BuildContext context,
      {String? title,
      String? content,
      String? buttonText}) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(title ?? 'Warning'),
            content: Text(content ?? 'Irregular action detected'),
            actions: [TextButton(onPressed: () => {Navigator.of(context, rootNavigator: true).pop()}, child: Text(buttonText ?? 'Ok'))],
          );
        });
  }

  /// Function to confirm if user wants to perform a certain action
  static void confirm (
      BuildContext context,
      {
    String? title,
    String? content,
        String? yesText,
        String? noText,
    required Function onConfirmCallback,
    Function? onCancelCallback,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(title ?? 'Please Confirm'),
            content: Text(content ?? 'Are you sure to do this?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    onConfirmCallback();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(yesText ?? 'Yes')),
              TextButton(
                  onPressed: () {
                    onCancelCallback!() ?? () => {};
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(noText ?? 'No'))
            ],
          );
        });
  }

  static void selectableOptionsDialog(BuildContext context,
  {String? title,
  required List<SimpleDialogOption> options}) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            title: Text(title ?? 'Select Option'),
            children: options,
          );
        });
  }
}

