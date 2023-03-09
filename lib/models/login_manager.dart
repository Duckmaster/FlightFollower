import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoginManager extends ChangeNotifier {
  bool _isLoggedIn;
  LoginManager() : _isLoggedIn = false {
    initListener();
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<String> loginUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _isLoggedIn = true;
      notifyListeners();
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  void initListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }
}
