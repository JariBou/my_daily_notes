import 'package:flutter/material.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/subpages/notes_page.dart';
import 'package:my_daily_notes/widget/navigation_drawer.dart';


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