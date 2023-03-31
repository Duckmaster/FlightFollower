import 'package:flight_follower/models/flights_listener.dart';
import 'package:flight_follower/models/login_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  void logout(BuildContext context) {
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    FlightsListener flightsListener =
        Provider.of<FlightsListener>(context, listen: false);
    flightsListener.listener?.cancel().then((value) => manager.logoutUser());
  }

  void downloadFlights() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
              child: Consumer<LoginManager>(builder: (context, value, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: value.currentUserModel.username,
                    decoration: InputDecoration(labelText: "Name"),
                    enabled: false,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: value.currentUserModel.phoneNumber,
                    decoration: InputDecoration(labelText: "Phone No."),
                    enabled: false,
                  ),
                ),
              ],
            );
          })),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: () => downloadFlights(),
                    child: Text("Download recent flights")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
