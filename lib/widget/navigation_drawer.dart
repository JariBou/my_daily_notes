import 'package:flutter/material.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/stored_data.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              DataStorage.getData('name') ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Change Name'),
            onTap: () async {await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const ChangeNameLayout()),
                    (Route<dynamic> route) => false);},
          )
        ],
      ),
    );
  }
}
