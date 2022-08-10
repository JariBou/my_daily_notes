
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_daily_notes/pages/notes_page.dart';
import 'package:my_daily_notes/stored_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('name', '');
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
        home: TabLayoutExample(),
      );
    } else {
      return MaterialApp(
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
                            builder: (context) => TabLayoutExample()),
                        (Route<dynamic> route) => false);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade700),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                child: const Text("Confirm", style: TextStyle(color: Colors.white)),
              )
            ],
          )),
    );
  }
}

class TabLayoutExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TabLayoutExampleState();
  }
}

class _TabLayoutExampleState extends State<TabLayoutExample>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.animateTo(2);
    //Future.delayed(Duration.zero, () => askForName(context));
  }



  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.arrow_upward), child: Text('Sent')),
    Tab(icon: Icon(Icons.mail), text: 'Received'),
    Tab(icon: Icon(Icons.border_color), text: 'Drafts'),
    Tab(icon: Icon(Icons.looks_4), text: 'Tab Four'),
    Tab(icon: Icon(Icons.looks_5), text: 'Tab Five'),
    Tab(icon: Icon(Icons.looks_6), text: 'Tab Six'),
  ];

  static final List<Widget> _views = [
    const NotesPage(table: NoteTables.sentNotes),
    const NotesPage(table: NoteTables.receivedNotes),
    const NotesPage(table: NoteTables.draftNotes),
    const Center(child: Text('Content of Tab Four')),
    const Center(child: Text('Content of Tab Five')),
    const Center(child: Text('Content of Tab Six')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 6,
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
              // Uncomment the line below and remove DefaultTabController if you want to use a custom TabController
              // controller: _tabController,
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
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.more_vert),
                  )),
            ],
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            // Uncomment the line below and remove DefaultTabController if you want to use a custom TabController
            // controller: _tabController,
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
            leading: const Icon(Icons.input),
            title: const Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }

}