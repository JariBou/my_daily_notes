import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_daily_notes/pages/notes_page.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name') ?? '';

  DataStorage.storeData('name', name);

  bool isLogged = name != '';

  runApp(MyApp(isLogged: isLogged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    if (isLogged) {
      return MaterialApp(
        title: 'My Daily Notes',
        color: Colors.blue,
        home: NotesTabLayout(),
      );
    } else {
      return const MaterialApp(
        title: 'My Daily Notes',
        color: Colors.blue,
        home: ChangeNameLayout(),
      );
    }
  }
}

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
                style: const TextStyle(fontSize: 16),
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

class NotesTabLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotesTabLayoutState();
  }
}

class _NotesTabLayoutState extends State<NotesTabLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animateTo(2);
    //Future.delayed(Duration.zero, () => askForName(context));
  }

  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.arrow_upward), child: Text('Sent')),
    Tab(icon: Icon(Icons.mail), text: 'Received'),
    Tab(icon: Icon(Icons.border_color), text: 'Drafts'),
  ];

  static final List<Widget> _views = [
    const NotesPage(table: NoteTables.sentNotes),
    const NotesPage(table: NoteTables.receivedNotes),
    const NotesPage(table: NoteTables.draftNotes),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: NavDrawer(),
          appBar: AppBar(
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontStyle: FontStyle.italic),
              overlayColor:
                  MaterialStateColor.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue;
                }
                if (states.contains(MaterialState.focused)) {
                  return Colors.orange;
                } else if (states.contains(MaterialState.hovered)) {
                  return Colors.pinkAccent;
                }

                return Colors.transparent;
              }),
              indicatorWeight: 10,
              indicatorColor: Colors.red,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(5),
              indicator: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
                color: Colors.pinkAccent,
              ),
              isScrollable: true,
              physics: const BouncingScrollPhysics(),
              onTap: (int index) {
                print('Tab $index is tapped');
              },
              enableFeedback: true,
              tabs: _tabs,
            ),
            title: const Text('My Daily Notes'),
            backgroundColor: Colors.blue,
            /*leading: GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.menu,
              ),
            ),*/
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: _views,
          ),
        ),
      ),
    );
  }

}

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
