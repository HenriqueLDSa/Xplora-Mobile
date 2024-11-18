import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplora/dashboard_page.dart';
import 'package:xplora/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  String? userId, firstName, lastName, email;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> doLogin(String reqEmail, String reqPassword) async {
    final response = await http.post(Uri.parse('https://xplora.fun/api/login'),
        body: jsonEncode({'email': reqEmail, 'password': reqPassword}),
        headers: {'Content-Type': 'application/json'});

    logger.d('Email sent: $reqEmail\nPassword sent: $reqPassword');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      userId = jsonResponse['id'];
      firstName = jsonResponse['firstName'];
      lastName = jsonResponse['lastName'];
      email = jsonResponse['email'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', userId!);
      prefs.setString('firstName', firstName!);
      prefs.setString('lastName', lastName!);
      prefs.setString('email', email!);

      logger.i('Login Successful: $firstName $lastName $userId');
      return true;
    }

    logger.e('Failed to log in: ${response.body}');
    return false;
  }

  void navigateToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                'assets/images/xplora.png',
                width: 250,
              ),
            ]),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    label: "Email",
                    controller: emailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                      label: "Password",
                      controller: passwordController,
                      obscureText: true),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      doLogin(email, password).then((loginSuccess) {
                        if (loginSuccess && mounted) {
                          navigateToDashboard();
                        } else if (mounted) {
                          Fluttertoast.showToast(
                            msg: "Login unsuccessful. Please try again!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4AB6),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Color.fromRGBO(4, 49, 199, 1)),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: label,
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
}
