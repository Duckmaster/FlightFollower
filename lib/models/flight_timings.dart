import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/flight.dart';

class FlightTimings {
  String? flightID;
  String? rotorStart;
  String? rotorStop;
  String? datconStart;
  String? datconStop;

  FlightTimings(
      {this.flightID,
      this.rotorStart,
      this.rotorStop,
      this.datconStart,
      this.datconStop});

  factory FlightTimings.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return FlightTimings(
        flightID: data?["flight_id"],
        rotorStart: data?["rotor_start"],
        rotorStop: data?["rotor_stop"],
        datconStart: data?["datcon_start"],
        datconStop: data?["datcon_stop"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "flight_id": flightID,
      "rotor_start": rotorStart,
      "rotor_stop": rotorStop,
      "datcon_start": datconStart,
      "datcon_stop": datconStop,
    };
  }
}
