import 'package:flutter/material.dart';

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