import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/flight.dart';

class FlightTimings {
  String? flightID;
  DateTime? rotorStart;
  DateTime? rotorStop;
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
        rotorStart: DateTime.parse(data?["rotor_start"]),
        rotorStop: DateTime.parse(data?["rotor_stop"]),
        datconStart: data?["datcon_start"],
        datconStop: data?["datcon_stop"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "flight_id": flightID,
      "rotor_start": rotorStart.toString(),
      "rotor_stop": rotorStop.toString(),
      "datcon_start": datconStart,
      "datcon_stop": datconStop,
    };
  }
}
