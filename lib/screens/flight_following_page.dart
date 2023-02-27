import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flights_listener.dart';

class FlightFollowingPage extends StatelessWidget {
  const FlightFollowingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<FlightsListener>(builder: (context, value, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [for (FlightItem flightItem in value.items) flightItem],
        ),
      );
    });
  }
}
