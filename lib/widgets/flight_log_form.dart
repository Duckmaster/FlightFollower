import 'package:firebase_core/firebase_core.dart';
import 'package:flight_follower/models/flight_timings.dart';
import 'package:flight_follower/models/request.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/widgets/time_picker.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:provider/provider.dart';

import '../models/contacts.dart';

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
  //static var peopleList = <UserModel>[];
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
  bool locationServices = true;
  String? rotorStartTime;
  DateTime? rotorStart;
  String? datconStart;
  String? rotorStopTime;
  DateTime? rotorStop;
  String? datconStop;
  String submitButtonLabel = "Submit";

  late UserModel user;
  Flight flight = Flight();
  FlightTimings timings = FlightTimings();

  String? flightID;
  String? requestID;

  TextEditingController rotorStartController = TextEditingController();
  TextEditingController rotorStopController = TextEditingController();
  TextEditingController rotorDiffController = TextEditingController();
  TextEditingController datconDiffController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool formSubmitted = false;

  @override
  void initState() {
    super.initState();
    //peopleList = Provider.of<Contacts>(_formKey.currentContext!).items;
    getObject("user_object").then((result) {
      setState(() {
        Map<String, dynamic> userMap = result;
        user = UserModel.fromJson(userMap);
        flight.user = user.email;
        nameController.text = user.username;
        phoneController.text = user.phoneNumber;
      });
    });
  }

  void onPressed() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    _formKey.currentState!.save();

    setState(() {
      formSubmitted = !formSubmitted;
      submitButtonLabel = formSubmitted ? "Flight Completed" : "Submit";
    });

    if (formSubmitted) {
      // push to database
      db
          .collection("flights")
          .withConverter(
              fromFirestore: Flight.fromFirestore,
              toFirestore: (Flight flight, options) => flight.toFirestore())
          .add(flight)
          .then((value) {
        print("sent data");
        flightID = value.id;
        Request request = Request(
            value.id, flight.monitoringPerson!, FlightStatuses.requested);
        db
            .collection("requests")
            .withConverter(
                fromFirestore: Request.fromFirestore,
                toFirestore: (Request r, options) => r.toFirestore())
            .add(request)
            .then((value) => requestID = value.id);
      });
    } else {
      timings.rotorStart = rotorStartController.value.text;
      timings.rotorStop = rotorStopController.value.text;
      timings.flightID = flightID;
      db
          .collection("timings")
          .withConverter(
              fromFirestore: FlightTimings.fromFirestore,
              toFirestore: (FlightTimings t, options) => t.toFirestore())
          .add(timings);

      db
          .collection("requests")
          .doc(requestID)
          .update({"status": FlightStatuses.completed});
      _formKey.currentState!.reset();
    }
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

    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requests")
        .doc(requestID)
        .update({"status": FlightStatuses.enroute.name});
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
      String init = "",
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
                  Expanded(
                      child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    enabled: false,
                  )),
                  Expanded(
                      child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    enabled: false,
                  )),
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
                                flight.organisation = value!;
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
                      callback: (String? value) =>
                          {flight.aircraftIdentifier = value},
                      setEnabled: !formSubmitted),
                ],
              ),
              // Copilot and num. persons fields
              Row(
                children: [
                  createInputField("Co-pilot",
                      callback: (String? value) => {flight.copilot = value},
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
                                flight.numPersons = value.toString();
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
                      callback: (String? value) =>
                          {flight.departureLocation = value},
                      setEnabled: !formSubmitted),
                  createInputField("Destination",
                      callback: (String? value) => {flight.destination = value},
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
                        flight.departureTime = time;
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
                                  flight.ete = value;
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
                                  flight.endurance = value.toString();
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
                        Expanded(child: Consumer<Contacts>(
                          builder: (context, value, child) {
                            return DropdownButtonFormField(
                              isExpanded: true,
                              items: value.items.map<DropdownMenuItem<String>>(
                                  (UserModel value) {
                                return DropdownMenuItem<String>(
                                  value: value.email,
                                  child: Text(value.username),
                                );
                              }).toList(),
                              onChanged: formSubmitted
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        flight.monitoringPerson = value;
                                      });
                                    },
                              decoration: const InputDecoration(
                                label: Text("Monitoring Person"),
                              ),
                            );
                          },
                        )),
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
                              flight.flightType = value;
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
                                timings.datconStart = value;
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
                                timings.datconStop = value;
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
