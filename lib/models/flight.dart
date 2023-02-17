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
  String? ete;
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
