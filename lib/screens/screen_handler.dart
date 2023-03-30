import 'package:flight_follower/screens/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'contacts_page.dart';
import 'flight_following_page.dart';
import 'flight_log_page.dart';

class ScreenHandler extends StatefulWidget {
  const ScreenHandler({super.key});

  @override
  ScreenHandlerState createState() {
    return ScreenHandlerState();
  }
}

class ScreenHandlerState extends State<ScreenHandler> {
  int _selectedIndex = 0;
  AppBar _buildAppBar(String title, {List<Widget>? actions}) => AppBar(
        title: Text(title),
        actions: actions,
        centerTitle: true,
      );

  final List<Map<String, Object>> _pages = [
    {
      'page': FlightLogPage(),
      'title': 'Flight Details',
      'actions': <Widget>[
        /* List of actions for screen1 */
      ] //<-- optional just in case you need default actions that depend on parent as well
    },
    {
      'page': FlightFollowingPage(),
      'title': 'Flight Following Log',
      'actions': <Widget>[
        /* List of actions for screen2 */
      ] //<-- optional just in case you need default actions that depend on parent as well
    },
    {
      'page': ContactsPage(),
      'title': 'Contacts',
      'actions': <
          Widget>[] //<-- optional just in case you need default actions that depend on parent as well
    },
    {
      'page': UserPage(),
      'title': 'Contacts',
      'actions': <
          Widget>[] //<-- optional just in case you need default actions that depend on parent as well
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page = _pages[_selectedIndex]["page"] as Widget;
    return Scaffold(
      appBar: _buildAppBar(_pages[_selectedIndex]["title"] as String,
          actions: page is ContactsPage
              ? [
                  IconButton(
                      onPressed: () => page.addContactDialog(context),
                      icon: const Icon(
                        Icons.add,
                      ))
                ]
              : _pages[_selectedIndex]["actions"] as List<Widget>),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: page,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
