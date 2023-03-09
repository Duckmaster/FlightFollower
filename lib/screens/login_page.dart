import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    return Padding(
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
                            controller: emailController,
                            decoration: const InputDecoration(
                                label: Text("Email/phone number")),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: emailController,
                            decoration:
                                const InputDecoration(label: Text("Password")),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(
                                    style: linkStyle,
                                    text: "Forgot your password?",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => print("Reset password"))),
                          ],
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: Column(children: [
                            ElevatedButton(
                                onPressed: () => print("login"),
                                child: const Text("Login")),
                            ElevatedButton(
                                onPressed: () => print("register"),
                                child: const Text("Register"))
                          ]),
                        )
                      ],
                    )),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
