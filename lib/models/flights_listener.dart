import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/request.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:flight_follower/utilities/utils.dart';

/// Handles the persistence and updating of the flights the user is monitoring
/// This class is responsible for storing monitored flights, and listening to
/// changes from the database when new flights are added or existing flights updated
class FlightsListener extends ChangeNotifier {
  final List<FlightItem> _flights = [];
  late UserModel _user;
  StreamSubscription? listener;
  bool _isListenerCancelled = false;

  FlightsListener() {
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = UserModel.fromJson(userMap);
      initListener();
    });
  }

  bool get isListenerCancelled => _isListenerCancelled;

  /// Returns an immutable list of flights this FlightListener is currently storing
  UnmodifiableListView<FlightItem> get flights =>
      UnmodifiableListView(_flights);

  /// Initialise this FlightListener's subscription to the database and callback
  void initListener() {
    _isListenerCancelled = false;
    FirebaseFirestore db = FirebaseFirestore.instance;
    listener = db
        .collection("requests")
        .withConverter(
            fromFirestore: Request.fromFirestore,
            toFirestore: (Request request, _) => request.toFirestore())
        .where("user_id", isEqualTo: _user.email)
        .where("timestamp", isGreaterThan: getCutoffDateTime())
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        Request request = change.doc.data()!;
        db
            .collection("flights")
            .doc(request.flightID)
            .withConverter(
                fromFirestore: Flight.fromFirestore,
                toFirestore: (Flight flight, _) => flight.toFirestore())
            .get()
            .then((value) {
          if (!value.exists) return;
          Flight flight = value.data()!;
          // Construct a FlightItem instance for the flight with the new status
          FlightItem newFlightItem =
              FlightItem(flight, request.status, change.doc.id);
          // Find the old FlightItem in_flights for the updated flight
          FlightItem? oldFlightItem = _flights.singleWhere(
            (f) => f.flight == flight,
            orElse: () => FlightItem(flight, FlightStatuses.declined, ""),
          );

          switch (change.type) {
            case DocumentChangeType.added:
              // We have a new request (new flight) so add the flight
              if (newFlightItem.flightStatus != FlightStatuses.declined) {
                _flights.add(newFlightItem);
              }

              notifyListeners();
              break;
            case DocumentChangeType.modified:
              // Status has been updated, so remove the old flight from the list and add the new one

              // Check to make sure the old flight exists in _flight
              // (if the earlier singleWhere fails, orElse func creates a Request with empty requestID)
              if (oldFlightItem.requestID != "") {
                _flights.remove(oldFlightItem);
              }

              if (newFlightItem.flightStatus != FlightStatuses.declined) {
                _flights.add(newFlightItem);
              }
              notifyListeners();

              break;
            case DocumentChangeType.removed:
              // We dont remove data so do nothing
              break;
          }
        });
      }
    });
  }

  /// Cancel the listener maintained by this instance and mark our internal state as such
  Future<void> cancelListener() async {
    await listener!.cancel();
    _isListenerCancelled = true;
  }
}
