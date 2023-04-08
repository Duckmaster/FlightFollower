import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores information relating to one singular flight
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
      this.copilot}) {
    _prefixDepartureWithNaught();
  }

  /// Adds a "0" onto the beginning of hour and minute components of this flight's
  /// departure time
  /// E.g. 3:5 -> 03:05
  void _prefixDepartureWithNaught() {
    if (departureTime == null) return;
    var parts = departureTime!.split(":");
    if (parts[0].length == 1) {
      parts[0] = "0${parts[0]}";
    }

    if (parts[1].length == 1) {
      parts[1] = "0${parts[1]}";
    }

    departureTime = parts.join(":");
  }

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

  @override
  bool operator ==(Object other) {
    // For our purposes, we define equality for flights to be those which have the
    // same identifier and departure time
    // In future, this will be replaced by flight IDs, or equivalent
    if (other is! Flight) {
      return false;
    }
    return (other.aircraftIdentifier == aircraftIdentifier &&
        other.departureTime == departureTime);
  }

  @override
  int get hashCode => Object.hash(aircraftIdentifier, departureTime);
}
