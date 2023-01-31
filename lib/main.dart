import 'package:flutter/material.dart';

void main() {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  static const List<Widget> _titles = <Widget>[
    Text("Flight Log"),
    Text("Flight Monitoring"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = const FlightLogPage();
        break;
      case 1:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: _titles.elementAt(_selectedIndex),
          centerTitle: true,
        ),
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
              label: 'Flight Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: 'Flight Monitoring',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}

class FlightLogPage extends StatelessWidget {
  const FlightLogPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlightLogForm();
  }
}

class FlightLogForm extends StatefulWidget {
  const FlightLogForm({super.key});

  @override
  FlightLogFormState createState() {
    return FlightLogFormState();
  }
}

class FlightLogFormState extends State<FlightLogForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  late String name;
  String? phoneNo;
  String orgDropDownValue = list.first;
  int? numPersons;

  void onPressed() {
    _formKey.currentState!.save();
    print(name);
    print(phoneNo);
    print(orgDropDownValue);
  }

  Widget createInputField(String fieldLabel, {bool setEnabled = true}) {
    return Expanded(
      child: TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
          ),
          initialValue: "placeholder",
          enabled: setEnabled,
          onSaved: (String? value) {
            name = value!;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  for (String label in ["Name", "Phone Number"])
                    createInputField(label, setEnabled: false)
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: "Name",
                      ),
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          orgDropDownValue = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  for (String label in [
                    "Aircraft Registration",
                    "Aircraft Callsign"
                  ])
                    createInputField(label)
                ],
              ),
              Row(
                children: [
                  createInputField("Co-pilot"),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: List<int>.generate(10, (i) => i + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem(
                            value: value, child: Text(value.toString()));
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          numPersons = value!;
                        });
                      },
                      decoration: const InputDecoration(
                          labelText: "Num. Persons",
                          contentPadding:
                              EdgeInsets.only(bottom: 9.5, top: 9.5)),
                      value: 1,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  for (String label in ["Departure", "Destination"])
                    createInputField(label)
                ],
              ),
              ElevatedButton(onPressed: onPressed, child: const Text("Submit"))
            ],
          ),
        ),
      ),
    );
    /* TextFormField(
        decoration: const InputDecoration(
          labelText: "Name",
        ),
        initialValue: "John Smith",
        enabled: false,
      ), */
  }
}
