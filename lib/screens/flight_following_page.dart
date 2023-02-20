import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';

enum FlightStatuses { requested, notstarted, enroute, nearlyoverdue, overdue }

class FlightFollowingPage extends StatefulWidget {
  const FlightFollowingPage({super.key});

  @override
  FlightFollowingPageState createState() {
    return FlightFollowingPageState();
  }
}

class FlightFollowingPageState extends State<FlightFollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          FlightItem(FlightStatuses.nearlyoverdue, "G-AAAA", "Blackpool",
              "Blackpool", "23:00", 2, "John Smith", 3, "07123456789", 2.5),
          FlightItem(FlightStatuses.notstarted, "G-AAAA", "Blackpool",
              "Blackpool", "23:58", 0.5, "John Smith", 3, "07123456789", 2.5),
        ],
      ),
    );
  }
}
