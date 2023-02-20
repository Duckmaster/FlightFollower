import 'package:flight_follower/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String flightID;
  final String userID;
  final FlightStatuses status;

  Request(this.flightID, this.userID, this.status);

  factory Request.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Request(data?["flight_id"], data?["user_id"],
        FlightStatuses.values.byName(data?["status"]));
  }

  Map<String, dynamic> toFirestore() {
    return {"flight_id": flightID, "user_id": userID, "status": status.name};
  }
}
