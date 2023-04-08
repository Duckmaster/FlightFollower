import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flutter/cupertino.dart';

import '../utilities/utils.dart';

/// User authentication and login manager
/// This class handles all user auth, login, logout, registering actions
class LoginManager extends ChangeNotifier {
  bool _isLoggedIn;
  User? _currentUser;
  UserModel _currentUserModel;
  // TODO: Refactor listener to be private again
  StreamSubscription? listener;
  bool _isRegistering = false;
  bool _disposed = false;
  LoginManager()
      : _isLoggedIn = false,
        _currentUserModel =
            UserModel("placeholder", "placeholder", "placeholder") {
    initListener();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  UserModel get currentUserModel => _currentUserModel;

  /// Attempts to sign in the user with [email] and [password]
  ///
  /// Returns a Future with the resulting status code
  Future<String> loginUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        updateUserModel(credential.user!);
      }
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  /// Attempts to create a new user account with [email] and [password]
  ///
  /// Returns a Future with the resulting status code
  Future<String> registerUser(UserModel user, String password) async {
    _isRegistering = true;
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
          email: user.email, password: password);
      // Stores the new user info into database
      FirebaseFirestore.instance
          .collection("users")
          .withConverter(
              fromFirestore: UserModel.fromFirestore,
              toFirestore: (UserModel user, options) => user.toFirestore())
          .doc(user.email)
          .set(user);
      _isRegistering = false;
      return "success";
    } on FirebaseAuthException catch (e) {
      _isRegistering = false;
      return e.code;
    }
  }

  void sendVerificationEmail() {
    _currentUser!.sendEmailVerification();
  }

  /// Sign out the currently signed in user
  ///
  /// Returns a Future with the resulting status code
  Future<String> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      notifyListeners();
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void initListener() {
    listener = FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) => listenerCallback(user));
  }

  /// Update this instance to store the UserModel object for [user]
  void updateUserModel(User user) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // TODO: Optimise so if _currentUserModel.email == user.email or
    // getObject("user_model") == _currentUserModel, dont do anything
    var docSnapshot = await db.collection("users").doc(user.email).get();
    _currentUserModel = UserModel.fromJson(docSnapshot.data()!);

    await storeObject(_currentUserModel, "user_object");
    notifyListeners();
  }

  void listenerCallback(User? user) {
    if (user == null) {
      // User is signed out
      _isLoggedIn = false;
      notifyListeners();
    } else {
      // user is signed in
      _currentUser = user;

      // Dont let the user sign in if they havent verified their email
      if (!user.emailVerified) {
        if (!_isRegistering) logoutUser();
        return;
      }

      _isLoggedIn = true;
      notifyListeners();
      updateUserModel(user);
    }
  }
}
