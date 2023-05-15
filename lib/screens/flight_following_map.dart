import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/utilities/gps_manager.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flight_follower/widgets/flight_map.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flights_listener.dart';
import 'package:flight_follower/utilities/database_api.dart';

class FlightFollowingMap extends StatefulWidget {
  Function? refreshCallback;
  FlightFollowingMap({super.key});

  void refresh() {
    refreshCallback!();
  }

  @override
  State<FlightFollowingMap> createState() => _FlightFollowingMapState();
}

class _FlightFollowingMapState extends State<FlightFollowingMap> {
  Future<Map<FlightItem, GPSData>>? _getData;

  Future<Map<FlightItem, GPSData>> getAllGPSData(
      List<FlightItem> flights) async {
    Map<FlightItem, GPSData> map = {};
    for (FlightItem flight in flights) {
      if (flight.flightStatus == FlightStatuses.requested) continue;
      CollectionReference ref = DatabaseWrapper()
          .getReferenceForDocument("flights", flight.flightID)
          .collection("gps_data");
      QuerySnapshot result =
          await ref.orderBy("time", descending: true).limit(1).get();
      if (result.docs.isEmpty) continue;
      GPSData data =
          GPSData.fromMap(result.docs.first.data() as Map<String, dynamic>);

      map.addAll({flight: data});
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    widget.refreshCallback = refresh;
    var flights = Provider.of<FlightsListener>(context, listen: false).flights;
    _getData = getAllGPSData(flights);
  }

  void refresh() {
    setState(() {
      var flights =
          Provider.of<FlightsListener>(context, listen: false).flights;
      _getData = getAllGPSData(flights);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<FlightsListener>(builder: (context, value, child) {
          // Restarts the listener if it was cancelled between user sessions
          if (value.isListenerCancelled) {
            value.initListener();
          }
          return FutureBuilder<Map<FlightItem, GPSData>>(
              future: _getData,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<FlightItem, GPSData>> snapshot) {
                return Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width,
                      child: FlightMap(snapshot.hasData
                          ? snapshot.data!.values.toList()
                          : []),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (FlightItem flightItem in value.flights)
                            flightItem
                        ],
                      ),
                    )
                  ],
                );
              });
        }));
  }
}
