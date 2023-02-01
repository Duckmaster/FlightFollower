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
  static List<String> orgList = <String>['One', 'Two', 'Three', 'Four'];
  static List<String> peopleList = <String>['Person 1', 'Person 2', 'Person 3'];
  static List<String> flightTypes = <String>[
    'Private',
    'Test/check',
    'AoC',
    'CAT',
    'Instructional',
    'HESLO 1',
    'HESLO 2',
    'HESLO 3',
    'HESLO 4',
    'HESLO 5'
  ];
  late String name;
  String? phoneNo;
  String orgDropDownValue = orgList.first;
  int? numPersons;
  double? ete;
  String? departureTime;
  bool locationServices = true;
  String? monitoringPerson;

  void onPressed() {
    _formKey.currentState!.save();
    print(name);
    print(phoneNo);
    print(orgDropDownValue);
    print(departureTime);
    print(locationServices);
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
                      items:
                          orgList.map<DropdownMenuItem<String>>((String value) {
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
              Row(
                children: [
                  Expanded(
                    child: TimePicker("Departure Time", (String time) {
                      departureTime = time;
                    }),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        items: List<double>.generate(50, (i) => (i + 1) / 10)
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value.toString()));
                        }).toList(),
                        onChanged: (double? value) {
                          setState(() {
                            ete = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "ETE",
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                        items: List<double>.generate(50, (i) => (i + 1) / 10)
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value.toString()));
                        }).toList(),
                        onChanged: (double? value) {
                          setState(() {
                            ete = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Fuel Endurance",
                        )),
                  ),
                  Expanded(
                      child: SwitchListTile(
                    value: locationServices,
                    onChanged: (value) {
                      setState(() {
                        locationServices = value;
                      });
                    },
                    title: const Text("Location Services"),
                  ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            items: peopleList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                monitoringPerson = value;
                              });
                            },
                            decoration: const InputDecoration(
                              label: Text("Monitoring Person"),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.pending,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: DropdownButtonFormField(
                    items: flightTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: ((value) {
                      setState(() {});
                    }),
                    decoration: const InputDecoration(
                      label: Text("Type of Flight"),
                    ),
                  ))
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

class TimePicker extends StatelessWidget {
  final String label;
  final Function callback;
  int? hourValue;
  int? minuteValue;
  TimePicker(this.label, this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Text(label)],
        ),
        Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hour"),
                DropdownButtonFormField(
                    items: List<int>.generate(24, (i) => i + 1)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                          value: value - 1,
                          child: Text((value - 1).toString()));
                    }).toList(),
                    onChanged: (int? value) {
                      hourValue = value;
                      callback("$hourValue:$minuteValue");
                    }),
              ],
            )),
            const Text(":"),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Minute"),
                DropdownButtonFormField(
                    items: List<int>.generate(30, (i) => i * 2, growable: false)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                          value: value, child: Text(value.toString()));
                    }).toList(),
                    onChanged: (int? value) {
                      minuteValue = value;
                      callback("$hourValue:$minuteValue");
                    }),
              ],
            ))
          ],
        )
      ],
    );
  }
}
