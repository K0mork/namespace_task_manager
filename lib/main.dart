import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NamespaceTaskApp());
}

class NamespaceTaskApp extends StatelessWidget {
  const NamespaceTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namespace Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
