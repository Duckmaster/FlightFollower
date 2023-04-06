import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flutter/cupertino.dart';

import '../utilities/utils.dart';

class LoginManager extends ChangeNotifier {
  bool _isLoggedIn;
  User? _currentUser;
  UserModel _currentUserModel;
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

  Future<String> registerUser(UserModel user, String password) async {
    _isRegistering = true;
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
          email: user.email, password: password);
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

  Future<String> logoutUser() async {
    try {
      final credential = await FirebaseAuth.instance.signOut();
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

  Future<void> updateUserModel(User user) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (_currentUserModel.email != user.email) {
      db.collection("users").doc(user.email).get().then(
        (docSnapshot) {
          _currentUserModel = UserModel.fromJson(docSnapshot.data()!);
          notifyListeners();
        },
      );
    } else {
      db.collection("users").doc(user.email).get().then((docSnapshot) {
        _currentUserModel = UserModel.fromJson(docSnapshot.data()!);
        notifyListeners();
      });
    }
  }

  void listenerCallback(User? user) {
    if (user == null) {
      print('User is currently signed out!');
      _isLoggedIn = false;
      notifyListeners();
    } else {
      _currentUser = user;
      if (!user.emailVerified) {
        if (!_isRegistering) logoutUser();
        return;
      }
      print('User is signed in!');
      _isLoggedIn = true;
      notifyListeners();
    }
  }
}
