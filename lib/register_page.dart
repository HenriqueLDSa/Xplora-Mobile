import 'package:flutter/material.dart';
import 'package:xplora/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState(); // Implement createState
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            //Logo row field
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                'assets/images/xplora.png',
                width: 250,
              ),
            ] //Children
                ),
            const SizedBox(height: 20),

            //First Name text field
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(label: "First Name"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Last Name text field
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(label: "Last Name"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Email text field
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(label: "Email"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Password text field
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(label: "Password"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Confirm Password text field
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomTextField(label: "Confirm Password"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Register button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Placeholder(/*Dashboard*/)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF6C4AB6), // Adjust to match the purple button color
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

            //Login link
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
                    padding: EdgeInsets.zero, // Removes padding
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
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
