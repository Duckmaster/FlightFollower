import 'package:flight_follower/models/flights_listener.dart';
import 'package:flight_follower/screens/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contacts_page.dart';
import 'flight_following_page.dart';
import 'flight_log_page.dart';

/// Manages pages and their associated styling for this app
class ScreenHandler extends StatefulWidget {
  const ScreenHandler({super.key});

  @override
  ScreenHandlerState createState() {
    return ScreenHandlerState();
  }
}

class ScreenHandlerState extends State<ScreenHandler> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    FlightsListener flightsListener =
        Provider.of<FlightsListener>(context, listen: false);
    flightsListener.initListener();
  }

  AppBar _buildAppBar(String title, {List<Widget>? actions}) => AppBar(
        title: Text(title),
        actions: actions,
        centerTitle: true,
      );

  final List<Map<String, Object>> _pages = [
    {'page': FlightLogPage(), 'title': 'Flight Details'},
    {'page': FlightFollowingPage(), 'title': 'Flight Following Log'},
    {'page': ContactsPage(), 'title': 'Contacts'},
    {'page': UserPage(), 'title': 'Contacts'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Gets [page]-specific app bar actions
  ///
  /// Returns a list of action widgets for [page]
  List<Widget> getActionsForPage(Widget page) {
    if (page is ContactsPage) {
      return [
        IconButton(
            onPressed: () => page.dialogAddNewContact(context),
            icon: const Icon(
              Icons.add,
            ))
      ];
    } else if (page is UserPage) {
      return [
        IconButton(
            onPressed: () => page.logout(context),
            icon: const Icon(
              Icons.logout,
            ))
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page = _pages[_selectedIndex]["page"] as Widget;
    return Scaffold(
      appBar: _buildAppBar(_pages[_selectedIndex]["title"] as String,
          actions: getActionsForPage(page)),
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
