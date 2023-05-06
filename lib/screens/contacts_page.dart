import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/models/contacts.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';

class ContactsPage extends StatelessWidget {
  late UserModel _user;
  final _db = DatabaseWrapper();
  ContactsPage({super.key}) {
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = UserModel.fromJson(userMap);
    });
  }

  void dialogAddNewContact(BuildContext context) {
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
                          onPressed: () =>
                              _addContact(controller.text, context),
                          child: Text("Add"))
                    ],
                  ),
                ),
              ],
            ));
  }

  /// Add [value] as a new contact for this user
  /// [value] can be either email or phone number, this method checks formatting
  /// using regex
  void _addContact(String value, BuildContext context) {
    var contacts = Provider.of<Contacts>(context, listen: false);
    var contactsCopy = contacts.contacts.toList();

    value = value.trimLeft().trimRight();

    // regex to match either email or phone no, then query db
    RegExp emailRegex = RegExp(r"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
    RegExp phoneRegex = RegExp("[0-9]{11}");

    String message;
    UserModel match = UserModel("", "", "");

    if (emailRegex.hasMatch(value)) {
      // query db for email
      getUser(value).then((foundUser) {
        match = foundUser;
        if (match.email != "") {
          contactsCopy.add(match);
          contacts.addContact(match);
          _storeContacts(contactsCopy);
          showSnackBar(context, "Contact successfully added!");
        } else {
          showSnackBar(context,
              "Email address provided does not belong to a registered user");
        }
      });
    } else if (phoneRegex.hasMatch(value)) {
      // query db for phone number
      _db.getDocumentsWhere("users", [
        ["phoneNumber", "==", value]
      ]).then((docs) {
        if (docs.isEmpty) return;
        match = UserModel.fromJson(docs.first);

        if (match.email != "") {
          contactsCopy.add(match);
          contacts.addContact(match);
          _storeContacts(contactsCopy);
          showSnackBar(context, "Contact successfully added!");
        } else {
          showSnackBar(context,
              "Phone number provided does not belong to a registered user");
        }
      });
    } else {
      // not valid phone number/email
      showSnackBar(context,
          "Please make sure the email address/phone number provided is valid and try again");
      return;
    }
  }

  /// Updates this users contacts in the database with [contactList]
  void _storeContacts(List<UserModel> contactList) {
    _db.addDocumentWithID("contacts", _user.email, <String, dynamic>{
      "contact_list": contactList.map((e) => e.email).join(",")
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<Contacts>(builder: (context, value, child) {
            return ListView(
              children: [
                for (UserModel user in value.contacts)
                  ListTile(title: Text(user.username)),
              ],
            );
          }),
        )),
      ],
    );
  }
}
