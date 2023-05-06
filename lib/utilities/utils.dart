import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flight_follower/models/user_model.dart';
import 'dart:convert';

/// Set of various statuses a flight can take
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

/// Stores [obj] into shared preferences as [name]
///
/// Returns a Future which completes once [obj] has been stored
Future<void> storeObject(Object obj, String name) async {
  final prefs = await SharedPreferences.getInstance();
  String objString = jsonEncode(obj);
  await prefs.setString(name, objString);
}

/// Retrieves an object with [name] from shared preferences
///
/// Returns a Future which completes to give a map of [name] and the
/// corresponding object. Throws if [name] is not found in shared preferences.
Future<Map<String, dynamic>> getObject(String name) async {
  final prefs = await SharedPreferences.getInstance();
  String? objString = prefs.getString(name);
  if (objString == null) {
    throw Exception('"$name" not found in shared preferences');
  }
  return jsonDecode(objString);
}

/// Gets the user information for [userID] from the database
///
/// Returns a Future that completes to give a UserModel object containing
/// [userID]'s informations. If [userID] is not found in the database,
/// a UserObject with empty strings is returned.
Future<UserModel> getUser(String userID) async {
  return DatabaseWrapper().getDocument("users", userID).then((data) {
    if (data == null) return UserModel("", "", "");
    return UserModel.fromJson(data);
  });
}

/// Uses [context] to show a [message] to the user as a snackbar.
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

/// Returns the time component of [dateTime] as a String
String formattedTimeFromDateTime(DateTime? dateTime) {
  if (dateTime == null) return "";
  String time = dateTime.toString().split(" ")[1].split(".")[0];
  List<String> parts = time.split(":");
  return "${parts[0]}:${parts[1]}";
}

/// Calculates a [DateTime] for retrieving only today's
/// flights (i.e. after 3am of that day) from the database
DateTime getCutoffDateTime() {
  DateTime now = DateTime.now();
  String date = now.toString().split(" ")[0];
  DateTime cutoff = DateTime.parse("$date 03:00");

  // After midnight, but before the next 3am cutoff
  if (now.isBefore(cutoff)) {
    cutoff.subtract(Duration(days: 1));
  }
  return cutoff;
}
