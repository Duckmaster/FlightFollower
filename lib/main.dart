import 'package:firebase_core/firebase_core.dart';
import 'package:flight_follower/models/contacts.dart';
import 'package:flight_follower/models/form_state_manager.dart';
import 'package:flight_follower/models/login_manager.dart';
import 'package:flight_follower/screens/login_page.dart';
import 'package:flight_follower/screens/screen_handler.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/models/flights_listener.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Follower',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Various providers that I need around the app
      home: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => LoginManager()),
        ChangeNotifierProvider(create: (context) => FlightsListener()),
        ChangeNotifierProvider(create: (context) => Contacts()),
        ChangeNotifierProvider(create: (context) => FormStateManager())
      ], child: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Clears the state of the app
  void _reset(BuildContext context) {
    Contacts contacts = Provider.of<Contacts>(context, listen: false);
    contacts.refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<LoginManager>(builder: (context, value, child) {
        // Rebuild after a login, so clear the app state for new user
        if (value.isLoggedIn) {
          _reset(context);
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
