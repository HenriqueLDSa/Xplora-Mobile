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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isValid = false;
  String _errorMessage = '';

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

      userId = jsonResponse['user_id'];
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

  bool _validatePassword(String password) {
    _errorMessage = '';

    if (password.length < 8) {
      _errorMessage += '• Password must be longer than 8 characters\n';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += '• Uppercase letter is missing\n';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += '• Lowercase letter is missing\n';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += '• Digit is missing\n';
    }

    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += '• Special character is missing\n';
    }

    return _errorMessage.isEmpty;
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
                            controller: _firstNameController,
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
                            controller: _lastNameController,
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
                            controller: _emailController,
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
                            controller: _passwordController,
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
                            controller: _confirmPassController,
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
                        final firstNameText = _firstNameController.text.trim();
                        final lastNameText = _lastNameController.text.trim();
                        final emailText = _emailController.text.trim();
                        final passwordText = _passwordController.text.trim();
                        final confirPasswordText =
                            _confirmPassController.text.trim();

                        if (firstNameText == "" ||
                            lastNameText == "" ||
                            emailText == "" ||
                            passwordText == "" ||
                            confirPasswordText == "") {
                          Fluttertoast.showToast(
                              msg: "All fields are required",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          return;
                        }

                        if (passwordText != confirPasswordText) {
                          Fluttertoast.showToast(
                              msg: "Passwords don't match",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          return;
                        }

                        setState(() {
                          _isValid =
                              _validatePassword(_passwordController.text);
                        });

                        if (!_isValid) {
                          Fluttertoast.showToast(
                              msg:
                                  "Password is not valid:\n${_errorMessage.substring(0, _errorMessage.length - 1)}",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          return;
                        }

                        doRegister(firstNameText, lastNameText, emailText,
                                passwordText)
                            .then((registerSuccess) {
                          if (registerSuccess && mounted) {
                            navigateToDashboard();
                          } else if (mounted) {
                            Fluttertoast.showToast(
                              msg: "Email already exists",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
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
