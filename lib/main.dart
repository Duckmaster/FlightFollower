import 'package:firebase_core/firebase_core.dart';
import 'package:flight_follower/models/contacts.dart';
import 'package:flight_follower/models/form_state_manager.dart';
import 'package:flight_follower/models/login_manager.dart';
import 'package:flight_follower/screens/contacts_page.dart';
import 'package:flight_follower/screens/login_page.dart';
import 'package:flight_follower/screens/screen_handler.dart';
import 'package:flight_follower/screens/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/screens/flight_following_page.dart';
import 'package:flight_follower/screens/flight_log_page.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/models/flights_listener.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
        ChangeNotifierProvider(create: (context) => Contacts()),
        ChangeNotifierProvider(create: (context) => LoginManager()),
        ChangeNotifierProvider(create: (context) => FormStateManager())
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
  /* static const List<Widget> _titles = <Widget>[
    Text("Flight Details"),
    Text("Flight Following Log"),
    Text("Contacts")
  ]; */

  void reset(BuildContext context) {
    Contacts contacts = Provider.of<Contacts>(context, listen: false);
    contacts.refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<LoginManager>(builder: (context, value, child) {
        if (value.isLoggedIn) {
          reset(context);
          return ScreenHandler();
        } else {
          return const Scaffold(
            body: SafeArea(
              child: LoginPage(),
            ),
          );
        }
      });
    });
  }
}
