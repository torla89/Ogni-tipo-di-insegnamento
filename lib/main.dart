import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ogni_tipo_di_insegnamento/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1829E8), // ✅ stesso colore dei bottoni
    statusBarIconBrightness: Brightness.light, // icone bianche
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ogni Tipo Di Insegnamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1829E8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1829E8),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1829E8),
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        useMaterial3: false,
      ),
      home: const HomeScreen(),
    );
  }
}