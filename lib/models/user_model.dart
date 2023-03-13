import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final String phoneNumber;

  UserModel(this.username, this.email, this.phoneNumber);

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    return UserModel(
        parsedJson['username'], parsedJson['email'], parsedJson['phoneNumber']);
  }

  Map<String, dynamic> toJson() {
    return {"username": username, "email": email, "phoneNumber": phoneNumber};
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(data?["username"], data?["email"], data?["phoneNumber"]);
  }

  Map<String, dynamic> toFirestore() => toJson();
}
