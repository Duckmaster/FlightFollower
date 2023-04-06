import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:flight_follower/models/user_model.dart';

class FlightItem extends StatefulWidget {
  final Flight flight;
  final String requestID;
  Enum flightStatus;
  final String _arrival;

  bool extended;

  FlightItem(
    this.flight,
    this.flightStatus,
    this.requestID, {
    super.key,
  })  : _arrival =
            _calculateArrival(flightStatus, flight.ete!, flight.departureTime!),
        extended = false {
    if (flightStatus == FlightStatuses.accepted) {
      flightStatus = FlightStatuses.notstarted;
    }
  }

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
}

class FlightItemState extends State<FlightItem> {
  UserModel pilot = UserModel("placeholder", "placeholder", "placeholder");

  @override
  void initState() {
    super.initState();
    getUser(widget.flight.user!).then((value) {
      setState(() {
        pilot = value;
      });
    });
  }

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
      case FlightStatuses.completed:
        {
          return Map.fromEntries(<String, String>{
            "status": "LANDED",
            "departure": "Departure:",
            "arrival": "Arrival:",
            "eta": ""
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
      case FlightStatuses.declined:
        {
          return Colors.grey;
        }
      case FlightStatuses.completed:
        return Colors.grey;
    }
    throw Exception("Invalid flight status");
  }

  String calculateETA() {
    DateTime currentDate = DateTime.now();
    DateTime currentTime =
        DateFormat("HH:mm").parse("${currentDate.hour}:${currentDate.minute}");
    DateTime time;

    if (widget.flightStatus == FlightStatuses.completed) {
      return "";
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
      return "${diff.inMinutes}mins";
    } else {
      String hour = ((diff.inMinutes ~/ 60)).toString();
      String min = ((diff.inMinutes % 60)).toString().split(".")[0];
      return "${hour}hrs ${min}mins";
    }
  }

  String getCopilotName() {
    return widget.flight.copilot ?? "N/A";
  }

  void onAccept() {
    setState(() {
      widget.flightStatus = FlightStatuses.notstarted;
    });
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requests")
        .doc(widget.requestID)
        .update({"status": FlightStatuses.accepted.name});
    // listen for timings
  }

  void onDecline() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requests")
        .doc(widget.requestID)
        .update({"status": FlightStatuses.declined.name});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> labels = getLabelsForStatus();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: widget.extended ? 175 : 100,
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
                color: getColour()),
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
                                          "${labels["departure"]!} ${widget.flight.departureTime}")
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
                              Text("${labels["eta"]!} ${calculateETA()}"),
                              Visibility(
                                  visible: widget.flightStatus ==
                                          FlightStatuses.requested
                                      ? true
                                      : false,
                                  child: Expanded(
                                    child: Row(children: [
                                      Expanded(
                                        child: IconButton(
                                            onPressed: onAccept,
                                            iconSize: 30,
                                            icon: const Icon(Icons.check)),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                            onPressed: onDecline,
                                            iconSize: 30,
                                            icon: const Icon(Icons.close)),
                                      )
                                    ]),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.extended,
                    child: Expanded(
                        child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text("Pilot: ${pilot.username}"),
                              Text("Co-pilot: ${getCopilotName()}")
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
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
