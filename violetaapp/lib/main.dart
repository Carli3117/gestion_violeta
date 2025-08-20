import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const VioletaApp());
}

class VioletaApp extends StatelessWidget {
  const VioletaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Violeta App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
