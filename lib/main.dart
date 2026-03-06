import 'package:flutter/material.dart';
import 'package:ogni_tipo_di_insegnamento/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ogni Tipo Di Insegnamento',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}