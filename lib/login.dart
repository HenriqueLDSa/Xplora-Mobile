import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // Centers the Column in the body
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers the Row
              children: [
                Image.asset(
                  'assets/img/xplora-logo.png',
                  width: 250,
                ),
              ],
            ),
            SizedBox(height: 150), // Vertical space between buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 55, 
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => LoginPage()),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xCC451992), // Set the background color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                          ),
                        ),
                        child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 150), // Vertical space between buttons
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}