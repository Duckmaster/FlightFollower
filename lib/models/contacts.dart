import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/utilities/utils.dart';

/// User contacts state manager
/// This class does NOT listen for database changes, but keeps track of its own
/// state and only retrieves database state between logins!
class Contacts extends ChangeNotifier {
  final List<UserModel> _contacts = [];
  late UserModel _user;

  Contacts() {
    refreshContacts();
  }

  // Gets the contacts for the current user
  UnmodifiableListView<UserModel> get contacts =>
      UnmodifiableListView(_contacts);

  /// Adds [newContact] to internal contacts state and updates any listeners
  void addContact(UserModel newContact) {
    _contacts.add(newContact);
    notifyListeners();
  }

  void refreshContacts() {
    _contacts.clear();
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = UserModel.fromJson(userMap);
      _retrieveContactsFromDatabase();
    });
  }

  /// Get the user's contacts as stored in the database and updates _contacts
  void _retrieveContactsFromDatabase() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("contacts").doc(_user.email).get().then((docSnapshot) {
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data() as Map<String, dynamic>;
      String contactsList = data["contact_list"];
      if (contactsList.isEmpty) return;
      for (var user in contactsList.split(",")) {
        getUser(user).then((value) {
          if (!_contacts.contains(value)) _contacts.add(value);
          notifyListeners();
        });
      }
    });
  }
}
