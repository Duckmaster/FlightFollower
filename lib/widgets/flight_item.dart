import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:flight_follower/utilities/gps_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:http/http.dart' as http;

class FlightItem extends StatefulWidget {
  final Flight flight;
  final String requestID;
  final String flightID;
  Enum flightStatus;
  final String _arrival;
  final double MAX_WIDTH = 500;

  bool extended;

  FlightItem(this.flight, this.flightStatus, this.requestID, this.flightID,
      {super.key, bool showLocation = false})
      : _arrival = _calculateArrival(flightStatus, flight),
        extended = false {
    if (flightStatus == FlightStatuses.accepted) {
      flightStatus = FlightStatuses.notstarted;
    }
  }

  @override
  FlightItemState createState() {
    return FlightItemState();
  }

  /// Calculates the arrival time for this flight item
  /// If this flight is still requested or not started, returns value of ETE
  static String _calculateArrival(Enum flightStatus, Flight flight) {
    var ete = flight.ete!;
    var depTime = flight.departureTime!;
    if (flightStatus == FlightStatuses.requested ||
        flightStatus == FlightStatuses.notstarted) {
      return ete.toString();
    } else if (flightStatus == FlightStatuses.completed) {
      return formattedTimeFromDateTime(flight.timings!.rotorStop);
    } else {
      String hour = depTime.split(":")[0];
      String min = depTime.split(":")[1];
      num delta = 60 * ete;

      int hourInt = (int.parse(hour) + (delta ~/ 60));
      double minInt = (int.parse(min) + (delta % 60));

      if (minInt >= 60) {
        minInt -= 60;
        hourInt += 1;
      }

      if (hourInt >= 24) hourInt -= 24;

      hour = hourInt.toString();
      min = minInt.toString().split(".")[0];

      if (min == "0") min = "00";

      return "$hour:$min";
    }
  }

  String getDeparture() {
    if (flightStatus == FlightStatuses.completed)
      return formattedTimeFromDateTime(flight.timings!.rotorStart);
    else
      return flight.departureTime!;
  }
}

class FlightItemState extends State<FlightItem> {
  UserModel pilot = UserModel("placeholder", "placeholder", "placeholder");
  final _db = DatabaseWrapper();

  @override
  void initState() {
    super.initState();
    getUser(widget.flight.user!).then((value) {
      setState(() {
        pilot = value;
      });
    });
  }

  /// Gets the contextual labels for this flight item depending on the
  /// current status
  ///
  /// Returns a map of label -> label text
  Map<String, String> _getLabelsForStatus() {
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
            "status": "ON TIME",
            "departure": "Sched. departure:",
            "arrival": "Est. arrival:",
            "eta": "ETA:"
          }.entries);
        }
      case FlightStatuses.nearlyoverdue:
        {
          return Map.fromEntries(<String, String>{
            "status": "LATE",
            "departure": "Sched. departure:",
            "arrival": "Est. arrival:",
            "eta": "ETA:"
          }.entries);
        }
      case FlightStatuses.overdue:
        {
          return Map.fromEntries(<String, String>{
            "status": "OVERDUE",
            "departure": "Sched. departure:",
            "arrival": "Est. arrival:",
            "eta": "ETA:"
          }.entries);
        }
      case FlightStatuses.completed:
        {
          return Map.fromEntries(<String, String>{
            "status": "LANDED",
            "departure": "Departure:",
            "arrival": "Arrival:",
            "eta": "Duration:"
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

  /// Returns the associate Color for each flight status
  Color _getColour() {
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
      case FlightStatuses.declined:
        {
          return Colors.grey;
        }
      case FlightStatuses.completed:
        return Colors.grey;
    }
    throw Exception("Invalid flight status");
  }

  /// Calculates the ETA value for this flight item
  /// If the flight status is requested, nothing is shown
  /// If the flight status is not started, time to departure is displayed
  /// If the flight status is completed, this should display the flight duration
  String _calculateETA() {
    DateTime currentDate = DateTime.now();
    DateTime currentTime =
        DateFormat("HH:mm").parse("${currentDate.hour}:${currentDate.minute}");
    DateTime time;

    if (widget.flightStatus == FlightStatuses.completed) {
      var timings = widget.flight.timings!;
      Duration diff = timings.rotorStop!.difference(timings.rotorStart!);
      return diff.inHours == 0
          ? "${diff.inMinutes % 60}mins"
          : "${diff.inHours}hrs ${diff.inMinutes % 60}mins";
    }

    if (widget.flightStatus == FlightStatuses.notstarted) {
      time = DateFormat("HH:mm").parse(widget.flight.departureTime!);
    } else if (widget.flightStatus == FlightStatuses.requested) {
      return "";
    } else {
      time = DateFormat("HH:mm").parse(widget._arrival);
    }
    Duration diff = time.difference(currentTime);

    if (diff.inHours == 0) {
      if (diff.inMinutes < 0 && diff.inMinutes > -8) {
        setState(() {
          widget.flightStatus = FlightStatuses.nearlyoverdue;
        });
      } else if (diff.inMinutes <= -8) {
        setState(() {
          widget.flightStatus = FlightStatuses.overdue;
        });
      }
      return "${diff.inMinutes}mins";
    } else {
      String hour = ((diff.inMinutes ~/ 60)).toString();
      String min = ((diff.inMinutes % 60)).toString().split(".")[0];
      return "${hour}hrs ${min}mins";
    }
  }

  String _getCopilotName() {
    return widget.flight.copilot ?? "N/A";
  }

  void _onRequestAccept() {
    setState(() {
      widget.flightStatus = FlightStatuses.notstarted;
    });
    _db.updateDocument(
        "requests", widget.requestID, {"status": FlightStatuses.accepted.name});
    // listen for timings
  }

  void _onRequestDecline() {
    _db.updateDocument(
        "requests", widget.requestID, {"status": FlightStatuses.declined.name});
  }

  Future<String> getCurrentLocation() async {
    CollectionReference ref = DatabaseWrapper()
        .getReferenceForDocument("flights", widget.flightID)
        .collection("gps_data");
    QuerySnapshot result =
        await ref.orderBy("time", descending: true).limit(1).get();
    if (result.docs.isEmpty) return "N/A";
    GPSData data =
        GPSData.fromMap(result.docs.first.data() as Map<String, dynamic>);
    if (kIsWeb) {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${data.lat}&lon=${data.long}&format=jsonv2'));
      final jsonData = jsonDecode(response.body);
      return jsonData["display_name"];
    } else {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(data.lat, data.long);
      return placemarks.first.thoroughfare ?? "";
    }
  }

  bool doShowLocation() {
    return widget.flightStatus != FlightStatuses.declined &&
        widget.flightStatus != FlightStatuses.notstarted &&
        widget.flightStatus != FlightStatuses.requested;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> labels = _getLabelsForStatus();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: MediaQuery.of(context).size.width >= widget.MAX_WIDTH
            ? widget.MAX_WIDTH
            : MediaQuery.of(context).size.width,
        height: widget.extended ? 180 : 100,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GestureDetector(
            onTap: () {
              setState(() {
                widget.extended = !widget.extended;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: _getColour()),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 65,
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
                                    children: [
                                      Text(widget.flight.aircraftIdentifier!)
                                    ],
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
                                    Text(
                                        "${widget.flight.departureLocation} -> ${widget.flight.destination}")
                                  ],
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            "${labels["departure"]!} ${widget.getDeparture()}")
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            "${labels["arrival"]!} ${widget._arrival}")
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
                              children: [
                                Text("${labels["eta"]!} ${_calculateETA()}"),
                                Visibility(
                                    visible: widget.flightStatus ==
                                            FlightStatuses.requested
                                        ? true
                                        : false,
                                    child: Expanded(
                                      child: Row(children: [
                                        Expanded(
                                          child: IconButton(
                                              onPressed: _onRequestAccept,
                                              iconSize: 30,
                                              icon: const Icon(Icons.check)),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                              onPressed: _onRequestDecline,
                                              iconSize: 30,
                                              icon: const Icon(Icons.close)),
                                        )
                                      ]),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.extended,
                      child: Expanded(
                          child: Column(
                        children: [
                          Row(children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text("Pilot: ${pilot.username}"),
                                  Text("Co-pilot: ${_getCopilotName()}")
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                      "Persons on board: ${widget.flight.numPersons}"),
                                  Text("Phone No.: ${pilot.phoneNumber}")
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text("Endurance: ${widget.flight.endurance}")
                                ],
                              ),
                            )
                          ]),
                          Spacer(),
                          Row(
                            children: [
                              FutureBuilder<String>(
                                  future: getCurrentLocation(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    return Visibility(
                                        visible: doShowLocation(),
                                        child: Flexible(
                                            child: Text(snapshot.data ?? "")));
                                  })
                            ],
                          )
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
