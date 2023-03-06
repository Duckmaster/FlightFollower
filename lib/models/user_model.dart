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
}
