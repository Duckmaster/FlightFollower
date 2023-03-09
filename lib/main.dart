import 'package:firebase_core/firebase_core.dart';
import 'package:flight_follower/models/contacts.dart';
import 'package:flight_follower/screens/contacts_page.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/screens/flight_following_page.dart';
import 'package:flight_follower/screens/flight_log_page.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/models/flights_listener.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Follower',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => FlightsListener()),
        ChangeNotifierProvider(create: (context) => Contacts())
      ], child: const MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  /* static const List<Widget> _titles = <Widget>[
    Text("Flight Details"),
    Text("Flight Following Log"),
    Text("Contacts")
  ]; */

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
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar(String title, {List<Widget>? actions}) => AppBar(
        title: Text(title),
        actions: actions,
        centerTitle: true,
      );

  @override
  void initState() {
    UserModel user =
        UserModel("John Smith", "email@address.com", "07123456789");
    storeObject(user, "user_object");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page = _pages[_selectedIndex]["page"] as Widget;

    return LayoutBuilder(builder: (context, constraints) {
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
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}
