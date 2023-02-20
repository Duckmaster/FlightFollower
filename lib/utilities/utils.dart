import 'package:shared_preferences/shared_preferences.dart';
import 'package:flight_follower/models/user.dart';
import 'dart:convert';

enum FlightStatuses { requested, notstarted, enroute, nearlyoverdue, overdue }

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
