import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/contacts.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:provider/provider.dart';
import 'package:flight_follower/models/flights_listener.dart';

import '../models/user_model.dart';

class ContactsPage extends StatelessWidget {
  late UserModel _user;
  ContactsPage({super.key}) {
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = UserModel.fromJson(userMap);
    });
  }

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
    UserModel match = UserModel("", "", "");

    if (emailRegex.hasMatch(value)) {
      // query db for email
      getUser(value).then((value) => match = value);
    } else if (phoneRegex.hasMatch(value)) {
      db
          .collection("users")
          .where("phoneNumber", isEqualTo: value)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data() as String;
          match = UserModel.fromJson(jsonDecode(data));
        }
      });
    } else {
      // not valid phone number/email
      print("not valid");
      return;
    }

    var contactsCopy =
        Provider.of<Contacts>(context, listen: false).items.toList();
    contactsCopy.add(match);
    db.collection("contacts").doc(_user.email).set(<String, dynamic>{
      "contact_list": contactsCopy.map((e) => e.email).join(",")
    });
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