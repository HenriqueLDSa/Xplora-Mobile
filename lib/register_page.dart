import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:xplora/dashboard_page.dart';
import 'package:xplora/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  String? userId, firstName, lastName, email;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  Future<bool> doRegister(String reqFirstName, String reqLastName,
      String reqEmail, String reqPassword) async {
    Map<String, dynamic> jsonPayload = {
      "first_name": reqFirstName,
      "last_name": reqLastName,
      "email": reqEmail,
      "password": reqPassword
    };

    final response = await http.post(
        Uri.parse('https://xplora.fun/api/register'),
        body: jsonEncode(jsonPayload),
        headers: {'Content-type': 'application/json'});

    logger.d('Payload sent: $jsonPayload');

    if (response.statusCode == 201) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      userId = ""; //Edit API to return the userId as well
      firstName = jsonResponse['first_name'];
      lastName = jsonResponse['last_name'];
      email = jsonResponse['email'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', userId!);
      prefs.setString('firstName', firstName!);
      prefs.setString('lastName', lastName!);
      prefs.setString('email', email!);

      logger.i('Register Successful: $jsonResponse');
      return true;
    }

    logger.e('Failed to register: ${response.body}');
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
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  'assets/images/xplora.png',
                  width: 250,
                ),
              ]),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: CustomTextField(
                            label: "First Name",
                            controller: firstNameController,
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
                            label: "Last Name",
                            controller: lastNameController,
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
                            obscureText: true,
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
                            label: "Confirm Password",
                            controller: confirmPassController,
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        final firstNameText = firstNameController.text.trim();
                        final lastNameText = lastNameController.text.trim();
                        final emailText = emailController.text.trim();
                        final passwordText = passwordController.text.trim();

                        doRegister(firstNameText, lastNameText, emailText,
                                passwordText)
                            .then((registerSuccess) {
                          if (registerSuccess && mounted) {
                            navigateToDashboard();
                          } else if (mounted) {
                            Fluttertoast.showToast(
                              msg: "Email already exists",
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
                        'Sign Up',
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
                    "Already have an account? ",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(color: Color.fromRGBO(4, 49, 199, 1)),
                    ),
                  ),
                ],
              ),
            ]),
          ),
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
