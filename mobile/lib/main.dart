import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';

void main() {
  runApp(const LaundryLoopApp());
}

class LaundryLoopApp extends StatelessWidget {
  const LaundryLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryLoop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
