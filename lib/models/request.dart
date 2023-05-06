import 'package:flight_follower/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A Request submitted from one user for another to monitor their flight
class Request {
  final Timestamp? timestamp;
  final String flightID;
  final String userID;
  final FlightStatuses status;

  Request(this.flightID, this.userID, this.status, {this.timestamp});

  factory Request.fromMap(
    Map<String, dynamic> data,
  ) {
    return Request(data["flight_id"], data["user_id"],
        FlightStatuses.values.byName(data["status"]),
        timestamp: data["timestamp"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "timestamp": FieldValue.serverTimestamp(),
      "flight_id": flightID,
      "user_id": userID,
      "status": status.name
    };
  }
}
