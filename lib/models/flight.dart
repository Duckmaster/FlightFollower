class Flight {
  final String? user;
  final String? organisation;
  final String? aircraftIdentifier;
  final String? copilot;
  final String? numPersons;
  final String? departureLocation;
  final String? destination;
  final String? departureTime;
  final String? ete;
  final String? endurance;
  final String? monitoringPerson;
  final String? flightType;

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
}
