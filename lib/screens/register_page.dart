import 'package:flight_follower/models/login_manager.dart';
import 'package:flight_follower/models/user_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController phoneController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

  void register(BuildContext context) {
    UserModel newUser = UserModel(
        nameController.text, emailController.text, phoneController.text);
    LoginManager manager = Provider.of<LoginManager>(context, listen: false);
    manager.registerUser(newUser, passwordController.text).then((returnCode) {
      if (returnCode == "success") {
        manager.sendVerificationEmail();
      }
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: Column(
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "Flight Follower",
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Form(
                        child: Expanded(
                            child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(label: Text("Name")),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                    label: Text("Email address")),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                    label: Text("Phone number")),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    label: Text("Password")),
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 3,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Back")),
                                    const Padding(padding: EdgeInsets.all(5)),
                                    ElevatedButton(
                                        onPressed: () => register(context),
                                        child: const Text("Register")),
                                  ]),
                            )
                          ],
                        )),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}