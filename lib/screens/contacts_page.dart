import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
                          onPressed: () => addContact(controller.text, context),
                          child: Text("Add"))
                    ],
                  ),
                ),
              ],
            ));
  }

  void addContact(String value, BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // regex to match either email or phone no, then query db
    //db.collection("users").where("email", isEqualTo: )

    RegExp emailRegex = RegExp(r"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
    RegExp phoneRegex = RegExp("[0-9]{11}");

    String message;
    UserModel match;

    if (emailRegex.hasMatch(value)) {
      // query db for email
    } else if (phoneRegex.hasMatch(value)) {
      // query db for phone
    } else {
      // not valid phone number/email
    }
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
