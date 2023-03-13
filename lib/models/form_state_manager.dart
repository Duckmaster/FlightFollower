import 'package:flight_follower/models/flight_timings.dart';
import 'package:flutter/cupertino.dart';

import 'flight.dart';

class FormStateManager extends ChangeNotifier {
  Flight flight;
  FlightTimings timings;
  FormStateManager()
      : flight = Flight(),
        timings = FlightTimings();
}
