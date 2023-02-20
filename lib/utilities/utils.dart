import 'package:shared_preferences/shared_preferences.dart';
import 'package:flight_follower/models/user.dart';
import 'dart:convert';

Future<void> storeObject(Object obj, String name) async {
  final prefs = await SharedPreferences.getInstance();
  String objString = jsonEncode(obj);
  await prefs.setString(name, objString);
}
