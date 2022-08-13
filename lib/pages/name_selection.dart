import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_daily_notes/pages/tab_layout.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page to change Name
class ChangeNameLayout extends StatefulWidget {
  const ChangeNameLayout({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChangeNameState();
  }
}

class _ChangeNameState extends State<ChangeNameLayout> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Daily Notes'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please enter a name that will be displayed as the note's author's' name:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text != '') {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('name', nameController.text);
                    DataStorage.storeData('name', nameController.text);
                    await Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => NotesTabLayout()),
                            (Route<dynamic> route) => false);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.grey.shade700),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                ),
                child: const Text("Confirm",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          )),
    );
  }
}