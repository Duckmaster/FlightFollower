import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp();
}

enum FlightStatuses { requested, notstarted, enroute, nearlyoverdue, overdue }

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
    Text("Flight Details"),
    Text("Flight Following Log"),
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
        page = const FlightFollowingPage();
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

class FlightFollowingPage extends StatefulWidget {
  const FlightFollowingPage({super.key});

  @override
  FlightFollowingPageState createState() {
    return FlightFollowingPageState();
  }
}

class FlightFollowingPageState extends State<FlightFollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          FlightItem(FlightStatuses.nearlyoverdue, "G-AAAA", "Blackpool",
              "Blackpool", "21:30", 0.5),
          FlightItem(FlightStatuses.notstarted, "G-AAAA", "Blackpool",
              "Blackpool", "23:12", 0.5),
        ],
      ),
    );
  }
}

class FlightItem extends StatefulWidget {
  final Enum flightStatus;
  final String aircraftReg;
  final String departureLoc;
  final String arrivalLoc;
  final String
      departure; // this could be either PLANNED or ACTUAL departure depending on flightStatus
  final double ete;
  final String arrival;

  FlightItem(this.flightStatus, this.aircraftReg, this.departureLoc,
      this.arrivalLoc, this.departure, this.ete,
      {super.key})
      : arrival = _calculateArrival(flightStatus, ete, departure);

  @override
  FlightItemState createState() {
    return FlightItemState();
  }

  static String _calculateArrival(
      Enum flightStatus, double ete, String depTime) {
    if (flightStatus == FlightStatuses.requested ||
        flightStatus == FlightStatuses.notstarted) {
      return ete.toString();
    } else {
      String hour = depTime.split(":")[0];
      String min = depTime.split(":")[1];
      num delta = 60 * ete;

      hour = (int.parse(hour) + (delta ~/ 60)).toString();
      min = (int.parse(min) + (delta % 60)).toString().split(".")[0];
      return "$hour:$min";
    }
  }
}

class FlightItemState extends State<FlightItem> {
  Map<String, String> getLabelsForStatus() {
    switch (widget.flightStatus) {
      case FlightStatuses.requested:
        {
          return Map.fromEntries(<String, String>{
            "status": "REQUESTED",
            "departure": "Planned Departure:",
            "arrival": "ETE:",
            "eta": "ACCEPT?"
          }.entries);
        }
      case FlightStatuses.notstarted:
        {
          return Map.fromEntries(<String, String>{
            "status": "START \nNOT LOGGED",
            "departure": "Planned Departure:",
            "arrival": "ETE:",
            "eta": "ETD:"
          }.entries);
        }
      case FlightStatuses.enroute:
        {
          return Map.fromEntries(<String, String>{
            "status": "EN ROUTE",
            "departure": "Departure:",
            "arrival": "Estimated arrival:",
            "eta": "ETA:"
          }.entries);
        }
      case FlightStatuses.nearlyoverdue:
        {
          return Map.fromEntries(<String, String>{
            "status": "NEARLY \nOVERDUE",
            "departure": "Departure:",
            "arrival": "Estimated arrival:",
            "eta": "ETA:"
          }.entries);
        }
      case FlightStatuses.overdue:
        {
          return Map.fromEntries(<String, String>{
            "status": "OVERDUE",
            "departure": "Departure:",
            "arrival": "Estimated arrival:",
            "eta": "ETA:"
          }.entries);
        }
    }
    return Map.fromEntries(<String, String>{
      "status": "STATUS",
      "departure": "DEP TIME",
      "arrival": "ARR TIME",
      "eta": "PLACEHOLDER"
    }.entries);
  }

  Color getColour() {
    switch (widget.flightStatus) {
      case FlightStatuses.requested:
        {
          return Colors.blue;
        }
      case FlightStatuses.notstarted:
        {
          return Colors.grey;
        }
      case FlightStatuses.enroute:
        {
          return Colors.green;
        }
      case FlightStatuses.nearlyoverdue:
        {
          return Colors.orange;
        }
      case FlightStatuses.overdue:
        {
          return Colors.red;
        }
    }
    throw Exception("Invalid flight status");
  }

  String calculateETA() {
    DateTime currentDate = DateTime.now();
    DateTime currentTime =
        DateFormat("HH:mm").parse("${currentDate.hour}:${currentDate.minute}");
    DateTime time;

    if (widget.flightStatus == FlightStatuses.notstarted) {
      time = DateFormat("HH:mm").parse(widget.departure);
    } else {
      time = DateFormat("HH:mm").parse(widget.arrival);
    }
    Duration diff = time.difference(currentTime);

    if (diff.inHours == 0) {
      return "${diff.inMinutes}mins";
    } else {
      String hour = ((diff.inMinutes ~/ 60)).toString();
      String min = ((diff.inMinutes % 60)).toString().split(".")[0];
      return "${hour}hrs ${min}mins";
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> labels = getLabelsForStatus();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: getColour()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [Text(labels["status"]!)],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [Text(widget.aircraftReg)],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Text("${widget.departureLoc} -> ${widget.arrivalLoc}")
                        ],
                      )),
                      Expanded(
                          child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                  "${labels["departure"]!} ${widget.departure}")
                            ],
                          ),
                          Row(
                            children: [
                              Text("${labels["arrival"]!} ${widget.arrival}")
                            ],
                          )
                        ],
                      ))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("${labels["eta"]!} ${calculateETA()}")],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  String? aircraftIdent;
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
  DateTime? rotorStart;
  String? datconStart;
  String? rotorStopTime;
  DateTime? rotorStop;
  String? datconStop;
  String submitButtonLabel = "Submit";

  TextEditingController rotorStartController = TextEditingController();
  TextEditingController rotorStopController = TextEditingController();
  TextEditingController rotorDiffController = TextEditingController();
  TextEditingController datconDiffController = TextEditingController();

  bool formSubmitted = false;

  void onPressed() {
    _formKey.currentState!.save();

    if (formSubmitted) {
      // push to database

      FirebaseFirestore db = FirebaseFirestore.instance;
      final flightDetails = <String, dynamic>{
        "user": "test",
        "organisation": orgDropDownValue,
        "aircraft_ident": aircraftIdent,
        "copilot": copilotName,
        "num_persons": numPersons,
        "departure": departure,
        "destination": destination,
        "departure_time": departureTime,
        "ete": ete,
        "endurance": endurance,
        "monitoring_person": monitoringPerson,
        "flight_type": flightType
      };

      db
          .collection("flights")
          .add(flightDetails)
          .then((value) => print("Added to database"));

      _formKey.currentState!.reset();
    }

    setState(() {
      formSubmitted = !formSubmitted;
      submitButtonLabel = formSubmitted ? "Flight Completed" : "Submit";
    });
  }

  void refreshMonitoringPerson() {
    // do nothing yet
  }

  void rotorStartPressed() {
    // store time button pressed
    // update the relevant input field
    DateTime now = DateTime.now();
    rotorStart = now;
    String time = "${now.hour}:${now.minute}";

    setState(() {
      rotorStartTime = time;
    });

    rotorStartController.text = time;
  }

  void rotorStopPressed() {
    // store time button pressed
    // update the relevant input field
    DateTime now = DateTime.now();
    rotorStop = now;
    String time = "${now.hour}:${now.minute}";
    String diff = rotorStop!.difference(rotorStart!).toString();

    setState(() {
      rotorStopTime = time;
    });

    rotorStopController.text = time;
    rotorDiffController.text = diff;
  }

  Widget createInputField(String fieldLabel,
      {bool setEnabled = true,
      String init = "placeholder",
      TextEditingController? controller,
      Function(String)? onChanged,
      Function? callback,
      double? fontSize}) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: fieldLabel, labelStyle: TextStyle(fontSize: fontSize)),
        initialValue: controller != null ? null : init,
        enabled: setEnabled,
        onSaved: callback != null ? (value) => callback(value) : null,
        onChanged: onChanged,
      ),
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
                  createInputField("Name",
                      callback: (String? value) => {name = value},
                      setEnabled: false),
                  createInputField("Phone Number",
                      callback: (String? value) => {phoneNo = value},
                      setEnabled: false)
                ],
              ),
              // Organisation dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: "Organisation",
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
                  createInputField("Aircraft Reg/Callsign",
                      callback: (String? value) => {aircraftIdent = value},
                      setEnabled: !formSubmitted),
                ],
              ),
              // Copilot and num. persons fields
              Row(
                children: [
                  createInputField("Co-pilot",
                      callback: (String? value) => {copilotName = value},
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
                          labelText: "Num. Persons on Board",
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
                  createInputField("Departure",
                      callback: (String? value) => {departure = value},
                      setEnabled: !formSubmitted),
                  createInputField("Destination",
                      callback: (String? value) => {destination = value},
                      setEnabled: !formSubmitted)
                ],
              ),
              // Departure time and ETE fields
              Row(
                children: [
                  Expanded(
                    child: TimePicker(
                      "Planned Departure Time",
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
                                onPressed: rotorStartTime == null
                                    ? rotorStartPressed
                                    : null,
                                child: const Text("START")),
                            createInputField("Start Time",
                                controller: rotorStartController),
                            createInputField("Datcon/Hobbs Start",
                                onChanged: (value) {
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
                                onPressed: rotorStartTime == null
                                    ? null
                                    : rotorStopPressed,
                                child: const Text("STOP")),
                            createInputField("Stop Time",
                                controller: rotorStopController),
                            createInputField("Datcon/Hobbs Stop",
                                onChanged: (value) {
                              setState(() {
                                datconStop = value;
                              });
                              double? stopDouble = double.tryParse(datconStop!);
                              double diff = stopDouble == null
                                  ? 0
                                  : stopDouble - double.parse(datconStart!);
                              datconDiffController.text =
                                  diff.toStringAsFixed(1);
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
                            createInputField("Flight Time",
                                controller: rotorDiffController, fontSize: 14),
                            createInputField("Maintenance\nTime",
                                controller: datconDiffController, fontSize: 12),
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
