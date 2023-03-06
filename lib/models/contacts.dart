import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flight_follower/utilities/utils.dart';

class Contacts extends ChangeNotifier {
  final List<UserModel> _contacts = [];
  late UserModel _user;

  Contacts() {
    getObject("user_object").then((result) {
      Map<String, dynamic> userMap = result;
      _user = UserModel.fromJson(userMap);
      retrieveContactsFromDatabase();
    });
  }

  UnmodifiableListView<UserModel> get items => UnmodifiableListView(_contacts);

  void retrieveContactsFromDatabase() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("contacts").doc(_user.email).get().then((docSnapshot) {
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data() as Map<String, dynamic>;
      String contactsList = data["contact_list"];
      for (var user in contactsList.split(",")) {
        getUser(user).then((value) => _contacts.add(value));
      }
    });
    notifyListeners();
  }
}
