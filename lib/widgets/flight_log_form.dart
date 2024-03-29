import 'package:flight_follower/models/login_manager.dart';
import 'package:flight_follower/models/request.dart';
import 'package:flight_follower/utilities/gps_manager.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/widgets/time_picker.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:provider/provider.dart';

import '../models/contacts.dart';
import '../models/form_state_manager.dart';

class FlightLogForm extends StatefulWidget {
  const FlightLogForm({super.key});

  @override
  FlightLogFormState createState() {
    return FlightLogFormState();
  }
}

class FlightLogFormState extends State<FlightLogForm>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static List<String> orgList = <String>[];
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
  //String? rotorStartTime;
  //DateTime? rotorStart;
  //String? datconStart;
  //String? rotorStopTime;
  //DateTime? rotorStop;
  //String? datconStop;
  String submitButtonLabel = "Submit";

  late UserModel user;
  Flight flight = Flight();
  FlightTimings timings = FlightTimings();
  //FlightTimings timings = FlightTimings();
  FormStateManager _formStateManager = FormStateManager();
  final DatabaseWrapper _db = DatabaseWrapper();

  String? requestID;

  TextEditingController rotorStartController = TextEditingController();
  TextEditingController rotorStopController = TextEditingController();
  TextEditingController rotorDiffController = TextEditingController();
  TextEditingController datconDiffController = TextEditingController();

  bool formSubmitted = false;

  late Future<void> _formLoaded;

  @override
  void initState() {
    super.initState();
    //peopleList = Provider.of<Contacts>(_formKey.currentContext!).items;
    WidgetsBinding.instance.addObserver(this);
    _formLoaded = initForm();
  }

  Future<void> initForm() async {
    await _formStateManager.load();
    var result = await getObject("user_object");
    setState(() {
      user = UserModel.fromJson(result);
      flight = _formStateManager.flight;
      flight.user = user.email;
      timings = flight.timings!;
      rotorStartController.text = formattedTimeFromDateTime(timings.rotorStart);
      rotorStopController.text = formattedTimeFromDateTime(timings.rotorStop);

      formSubmitted = _formStateManager.isSubmitted;
      requestID = _formStateManager.requestID;
    });
    return;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // app is no longer the focus so we should save our state
      if (_formStateManager.listener != null) {
        DatabaseWrapper().removeListener(_formStateManager.listener!);
        _formStateManager.listener!.cancel();
      }
      await _formStateManager.save();
    } //else if (state == AppLifecycleState.resumed) {
    //await _formStateManager.load();
    //setState(() {
    //  _formLoaded = initForm();
    //});
    //}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _formStateManager.save();
    super.dispose();
  }

  void onPressed() {
    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      formSubmitted = _formStateManager.isSubmitted = !formSubmitted;
      _formStateManager.monPersonSelectEnabled = false;
      submitButtonLabel = formSubmitted ? "Flight Completed" : "Submit";
    });

    if (formSubmitted) {
      // push to database
      _db.addDocument("flights", flight.toFirestore()).then((flightID) async {
        print("sent data");
        _formStateManager.flightID = flightID;
        if (flight.monitoringPerson != null) {
          await _addRequestToDatabase();
          _initMonitoringPersonListener();
        }
      });
    } else {
      if (_formStateManager.listener != null)
        _db.removeListener(_formStateManager.listener!);
      DateTime now = DateTime.now();
      String date = now.toString().split(" ")[0];
      timings.rotorStart = DateTime.parse("$date ${rotorStartController.text}");
      timings.rotorStop = DateTime.parse("$date ${rotorStopController.text}");
      _db.updateDocument("flights", _formStateManager.flightID,
          {"timings": flight.timings!.toFirestore()});
      if (flight.monitoringPerson != null) {
        _db.updateDocument(
            "requests", requestID!, {"status": FlightStatuses.completed.name});
      }
      _formLoaded = _formStateManager.reset().then((value) {
        flight = value.flight;
        timings = flight.timings!;
        flight.user = user.email;
        if (value.locationServices && timings.rotorStart != null) {
          GPSManager().start(value.flightID);
        }
      });
      //await initForm();
    }
  }

  void refreshMonitoringPerson() async {
    // TODO: Needs implementation
    setState(() {
      _formStateManager.monPersonIcon = const Icon(Icons.pending);
      _formStateManager.monPersonSelectEnabled = false;
      _formStateManager.refreshButtonVisible = false;
    });
    // cancel old listener
    // send new request
    // add listener for request
    _db.removeListener(_formStateManager.listener!);
    _formStateManager.listener = null;

    await _addRequestToDatabase();

    _initMonitoringPersonListener();
  }

  void _initMonitoringPersonListener() {
    _formStateManager.listener = _db.addListener("requests", [
      [FieldPath.documentId, "==", requestID]
    ], (event) {
      for (var change in event.docChanges) {
        Request request =
            Request.fromMap(change.doc.data()! as Map<String, dynamic>);

        switch (change.type) {
          case DocumentChangeType.added:
            break;
          case DocumentChangeType.modified:
            if (request.status == FlightStatuses.accepted) {
              _formStateManager.monPersonIcon =
                  const Icon(Icons.check, color: Colors.green);
              //monPersonSelectEnabled = false;
            } else if (request.status == FlightStatuses.declined) {
              _formStateManager.monPersonIcon =
                  const Icon(Icons.close, color: Colors.red);
              _formStateManager.refreshButtonVisible = true;
              _formStateManager.monPersonSelectEnabled = true;
            }
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    });
  }

  Future<void> _addRequestToDatabase() async {
    if (flight.monitoringPerson != null) {
      Request request = Request(_formStateManager.flightID,
          flight.monitoringPerson!, FlightStatuses.requested);
      String requestID =
          await _db.addDocument("requests", request.toFirestore());
      setState(() {
        _formStateManager.requestID = this.requestID = requestID;
      });
    }
  }

  void rotorStartPressed() {
    // store time button pressed
    // update the relevant input field
    DateTime now = DateTime.now();
    // make X:X into XX:XX
    String hour = now.hour < 10 ? "0${now.hour}" : now.hour.toString();
    String minute = now.minute < 10 ? "0${now.minute}" : now.minute.toString();
    String time = "$hour:$minute";

    setState(() {
      timings.rotorStart = now;
    });

    rotorStartController.text = time;

    if (flight.monitoringPerson != null) {
      _db.updateDocument(
          "requests", requestID!, {"status": FlightStatuses.enroute.name});
    }
    if (_formStateManager.locationServices) {
      GPSManager().start(FormStateManager().flightID);
    }
  }

  void rotorStopPressed() {
    // store time button pressed
    // update the relevant input field
    DateTime now = DateTime.now();
    String hour = now.hour < 10 ? "0${now.hour}" : now.hour.toString();
    String minute = now.minute < 10 ? "0${now.minute}" : now.minute.toString();
    String time = "$hour:$minute";
    setState(() {
      timings.rotorStop = now;
    });
    String diff = timings.rotorStop!.difference(timings.rotorStart!).toString();
    rotorStopController.text = time;
    rotorDiffController.text = diff;

    GPSManager().stop();
  }

  String? validatorEmpty(String? value) {
    return value == "" || value == null ? "This field is required." : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _formLoaded,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(child: Text("Loading..."));
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

                      Consumer<LoginManager>(builder: (context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              initialValue: value.currentUserModel.username,
                              decoration: InputDecoration(labelText: "Name"),
                              enabled: false,
                            )),
                            Expanded(
                                child: TextFormField(
                              initialValue: value.currentUserModel.phoneNumber,
                              decoration:
                                  InputDecoration(labelText: "Phone Number"),
                              enabled: false,
                            )),
                          ],
                        );
                      }),
                      // Organisation dropdown
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                labelText: "Organisation",
                              ),
                              items: null,
                              /*orgList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()*/
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
                          Expanded(
                            child: TextFormField(
                                initialValue: flight.aircraftIdentifier,
                                decoration: const InputDecoration(
                                  labelText: "Aircraft Reg/Callsign",
                                ),
                                enabled: !formSubmitted,
                                onChanged: (value) =>
                                    flight.aircraftIdentifier = value,
                                validator: validatorEmpty),
                          ),
                        ],
                      ),
                      // Copilot and num. persons fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: flight.copilot,
                              decoration: const InputDecoration(
                                labelText: "Co-pilot",
                              ),
                              enabled: !formSubmitted,
                              onChanged: (value) => flight.copilot = value,
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField(
                              items: List<int>.generate(10, (i) => i + 1)
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value.toString()));
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
                              value: int.parse(flight.numPersons ?? "1"),
                            ),
                          ),
                        ],
                      ),
                      // Departure and destination fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: flight.departureLocation,
                              decoration: const InputDecoration(
                                labelText: "Departure",
                              ),
                              enabled: !formSubmitted,
                              onChanged: (value) =>
                                  flight.departureLocation = value,
                              validator: validatorEmpty,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: flight.destination,
                              decoration: const InputDecoration(
                                labelText: "Destination",
                              ),
                              enabled: !formSubmitted,
                              onChanged: (value) => flight.destination = value,
                              validator: validatorEmpty,
                            ),
                          )
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
                              time: flight.departureTime,
                              enabled: !formSubmitted,
                              validator: (int? value) {
                                return value == null
                                    ? "This field is required."
                                    : null;
                              },
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField(
                                items: List<double>.generate(
                                        50, (i) => (i + 1) / 10)
                                    .map<DropdownMenuItem<double>>(
                                        (double value) {
                                  return DropdownMenuItem(
                                      value: value,
                                      child: Text(value.toString()));
                                }).toList(),
                                value: flight.ete,
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
                                items: List<double>.generate(
                                        50, (i) => (i + 1) / 10)
                                    .map<DropdownMenuItem<double>>(
                                        (double value) {
                                  return DropdownMenuItem(
                                      value: value,
                                      child: Text(value.toString()));
                                }).toList(),
                                value: double.parse(flight.endurance ?? "0.1"),
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
                            value: _formStateManager.locationServices,
                            onChanged: formSubmitted
                                ? null
                                : (value) {
                                    setState(() {
                                      _formStateManager.locationServices =
                                          value;
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
                                    return FutureBuilder<void>(
                                        future: value.isReady,
                                        builder: (context, snapshot) => snapshot
                                                    .connectionState !=
                                                ConnectionState.done
                                            ? Text("Loading...")
                                            : DropdownButtonFormField(
                                                isExpanded: true,
                                                value: flight.monitoringPerson,
                                                items: [
                                                      DropdownMenuItem<String>(
                                                          child: Text(""))
                                                    ] +
                                                    value.contacts.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (UserModel value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value.email,
                                                        child: Text(
                                                            value.username),
                                                      );
                                                    }).toList(),
                                                onChanged: !_formStateManager
                                                        .monPersonSelectEnabled
                                                    ? null
                                                    : (String? value) {
                                                        setState(() {
                                                          flight.monitoringPerson =
                                                              value;
                                                        });
                                                      },
                                                decoration:
                                                    const InputDecoration(
                                                  label:
                                                      Text("Monitoring Person"),
                                                ),
                                              ));
                                  },
                                )),
                                // Icon for visual feedback on monitoring person (waiting to accept, declined, accepted)
                                Visibility(
                                  visible: formSubmitted,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: _formStateManager.monPersonIcon,
                                ),

                                Visibility(
                                  visible:
                                      _formStateManager.refreshButtonVisible,
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
                            value: flight.flightType,
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
                            validator: validatorEmpty,
                          ))
                        ],
                      ),
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
                                        onPressed: timings.rotorStart == null
                                            ? rotorStartPressed
                                            : null,
                                        child: const Text("START")),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: "Start Time",
                                        ),
                                        controller: rotorStartController,
                                        validator: validatorEmpty,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: "Datcon/Hobbs Start",
                                        ),
                                        initialValue: timings.datconStart,
                                        onChanged: (value) {
                                          setState(() {
                                            timings.datconStart = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                        onPressed: timings.rotorStart == null
                                            ? null
                                            : rotorStopPressed,
                                        child: const Text("STOP")),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: "Stop Time",
                                        ),
                                        controller: rotorStopController,
                                        validator: validatorEmpty,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: "Datcon/Hobbs Stop",
                                        ),
                                        initialValue: timings.datconStop,
                                        onChanged: (value) {
                                          setState(() {
                                            timings.datconStop = value;
                                          });
                                          // TODO: Move this into a sep func
                                          double? stopDouble = double.tryParse(
                                              timings.datconStop!);
                                          double diff = stopDouble == null
                                              ? 0
                                              : stopDouble -
                                                  double.parse(
                                                      timings.datconStart!);
                                          datconDiffController.text =
                                              diff.toStringAsFixed(1);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 48),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: "Flight Time",
                                            labelStyle:
                                                TextStyle(fontSize: 14)),
                                        controller: rotorDiffController,
                                        enabled: false,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: "Maintenance\nTime",
                                            labelStyle:
                                                TextStyle(fontSize: 12)),
                                        controller: datconDiffController,
                                        enabled: false,
                                      ),
                                    ),
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
              ));
        });
  }
}
