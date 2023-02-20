class User {
  final String username;
  final String email;
  final String phoneNumber;

  User(this.username, this.email, this.phoneNumber);

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        parsedJson['username'], parsedJson['email'], parsedJson['phoneNumber']);
  }

  Map<String, dynamic> toJson() {
    return {"username": username, "email": email, "phoneNumber": phoneNumber};
  }
}
