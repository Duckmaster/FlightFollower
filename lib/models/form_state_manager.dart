import 'dart:async';
import 'package:flight_follower/utilities/utils.dart';
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
  bool locationServices = false;
  StreamSubscription? listener;

  factory FormStateManager() {
    return _formStateManager;
  }

  FormStateManager._internal();

  Future<void> save() {
    Map<String, dynamic> managerMap = {
      "flight": flight.toFirestore(),
      "isSubmitted": isSubmitted,
      "flightID": flightID,
      "requestID": requestID,
      "refreshButtonVisible": refreshButtonVisible,
      "monPersonSelectEnabled": true,
      "locationServices": locationServices
    };
    return storeObject(managerMap, "form_state");
  }

  Future<void> load() async {
    Map<String, dynamic> storedMap = await getObject("form_state");
    if (storedMap.isEmpty) return;
    flight = Flight.fromMap(storedMap["flight"]);
    isSubmitted = storedMap["isSubmitted"];
    flightID = storedMap["flightID"];
    requestID = storedMap["requestID"];
    monPersonIcon = const Icon(Icons.pending);
    refreshButtonVisible = storedMap["refreshButtonVisible"];
    monPersonSelectEnabled = storedMap["monPersonSelectEnabled"];
    locationServices = storedMap["locationServices"] ?? false;

    return;
  }

  Future<FormStateManager> reset() async {
    await storeObject(Map<String, dynamic>(), "form_state");
    flight = Flight(numPersons: "1", endurance: "0.1", ete: 0.1);
    isSubmitted = false;
    flightID = "";
    requestID = "";
    monPersonIcon = const Icon(Icons.pending);
    refreshButtonVisible = false;
    monPersonSelectEnabled = true;

    return this;
  }

  /*FormStateManager()
      : flight = Flight(numPersons: "1", endurance: "0.1", ete: 0.1),
        isSubmitted = false,
        flightID = "",
        requestID = "";*/
}
