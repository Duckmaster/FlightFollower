import 'dart:collection';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/utilities/utils.dart';

/// User contacts state manager
/// This class does NOT listen for database changes, but keeps track of its own
/// state and only retrieves database state between logins!
class Contacts extends ChangeNotifier {
  final List<UserModel> _contacts = [];
  late UserModel _user;
  Future? _isReady;

  Contacts() {
    _isReady = refreshContacts();
  }

  // Gets the contacts for the current user
  UnmodifiableListView<UserModel> get contacts =>
      UnmodifiableListView(_contacts);

  Future? get isReady => _isReady;

  /// Adds [newContact] to internal contacts state and updates any listeners
  void addContact(UserModel newContact) {
    _contacts.add(newContact);
    notifyListeners();
  }

  Future<void> refreshContacts() async {
    _contacts.clear();
    Map<String, dynamic> userMap = await getObject("user_object");
    _user = UserModel.fromJson(userMap);
    await _retrieveContactsFromDatabase();
  }

  /// Get the user's contacts as stored in the database and updates _contacts
  Future<void> _retrieveContactsFromDatabase() async {
    Map<String, dynamic>? data =
        await DatabaseWrapper().getDocument("contacts", _user.email);
    if (data == null) return;
    String contactsList = data["contact_list"];
    if (contactsList.isEmpty) return;
    for (var user in contactsList.split(",")) {
      UserModel value = await getUser(user);
      if (!_contacts.contains(value)) _contacts.add(value);
      notifyListeners();
    }
  }
}
