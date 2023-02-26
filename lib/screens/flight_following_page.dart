import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/models/user.dart';
import 'package:flight_follower/models/request.dart';
import 'package:flight_follower/models/flight.dart';

class FlightFollowingPage extends StatefulWidget {
  const FlightFollowingPage({super.key});

  @override
  FlightFollowingPageState createState() {
    return FlightFollowingPageState();
  }
}

class FlightFollowingPageState extends State<FlightFollowingPage> {
  var flights = []; // this needs storing into shared prefs probably
  late User user;

  @override
  void initState() {
    super.initState();
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      setState(() {
        user = User.fromJson(userMap);
      });

      listenFlightRequests();
    });
  }

  void listenFlightRequests() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requests")
        .withConverter(
            fromFirestore: Request.fromFirestore,
            toFirestore: (Request request, _) => request.toFirestore())
        .where("user_id", isEqualTo: user.email)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        Request request = change.doc.data()!;
        switch (change.type) {
          case DocumentChangeType.added:
            db
                .collection("flights")
                .doc(request.flightID)
                .withConverter(
                    fromFirestore: Flight.fromFirestore,
                    toFirestore: (Flight flight, _) => flight.toFirestore())
                .get()
                .then((value) {
              Flight flight = value.data()!;
              FlightItem flightItem = FlightItem(flight, request.status);
              setState(() {
                flights.add(flightItem);
              });
            });
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [for (FlightItem flightItem in flights) flightItem],
      ),
    );
  }
}
