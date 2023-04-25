import 'package:flight_follower/models/flight_timings.dart';
import 'package:flutter/cupertino.dart';

import 'flight.dart';

/// Persistence for FlightLogForm state, allows us to keep the form populated
/// between page switches
class FormStateManager extends ChangeNotifier {
  Flight flight;
  FlightTimings timings;
  bool isSubmitted;
  String flightID;
  String requestID;
  FormStateManager()
      : flight = Flight(numPersons: "1", endurance: "0.1", ete: 0.1),
        timings = FlightTimings(),
        isSubmitted = false,
        flightID = "",
        requestID = "";
}
