import 'package:flutter/material.dart';
import 'package:my_daily_notes/pages/notes_page.dart';

import 'models/note.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Daily Notes',
      color: Colors.blue,
      home: TabLayoutExample(),
    );
  }
}

class TabLayoutExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TabLayoutExampleState();
  }

}

class _TabLayoutExampleState extends State<TabLayoutExample> with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.animateTo(2);
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
          appBar: AppBar(
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontStyle: FontStyle.italic),
              overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue;
                } if (states.contains(MaterialState.focused)) {
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