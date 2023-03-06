import 'package:flight_follower/models/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flights_listener.dart';

import '../models/user_model.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<Contacts>(builder: (context, value, child) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  for (UserModel user in value.items)
                    ListTile(title: Text(user.username)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
