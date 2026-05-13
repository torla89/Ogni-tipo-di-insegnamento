import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTema { classico, modernoChiaro, modernoScuro, automatico }

class AppThemeProvider extends ChangeNotifier {
  static const String _keyTema = 'tema_app';
  static const String _keyTestoGrande = 'testo_grande';

  AppTema _tema = AppTema.classico;
  bool _testoGrande = false;
  Timer? _timerAutomatico;

  AppTema get tema => _temaEffettivo;
  AppTema get temaImpostato => _tema;
  bool get testoGrande => _testoGrande;
  bool get isAutomatico => _tema == AppTema.automatico;

  bool get _isOraLegale => DateTime.now().timeZoneOffset.inHours >= 2;

  int get _oraAlba => 7;
  int get _oraTramonto => _isOraLegale ? 21 : 18;

  AppTema get _temaEffettivo {
    if (_tema != AppTema.automatico) return _tema;
    final now = TimeOfDay.now();
    final minutiTotali = now.hour * 60 + now.minute;
    final alba = _oraAlba * 60;
    final tramonto = _oraTramonto * 60;
    debugPrint('🕐 ORA: ${now.hour}:${now.minute} | minuti: $minutiTotali | alba: $alba | tramonto: $tramonto | oraLegale: $_isOraLegale');
    if (minutiTotali >= alba && minutiTotali < tramonto) return AppTema.modernoChiaro;
    return AppTema.modernoScuro;
  }

  bool get moderno => _temaEffettivo != AppTema.classico;
  bool get isChiaro => _temaEffettivo == AppTema.modernoChiaro;
  bool get isScuro => _temaEffettivo == AppTema.modernoScuro;
  bool get isClassico => _temaEffettivo == AppTema.classico;

  double get fontSizeBottone => _testoGrande ? 20.0 : 16.0;
  double get fontSizeHome => _testoGrande ? 20.0 : 16.0;

  AppThemeProvider() {
    _carica();
  }

  Future<void> _carica() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_keyTema) ?? 0;
    _tema = AppTema.values[val.clamp(0, AppTema.values.length - 1)];
    _testoGrande = prefs.getBool(_keyTestoGrande) ?? false;
    _aggiornaTimer();
    notifyListeners();
  }

  void _aggiornaTimer() {
    _timerAutomatico?.cancel();
    if (_tema == AppTema.automatico) {
      _timerAutomatico = Timer.periodic(const Duration(minutes: 1), (_) {
        notifyListeners();
      });
    }
  }

  Future<void> setTema(AppTema tema) async {
    _tema = tema;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, tema.index);
    _aggiornaTimer();
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

  @override
  void dispose() {
    _timerAutomatico?.cancel();
    super.dispose();
  }

  String get sfondoMobile {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return 'assets/sfondo_chiaro.png';
      case AppTema.modernoScuro:
        return 'assets/sfondo_scuro.png';
      case AppTema.classico:
      case AppTema.automatico:
        return 'assets/sfondo_home.jpeg';
    }
  }

  String get sfondoDesktop {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return 'assets/sfondo_chiaro_desktop.png';
      case AppTema.modernoScuro:
        return 'assets/sfondo_scuro_desktop.png';
      case AppTema.classico:
      case AppTema.automatico:
        return 'assets/sfondo_home_desktop.jpeg';
    }
  }

  Color get coloreTesto {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return const Color(0xFF2C1A0E);
      case AppTema.modernoScuro:
      case AppTema.classico:
      case AppTema.automatico:
        return Colors.white;
    }
  }

  Color get coloreTestoSecondario {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return const Color(0xFF5C3D1E);
      case AppTema.modernoScuro:
      case AppTema.classico:
      case AppTema.automatico:
        return Colors.white70;
    }
  }

  Color get bottoneColore {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return const Color(0x88FFFFFF);
      case AppTema.modernoScuro:
        return const Color(0x33000000);
      case AppTema.classico:
      case AppTema.automatico:
        return Colors.transparent;
    }
  }

  Color get bottoneBordo {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return const Color(0xAAFFFFFF);
      case AppTema.modernoScuro:
        return const Color(0x33FFFFFF);
      case AppTema.classico:
      case AppTema.automatico:
        return Colors.transparent;
    }
  }

  double get gradienteTop {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return 0.0;
      case AppTema.modernoScuro:
        return 0.3;
      case AppTema.classico:
      case AppTema.automatico:
        return 0.2;
    }
  }

  double get gradienteBottom {
    switch (_temaEffettivo) {
      case AppTema.modernoChiaro:
        return 0.08;
      case AppTema.modernoScuro:
        return 0.6;
      case AppTema.classico:
      case AppTema.automatico:
        return 0.3;
    }
  }
}