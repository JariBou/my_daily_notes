import 'package:flutter/material.dart';
import 'package:my_daily_notes/models/note.dart';
import 'package:my_daily_notes/pages/subpages/note_detail_page.dart';
import 'package:my_daily_notes/pages/subpages/notes_page.dart';
import 'package:my_daily_notes/widget/navigation_drawer.dart';

import '../services/notifications_service.dart';


/// Main layout with tabs for different noteTables
class NotesTabLayout extends StatefulWidget {
  final NoteNotification? notification;
  const NotesTabLayout({Key? key, this.notification}) : super(key: key);

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
    if (widget.notification != null) {
      return NoteDetailPage(
          noteId: widget.notification!.id,
          table: widget.notification!.table,
          isModifiable: widget.notification!.table == NoteTables.draftNotes,
        );
    }
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: const NavDrawer(),
          appBar: AppBar(
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
              const TextStyle(fontStyle: FontStyle.italic),
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