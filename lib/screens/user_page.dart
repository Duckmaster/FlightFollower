import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:flight_follower/models/flights_listener.dart';
import 'package:flight_follower/models/login_manager.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  void logout(BuildContext context) {
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    FlightsListener flightsListener =
        Provider.of<FlightsListener>(context, listen: false);
    // We have to cancel this listener on logout (then start it on login) as
    // the active subscription causes havoc with Firestore access perms when no
    // user is signed in
    flightsListener.cancelListener().then((value) => manager.logoutUser());
  }

  /// Fetches all Flights and their FlightTimings for the logged in user
  Future<List<Flight>> _retrieveAllFlightData(User currentUser) async {
    List<Flight> flights = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    var flightSnapshot = await db
        .collection("flights")
        .withConverter(
            fromFirestore: Flight.fromFirestore,
            toFirestore: (Flight flight, _) => flight.toFirestore())
        .where("user", isEqualTo: currentUser.email)
        .get();
    if (flightSnapshot.size == 0) {
      return flights;
    }

    for (var doc in flightSnapshot.docs) {
      flights.add(doc.data());
    }

    return flights;
  }

  /// Download the flight data for the logged in user
  void downloadFlights(BuildContext context) async {
    // Let the user pick the directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    List<Flight> flights = await _retrieveAllFlightData(manager.currentUser!);
    // We will put our csv formatted lines in here
    // Init list with the header and remove any \n created by multiline string
    // (it looks nicer than one long line)
    List<String> flightsTransformed = [
      """Flight ID, Organisation, Aircraft Ident, Copilot,
      Num. Persons, Departure, Destination, Scheduled Departure,
      Datcon Start, Rotor Start, Scheduled Arrival,
      Rotor Stop, Datcon Stop, ETE, Fuel Endurance,
      Flight Type"""
          .replaceAll("\n", "")
    ];

    DateTime now = DateTime.now();
    String date = now.toString().split(" ")[0];

    for (var flight in flights) {
      // Calculate sched. arrival adhoc because I dont save it anywhere
      String scheduledArrival = DateTime.parse("$date ${flight.departureTime}")
          .add(Duration(minutes: (flight.ete! * 60).toInt()))
          .toString()
          .split(" ")[1];
      // Create a map of values then join with comma to create a string
      flightsTransformed.add({
        // TODO: Decide if this is necessary
        //"flight_id": flight.timings!.flightID,
        "organisation": flight.organisation ?? "N/A",
        "aircraft_ident": flight.aircraftIdentifier!,
        "copilot": flight.copilot ?? "N/A",
        "num_persons": flight.numPersons!,
        "departure_location": flight.departureLocation!,
        "destination": flight.destination!,
        "scheduled_departure": flight.departureTime!,
        "datcon_start": flight.timings!.datconStart!,
        "rotor_start": flight.timings!.rotorStart.toString(),
        "scheduled_arrival": scheduledArrival,
        "rotor_stop": flight.timings!.rotorStop.toString(),
        "datcon_stop": flight.timings!.datconStop.toString(),
        "ete": flight.ete.toString(),
        "endurance": flight.endurance!,
        "flight_type": flight.flightType!
      }.values.join(","));
    }
    //String flightsJSON = jsonEncode({"flights": flightsTransformed});

    // Once we've formatted everything, write our list to a file (joined by newline and carriage returns)
    await File("$selectedDirectory/flights.csv")
        .writeAsString(flightsTransformed.join("\r\n"));

    showSnackBar(
        context, "Saved flight information to $selectedDirectory/flights.csv!");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
              child: Consumer<LoginManager>(builder: (context, value, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: value.currentUserModel.username,
                    decoration: InputDecoration(labelText: "Name"),
                    enabled: false,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: value.currentUserModel.phoneNumber,
                    decoration: InputDecoration(labelText: "Phone No."),
                    enabled: false,
                  ),
                ),
              ],
            );
          })),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: () => downloadFlights(context),
                    child: Text("Download flights")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
