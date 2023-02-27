import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/request.dart';
import 'package:flight_follower/models/flight.dart';
import 'package:flight_follower/models/user.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:flight_follower/utilities/utils.dart';

class FlightsListener extends ChangeNotifier {
  final List<FlightItem> _flights = [];
  late User _user;

  FlightsListener() {
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = User.fromJson(userMap);
      initListener();
    });
  }

  UnmodifiableListView<FlightItem> get items => UnmodifiableListView(_flights);

  void initListener() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requests")
        .withConverter(
            fromFirestore: Request.fromFirestore,
            toFirestore: (Request request, _) => request.toFirestore())
        .where("user_id", isEqualTo: _user.email)
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
          Flight flight = value.data()!;
          FlightItem newFlightItem =
              FlightItem(flight, request.status, change.doc.id);
          // need to fix this; equality testing between flight objects
          FlightItem? oldFlightItem = _flights.singleWhere(
            (f) => f.flight == flight,
            orElse: () => FlightItem(flight, FlightStatuses.declined, ""),
          );

          switch (change.type) {
            case DocumentChangeType.added:
              if (newFlightItem.flightStatus != FlightStatuses.declined) {
                _flights.add(newFlightItem);
              }

              notifyListeners();
              break;
            case DocumentChangeType.modified:
              if (oldFlightItem.requestID != "") {
                _flights.remove(oldFlightItem);
              }

              if (newFlightItem.flightStatus != FlightStatuses.declined) {
                _flights.add(newFlightItem);
              }
              notifyListeners();

              break;
            case DocumentChangeType.removed:
              break;
          }
        });
      }
    });
  }

  FlightItem getFlightItemByFlight(Flight toFind) {
    return _flights.singleWhere((flight) => flight.flight == toFind);
  }
}