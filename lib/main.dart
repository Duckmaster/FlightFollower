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
  String? name;
  String? phoneNo;
  String orgDropDownValue = orgList.first;
  String? aircraftReg;
  String? aircraftCallsign;
  String? copilotName;
  int? numPersons;
  String? departure;
  String? destination;
  String? departureTime;
  double? ete;
  double? endurance;
  bool locationServices = true;
  String? monitoringPerson;
  String? flightType;
  String? rotorStartTime;
  String? datconStart;
  String? rotorStopTime;
  String? datconStop;
  String? rotorDiff;
  String? datconDiff;
  String submitButtonLabel = "Submit";

  bool formSubmitted = false;

  void onPressed() {
    _formKey.currentState!.save();

    setState(() {
      formSubmitted = true;
    });

    print(name);
    print(phoneNo);
    print(orgDropDownValue);
    print(aircraftReg);
    print(aircraftCallsign);
    print(copilotName);
    print(numPersons);
    print(departure);
    print(destination);
    print(departureTime);
    print(ete);
    print(endurance);
    print(locationServices);
    print(monitoringPerson);
    print(flightType);

    print("Form submitted: $formSubmitted");
  }

  void refreshMonitoringPerson() {
    // do nothing yet
  }

  void rotorStartPressed() {
    // store time button pressed
    // update the relevant input field
  }

  void rotorStopPressed() {
    // store time button pressed
    // update the relevant input field
  }

  Widget createInputField(String fieldLabel, Function callback,
      {bool setEnabled = true}) {
    return Expanded(
      child: TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
          ),
          initialValue: "placeholder",
          enabled: setEnabled,
          onSaved: (value) => callback(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          // Some padding so the form doesnt go all the way to the edges
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Name and Phone No fields
              Row(
                children: [
                  createInputField("Name", (String? value) => {name = value},
                      setEnabled: false),
                  createInputField(
                      "Phone Number", (String? value) => {phoneNo = value},
                      setEnabled: false)
                ],
              ),
              // Organisation dropdown
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
                      onChanged: formSubmitted
                          ? null
                          : (String? value) {
                              setState(() {
                                orgDropDownValue = value!;
                              });
                            },
                    ),
                  ),
                ],
              ),
              // Reg and callsign fields
              Row(
                children: [
                  createInputField("Aircraft Registration",
                      (String? value) => {aircraftReg = value},
                      setEnabled: !formSubmitted),
                  createInputField("Aircraft Callsign",
                      (String? value) => {aircraftCallsign = value},
                      setEnabled: !formSubmitted)
                ],
              ),
              // Copilot and num. persons fields
              Row(
                children: [
                  createInputField(
                      "Co-pilot", (String? value) => {copilotName = value},
                      setEnabled: !formSubmitted),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: List<int>.generate(10, (i) => i + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem(
                            value: value, child: Text(value.toString()));
                      }).toList(),
                      onChanged: formSubmitted
                          ? null
                          : (int? value) {
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
              // Departure and destination fields
              Row(
                children: [
                  createInputField(
                      "Departure", (String? value) => {departure = value},
                      setEnabled: !formSubmitted),
                  createInputField(
                      "Destination", (String? value) => {destination = value},
                      setEnabled: !formSubmitted)
                ],
              ),
              // Departure time and ETE fields
              Row(
                children: [
                  Expanded(
                    child: TimePicker(
                      "Departure Time",
                      (String time) {
                        departureTime = time;
                      },
                      enabled: !formSubmitted,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        items: List<double>.generate(50, (i) => (i + 1) / 10)
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value.toString()));
                        }).toList(),
                        onChanged: formSubmitted
                            ? null
                            : (double? value) {
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
              // Fuel endurance field and location services toggle
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                        items: List<double>.generate(50, (i) => (i + 1) / 10)
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value.toString()));
                        }).toList(),
                        onChanged: formSubmitted
                            ? null
                            : (double? value) {
                                setState(() {
                                  endurance = value!;
                                });
                              },
                        decoration: const InputDecoration(
                          labelText: "Fuel Endurance",
                        )),
                  ),
                  Expanded(
                      child: SwitchListTile(
                    value: locationServices,
                    onChanged: formSubmitted
                        ? null
                        : (value) {
                            setState(() {
                              locationServices = value;
                            });
                          },
                    title: const Text("Location Services"),
                  ))
                ],
              ),
              // Monitoring person and flight type dropdowns
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
                            onChanged: formSubmitted
                                ? null
                                : (String? value) {
                                    setState(() {
                                      monitoringPerson = value;
                                    });
                                  },
                            decoration: const InputDecoration(
                              label: Text("Monitoring Person"),
                            ),
                          ),
                        ),
                        // Icon for visual feedback on monitoring person (waiting to accept, declined, accepted)
                        Visibility(
                          visible: formSubmitted,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: const Icon(
                            Icons.pending,
                          ),
                        ),

                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                              onPressed: refreshMonitoringPerson,
                              icon: const Icon(Icons.refresh)),
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
                    onChanged: formSubmitted
                        ? null
                        : (String? value) {
                            setState(() {
                              flightType = value;
                            });
                          },
                    decoration: const InputDecoration(
                      label: Text("Type of Flight"),
                    ),
                  ))
                ],
              ),
              // Honestly cant decide if i want 3 columns or 3 rows AAAAAAAAA
              const SizedBox(
                height: 50,
              ),
              Visibility(
                visible: formSubmitted,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(
                                onPressed: rotorStartPressed,
                                child: const Text("Rotor START")),
                            createInputField("Rotor Start Time", (value) {
                              setState(() {
                                rotorStartTime = value;
                              });
                            }),
                            createInputField("Datcon/Hobbs Start", (value) {
                              setState(() {
                                datconStart = value;
                              });
                            })
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(
                                onPressed: rotorStopPressed,
                                child: const Text("Rotor STOP")),
                            createInputField("Rotor Stop Time", (value) {
                              setState(() {
                                rotorStopTime = value;
                              });
                            }),
                            createInputField("Datcon/Hobbs Stop", (value) {
                              setState(() {
                                datconStop = value;
                              });
                            })
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            //const ElevatedButton(
                            //    onPressed: null, child: Text("test")),
                            const SizedBox(height: 48),
                            createInputField("Difference", (value) {
                              setState(() {
                                rotorDiff = value;
                              });
                            }),
                            createInputField("Difference", (value) {
                              setState(() {
                                datconDiff = value;
                              });
                            })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Submit button
              ElevatedButton(
                  onPressed: onPressed, child: Text(submitButtonLabel))
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
  bool enabled;
  int? hourValue;
  int? minuteValue;
  TimePicker(this.label, this.callback, {super.key, this.enabled = true});

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
                    onChanged: !enabled
                        ? null
                        : (int? value) {
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
                    onChanged: !enabled
                        ? null
                        : (int? value) {
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
