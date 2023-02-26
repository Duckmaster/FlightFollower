import 'package:cloud_firestore/cloud_firestore.dart';

class Flight {
  String? user;
  String? organisation;
  String? aircraftIdentifier;
  String? copilot;
  String? numPersons;
  String? departureLocation;
  String? destination;
  String? departureTime;
  double? ete;
  String? endurance;
  String? monitoringPerson;
  String? flightType;

  Flight(
      {this.user,
      this.organisation,
      this.aircraftIdentifier,
      this.numPersons,
      this.departureLocation,
      this.destination,
      this.departureTime,
      this.ete,
      this.endurance,
      this.monitoringPerson,
      this.flightType,
      this.copilot});

  factory Flight.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Flight(
      user: data?["user"],
      organisation: data?["organisation"],
      aircraftIdentifier: data?["aircraft_ident"],
      copilot: data?["copilot"],
      numPersons: data?["num_persons"],
      departureLocation: data?["departure"],
      destination: data?["destination"],
      departureTime: data?["departure_time"],
      ete: data?["ete"],
      endurance: data?["endurance"],
      monitoringPerson: data?["monitoring_person"],
      flightType: data?["flight_type"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "user": user,
      "organisation": organisation,
      "aircraft_ident": aircraftIdentifier,
      "copilot": copilot,
      "num_persons": numPersons,
      "departure": departureLocation,
      "destination": destination,
      "departure_time": departureTime,
      "ete": ete,
      "endurance": endurance,
      "monitoring_person": monitoringPerson,
      "flight_type": flightType
    };
  }
}
