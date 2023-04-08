import 'package:cloud_firestore/cloud_firestore.dart';

/// User information model
/// This is necessary as Firebase Auth's own User class doesnt allow for
/// storage of any other info, and we require a user's phone number within this app.
/// So, this class is used to save database reads
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

  @override
  bool operator ==(Object other) {
    if (other is! UserModel) {
      return false;
    }
    return (other.email == email);
  }

  @override
  int get hashCode => Object.hash(email, phoneNumber);
}
