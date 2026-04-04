import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ogni_tipo_di_insegnamento/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1829E8),
    statusBarIconBrightness: Brightness.light,
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it')],
      locale: const Locale('it'),
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
      home: HomeScreen(),
    );
  }
}