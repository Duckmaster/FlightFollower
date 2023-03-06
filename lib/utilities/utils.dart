import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flight_follower/models/user_model.dart';
import 'dart:convert';

enum FlightStatuses {
  requested,
  notstarted,
  enroute,
  nearlyoverdue,
  overdue,
  declined,
  accepted,
  completed
}

Future<void> storeObject(Object obj, String name) async {
  final prefs = await SharedPreferences.getInstance();
  String objString = jsonEncode(obj);
  await prefs.setString(name, objString);
}

Future<Map<String, dynamic>> getObject(String name) async {
  final prefs = await SharedPreferences.getInstance();
  String? objString = prefs.getString(name);
  if (objString == null) {
    throw Exception('"$name" not found in shared preferences');
  }
  return jsonDecode(objString);
}

// retrieves user data from db
Future<UserModel> getUser(String userID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  db.collection("users").doc(userID).get().then((docSnapshot) {
    final data = docSnapshot.data() as String;
    return UserModel.fromJson(jsonDecode(data));
  });
  return UserModel("", "", "");
}
