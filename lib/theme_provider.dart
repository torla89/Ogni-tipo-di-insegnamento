import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTema { classico, modernoChiaro, modernoScuro }

class AppThemeProvider extends ChangeNotifier {
  static const String _keyTema = 'tema_app';
  static const String _keyTestoGrande = 'testo_grande';

  AppTema _tema = AppTema.classico;
  bool _testoGrande = false;

  AppTema get tema => _tema;
  bool get testoGrande => _testoGrande;

  bool get moderno => _tema != AppTema.classico;
  bool get isChiaro => _tema == AppTema.modernoChiaro;
  bool get isScuro => _tema == AppTema.modernoScuro;
  bool get isClassico => _tema == AppTema.classico;

  // FontSize per bottoni liste
  double get fontSizeBottone => _testoGrande ? 19.0 : 14.0;
  // FontSize per bottoni home
  double get fontSizeHome => _testoGrande ? 19.0 : 14.0;

  AppThemeProvider() {
    _carica();
  }

  Future<void> _carica() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_keyTema) ?? 0;
    _tema = AppTema.values[val.clamp(0, AppTema.values.length - 1)];
    _testoGrande = prefs.getBool(_keyTestoGrande) ?? false;
    notifyListeners();
  }

  Future<void> setTema(AppTema tema) async {
    _tema = tema;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, tema.index);
    notifyListeners();
  }

  Future<void> setTestoGrande(bool value) async {
    _testoGrande = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTestoGrande, value);
    notifyListeners();
  }

  Future<void> setModerno(bool value) async {
    await setTema(value ? AppTema.modernoScuro : AppTema.classico);
  }

  String get sfondoMobile {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return 'assets/sfondo_chiaro.png';
      case AppTema.modernoScuro:
        return 'assets/sfondo_scuro.png';
      case AppTema.classico:
        return 'assets/sfondo_home.jpeg';
    }
  }

  String get sfondoDesktop {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return 'assets/sfondo_chiaro_desktop.png';
      case AppTema.modernoScuro:
        return 'assets/sfondo_scuro_desktop.png';
      case AppTema.classico:
        return 'assets/sfondo_home_desktop.jpeg';
    }
  }

  Color get coloreTesto {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return const Color(0xFF2C1A0E);
      case AppTema.modernoScuro:
        return Colors.white;
      case AppTema.classico:
        return Colors.white;
    }
  }

  Color get coloreTestoSecondario {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return const Color(0xFF5C3D1E);
      case AppTema.modernoScuro:
        return Colors.white70;
      case AppTema.classico:
        return Colors.white70;
    }
  }

  Color get bottoneColore {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return const Color(0x88FFFFFF);
      case AppTema.modernoScuro:
        return const Color(0x33000000);
      case AppTema.classico:
        return Colors.transparent;
    }
  }

  Color get bottoneBordo {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return const Color(0xAAFFFFFF);
      case AppTema.modernoScuro:
        return const Color(0x33FFFFFF);
      case AppTema.classico:
        return Colors.transparent;
    }
  }

  double get gradienteTop {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return 0.0;
      case AppTema.modernoScuro:
        return 0.3;
      case AppTema.classico:
        return 0.2;
    }
  }

  double get gradienteBottom {
    switch (_tema) {
      case AppTema.modernoChiaro:
        return 0.08;
      case AppTema.modernoScuro:
        return 0.6;
      case AppTema.classico:
        return 0.3;
    }
  }
}