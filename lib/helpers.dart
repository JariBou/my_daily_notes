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

/// Function to confirm if user wants to perform a certain action
void confirm (
    BuildContext context,
    String? title,
    String? content,
    Function? onConfirmCallback,
    Function? onCancelCallback,
    ) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title ?? 'Please Confirm'),
          content: Text(content ?? 'Are you sure to remove the box?'),
          actions: [
            // The "Yes" button
            TextButton(
                onPressed: () {
                  onConfirmCallback!();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('Yes')),
            TextButton(
                onPressed: () {
                  onCancelCallback!();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('No'))
          ],
        );
      });
}