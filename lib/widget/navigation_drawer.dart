import 'package:flutter/material.dart';
import 'package:my_daily_notes/pages/name_selection.dart';
import 'package:my_daily_notes/services/stored_data.dart';

/// Main Drawer
class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

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
              DataStorage.getData('name') ?? 'User',
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Change Name'),
            onTap: () => changeName(context),
          )
        ],
      ),
    );
  }

  /// Sends to page to change name
  changeName(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const ChangeNameLayout()));
  }


}
