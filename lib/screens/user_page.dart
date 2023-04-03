import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:flight_follower/models/flight_timings.dart';
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
    flightsListener.listener?.cancel().then((value) => manager.logoutUser());
  }

  Future<List<Map<Flight, FlightTimings>>> retrieveAllFlightData(
      User currentUser) async {
    List<Map<Flight, FlightTimings>> flights = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    var smth = await db
        .collection("flights")
        .withConverter(
            fromFirestore: Flight.fromFirestore,
            toFirestore: (Flight flight, _) => flight.toFirestore())
        .where("user", isEqualTo: currentUser.email)
        .get();
    if (smth.size == 0) {
      return flights;
    }
    List<String> flightIDs = smth.docs.map((e) => e.id).toList();
    var anotherSmth = await db
        .collection("timings")
        .withConverter(
            fromFirestore: FlightTimings.fromFirestore,
            toFirestore: (FlightTimings timings, _) => timings.toFirestore())
        .where("flight_id", whereIn: flightIDs)
        .get();

    for (int i = 0; i < smth.size; i++) {
      flights.add({smth.docs[i].data(): anotherSmth.docs[i].data()});
    }
    return flights;
  }

  void downloadFlights(BuildContext context) async {
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    List<Map<Flight, FlightTimings>> flights =
        await retrieveAllFlightData(manager.currentUser!);
    List<Map<String, Map<String, String>>> flightsTransformed = [];
    for (var pair in flights) {
      Flight flight = pair.keys.first;
      FlightTimings timings = pair.values.first;

      DateTime now = DateTime.now();
      String date = now.toString().split(" ")[0];
      String scheduledArrival = DateTime.parse("$date ${flight.departureTime}")
          .add(Duration(minutes: (flight.ete! * 60).toInt()))
          .toString()
          .split(" ")[1];
      flightsTransformed.add({
        timings.flightID!: {
          "organisation": flight.organisation ?? "N/A",
          "aircraft_ident": flight.aircraftIdentifier!,
          "copilot": flight.copilot ?? "N/A",
          "num_persons": flight.numPersons!,
          "departure_location": flight.departureLocation!,
          "destination": flight.destination!,
          "scheduled_departure": flight.departureTime!,
          "datcon_start": timings.datconStart!,
          "rotor_start": timings.rotorStart.toString(),
          "scheduled_arrival": scheduledArrival,
          "rotor_stop": timings.rotorStop.toString(),
          "datcon_stop": timings.datconStop.toString(),
          "ete": flight.ete.toString(),
          "endurance": flight.endurance!,
          "flight_type": flight.flightType!
        }
      });
    }
    String flightsJSON = jsonEncode({"flights": flightsTransformed});
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
                    child: Text("Download recent flights")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
