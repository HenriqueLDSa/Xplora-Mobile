import 'package:flutter/material.dart';
import 'package:xplora/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Wrap in MaterialApp
      title: 'Xplora',
      theme: ThemeData(
        primaryColor: Color(0xFF451992),
      ),
      home: const WelcomePage(), // Set WelcomePage as the home
    );
  }
}
