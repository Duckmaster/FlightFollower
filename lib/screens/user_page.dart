import 'package:flight_follower/models/login_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  void logout(BuildContext context) {
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    manager.logoutUser();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => logout(context), child: Text("logout"));
  }
}
