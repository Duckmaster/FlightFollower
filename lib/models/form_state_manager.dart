import 'package:flight_follower/models/flight_timings.dart';
import 'package:flutter/cupertino.dart';

import 'flight.dart';

class FormStateManager extends ChangeNotifier {
  Flight flight;
  FlightTimings timings;
  bool isSubmitted;
  FormStateManager()
      : flight = Flight(),
        timings = FlightTimings(),
        isSubmitted = false;
}
