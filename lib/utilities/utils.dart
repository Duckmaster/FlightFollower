import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  return db.collection("users").doc(userID).get().then((docSnapshot) {
    if (!docSnapshot.exists) return UserModel("", "", "");
    final data = docSnapshot.data();
    return UserModel.fromJson(data!);
  });
}

void showSnackBar(BuildContext context, String message) {
  SnackBar snackBar;
  switch (message) {
    case "email-already-in-use":
      snackBar =
          SnackBar(content: Text("An account with that email already exists."));
      break;
    case "invalid-email":
      snackBar = SnackBar(
          content: Text(
              "The email address provided is not valid. Please try again."));
      break;
    case "user-disabled":
      snackBar = SnackBar(
          content: Text(
              "The account associated with this email has been disabled."));
      break;
    case "user-not-found":
      snackBar = SnackBar(
          content: Text(
              "An account matching the given email address could not be found. Please check the email address is correct, or register an account."));
      break;
    case "wrong-password":
      snackBar =
          SnackBar(content: Text("Incorrect password, please try again."));
      break;
    default:
      snackBar = SnackBar(content: Text(message));
      break;
  }
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
