import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoginManager extends ChangeNotifier {
  bool _isLoggedIn;
  User? _currentUser;
  LoginManager() : _isLoggedIn = false {
    initListener();
  }

  bool get isLoggedIn => _isLoggedIn;

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

  void initListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
      if (user == null) {
        print('User is currently signed out!');
        _isLoggedIn = false;
      } else {
        print('User is signed in!');
        _isLoggedIn = true;
      }
    });
  }
}
