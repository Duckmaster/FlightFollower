import 'package:flight_follower/models/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flights_listener.dart';

import '../models/user_model.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  void addContactDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => SimpleDialog(
              title: Text("Add New Contact"),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                            label: Text("Email address/phone number:")),
                      ),
                      ElevatedButton(
                          onPressed: () => addContact(controller.text),
                          child: Text("Add"))
                    ],
                  ),
                ),
              ],
            ));
  }

  void addContact(String value) {
    print(value);
  }

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
