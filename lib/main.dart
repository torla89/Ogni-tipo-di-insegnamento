import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OgniTipoDiInsegnamentoApp());
}

class OgniTipoDiInsegnamentoApp extends StatelessWidget {
  const OgniTipoDiInsegnamentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ogni tipo di insegnamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1829E8),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1829E8),
          foregroundColor: Colors.white,
          elevation: 8,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
