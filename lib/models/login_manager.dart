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
  LoginManager() : _isLoggedIn = false {
    initListener();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<String> loginUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String> registerUser(UserModel user, String password) async {
    try {
      final auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email, password: password);
      FirebaseFirestore.instance
          .collection("users")
          .withConverter(
              fromFirestore: UserModel.fromFirestore,
              toFirestore: (UserModel user, options) => user.toFirestore())
          .doc(user.email)
          .set(user);
      return "success";
    } on FirebaseAuthException catch (e) {
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
    removeListener(() => listenerCallback);
    super.dispose();
  }

  void initListener() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) => listenerCallback(user));
  }

  void listenerCallback(User? user) {
    if (user == null) {
      print('User is currently signed out!');
      _isLoggedIn = false;
      notifyListeners();
    } else {
      _currentUser = user;
      if (!user.emailVerified) {
        logoutUser();
      }
      print('User is signed in!');
      _isLoggedIn = true;
      notifyListeners();
      getObject("user_object").then((result) {
        Map<String, dynamic> userMap = result;
        if (UserModel.fromJson(userMap).email != user.email) {
          FirebaseFirestore db = FirebaseFirestore.instance;
          db.collection("users").doc(user.email).get().then(
            (docSnapshot) {
              storeObject(
                  UserModel.fromJson(docSnapshot.data()!), "user_object");
            },
          );
        }
      });
    }
  }
}
