import 'package:flutter/material.dart';
import 'homepage.dart'; //Import the homepage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gala',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 10, 71, 121),
      ),
      home: const Homepage(), //Connect the homepage
    );
  }
}
