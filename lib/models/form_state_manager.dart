import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flight.dart';

/// Persistence for FlightLogForm state, allows us to keep the form populated
/// between page switches
class FormStateManager {
  static final FormStateManager _formStateManager =
      FormStateManager._internal();
  Flight flight = Flight(numPersons: "1", endurance: "0.1", ete: 0.1);
  bool isSubmitted = false;
  String flightID = "";
  String requestID = "";
  Icon monPersonIcon = const Icon(Icons.pending);
  bool refreshButtonVisible = false;
  bool monPersonSelectEnabled = true;
  StreamSubscription? listener;

  factory FormStateManager() {
    return _formStateManager;
  }

  FormStateManager._internal();

  /*FormStateManager()
      : flight = Flight(numPersons: "1", endurance: "0.1", ete: 0.1),
        isSubmitted = false,
        flightID = "",
        requestID = "";*/
}
