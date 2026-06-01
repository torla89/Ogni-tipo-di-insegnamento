import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum esteso per compatibilità con le schermate esistenti
enum AppTema {
  classico,
  moderno,
  personalizzato,
  modernoChiaro,  // usato solo internamente per compatibilità
  modernoScuro,   // usato solo internamente per compatibilità
  automatico,     // usato solo internamente per compatibilità
}

enum AppTemaModerno { chiaro, scuro, automatico }
enum StileBottone { classico, outline, pill, sharp, lista }
enum AlternanzaSfondo {
  fisso, giornoNotte, giornoNotteRandom,
  randomApertura, randomGiornaliero, randomStagionale,
}

class SfondoApp {
  final String id;
  final String pathMobile;
  final String? pathDesktop;
  final bool isChiaro;
  const SfondoApp({
    required this.id, required this.pathMobile,
    this.pathDesktop, required this.isChiaro,
  });
}

const List<SfondoApp> sfondiDisponibili = [
  SfondoApp(id: 'chiaro_autunno',   pathMobile: 'assets/images/Chiaro - autunno.png',      isChiaro: true),
  SfondoApp(id: 'chiaro_casa',      pathMobile: 'assets/images/chiaro - casa.png',          isChiaro: true),
  SfondoApp(id: 'chiaro_collina',   pathMobile: 'assets/images/Chiaro - collina.png',       isChiaro: true),
  SfondoApp(id: 'chiaro_estate',    pathMobile: 'assets/images/Chiaro - estate.png',        isChiaro: true),
  SfondoApp(id: 'chiaro_inverno',   pathMobile: 'assets/images/Chiaro - inverno.png',       isChiaro: true),
  SfondoApp(id: 'chiaro_lago',      pathMobile: 'assets/images/Chiaro - lago.png',          isChiaro: true),
  SfondoApp(id: 'chiaro_primavera', pathMobile: 'assets/images/Chiaro - primavera.png',     isChiaro: true),
  SfondoApp(id: 'chiaro_spiaggia2', pathMobile: 'assets/images/Chiaro - spiaggia 2.png',    isChiaro: true),
  SfondoApp(id: 'scuro_autunno',    pathMobile: 'assets/images/scuro - autunno.png',        isChiaro: false),
  SfondoApp(id: 'scuro_balloni',    pathMobile: 'assets/images/scuro - balloni fieno.png',  isChiaro: false),
  SfondoApp(id: 'scuro_bosco',      pathMobile: 'assets/images/scuro - bosco.png',          isChiaro: false),
  SfondoApp(id: 'scuro_casa_fiume', pathMobile: 'assets/images/Scuro - casa sul fiume.png', isChiaro: false),
  SfondoApp(id: 'scuro_estivo',     pathMobile: 'assets/images/scuro - estivo.png',         isChiaro: false),
  SfondoApp(id: 'scuro_inverno',    pathMobile: 'assets/images/scuro - inverno.png',        isChiaro: false),
  SfondoApp(id: 'scuro_lago',       pathMobile: 'assets/images/scuro - lago.png',           isChiaro: false),
  SfondoApp(id: 'scuro_primavera',  pathMobile: 'assets/images/scuro - primavera.png',      isChiaro: false),
];

List<SfondoApp> get sfondiChiari => sfondiDisponibili.where((s) => s.isChiaro).toList();
List<SfondoApp> get sfondiScuri  => sfondiDisponibili.where((s) => !s.isChiaro).toList();

class TemaPersonalizzatoSalvato {
  String id;
  String nome;
  AlternanzaSfondo alternanza;
  String sfondoFissoId;
  String sfondoGiornoId;
  String sfondoNotteId;
  StileBottone stileBottone;
  int coloreBottone;
  double opacitaBottone;
  int coloreBottoneGiorno;
  double opacitaBottoneGiorno;
  int coloreBottoneNotte;
  double opacitaBottoneNotte;

  TemaPersonalizzatoSalvato({
    required this.id, required this.nome,
    required this.alternanza,
    required this.sfondoFissoId, required this.sfondoGiornoId,
    required this.sfondoNotteId, required this.stileBottone,
    required this.coloreBottone, required this.opacitaBottone,
    required this.coloreBottoneGiorno, required this.opacitaBottoneGiorno,
    required this.coloreBottoneNotte, required this.opacitaBottoneNotte,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nome': nome,
    'alternanza': alternanza.index,
    'sfondoFissoId': sfondoFissoId,
    'sfondoGiornoId': sfondoGiornoId,
    'sfondoNotteId': sfondoNotteId,
    'stileBottone': stileBottone.index,
    'coloreBottone': coloreBottone,
    'opacitaBottone': opacitaBottone,
    'coloreBottoneGiorno': coloreBottoneGiorno,
    'opacitaBottoneGiorno': opacitaBottoneGiorno,
    'coloreBottoneNotte': coloreBottoneNotte,
    'opacitaBottoneNotte': opacitaBottoneNotte,
  };

  factory TemaPersonalizzatoSalvato.fromJson(Map<String, dynamic> j) =>
      TemaPersonalizzatoSalvato(
        id: j['id'] as String,
        nome: j['nome'] as String,
        alternanza: AlternanzaSfondo.values[(j['alternanza'] as int)
            .clamp(0, AlternanzaSfondo.values.length - 1)],
        sfondoFissoId: j['sfondoFissoId'] as String,
        sfondoGiornoId: j['sfondoGiornoId'] as String,
        sfondoNotteId: j['sfondoNotteId'] as String,
        stileBottone: StileBottone.values[(j['stileBottone'] as int)
            .clamp(0, StileBottone.values.length - 1)],
        coloreBottone: j['coloreBottone'] as int,
        opacitaBottone: (j['opacitaBottone'] as num).toDouble(),
        coloreBottoneGiorno: j['coloreBottoneGiorno'] as int,
        opacitaBottoneGiorno: (j['opacitaBottoneGiorno'] as num).toDouble(),
        coloreBottoneNotte: j['coloreBottoneNotte'] as int,
        opacitaBottoneNotte: (j['opacitaBottoneNotte'] as num).toDouble(),
      );
}

class AppThemeProvider extends ChangeNotifier {
  static const String _keyTema                 = 'tema_app_v2';
  static const String _keyTemaModerno          = 'tema_moderno';
  static const String _keyTemaPersonalizzatoId = 'tema_personalizzato_id';
  static const String _keyFontSize             = 'font_size';
  static const String _keyStileBottone         = 'stile_bottone';
  static const String _keyColoreBottone        = 'colore_bottone';
  static const String _keyOpacitaBottone       = 'opacita_bottone';
  static const String _keyColoreBottoneGiorno  = 'colore_bottone_giorno';
  static const String _keyColoreBottoneNotte   = 'colore_bottone_notte';
  static const String _keyOpacitaBottoneGiorno = 'opacita_bottone_giorno';
  static const String _keyOpacitaBottoneNotte  = 'opacita_bottone_notte';
  static const String _keyAlternanza           = 'alternanza_sfondo';
  static const String _keySfondoFissoId        = 'sfondo_fisso_id';
  static const String _keySfondoGiornoId       = 'sfondo_giorno_id';
  static const String _keySfondoNotteId        = 'sfondo_notte_id';
  static const String _keySfondoRandomId       = 'sfondo_random_id';
  static const String _keySfondoRandGiornoId   = 'sfondo_rand_giorno_id';
  static const String _keySfondoRandNotteId    = 'sfondo_rand_notte_id';
  static const String _keyUltimoGiornoRandom   = 'ultimo_giorno_random';
  static const String _keyUltimaDataRandom     = 'ultima_data_random';
  static const String _keyTemiSalvati          = 'temi_salvati';
  static const String _keyColoreTesto          = 'colore_testo_bottone';
  static const String _keyColoreTestoGiorno    = 'colore_testo_giorno';
  static const String _keyColoreTestoNotte     = 'colore_testo_notte';
  static const int    _maxTemi                 = 5;

  AppTema        _tema        = AppTema.classico;
  AppTemaModerno _temaModerno = AppTemaModerno.automatico;
  String?        _temaPersonalizzatoAttivoId;
  double         _fontSize   = 16.0;
  Timer?         _timerAutomatico;

  StileBottone     _stileBottone         = StileBottone.classico;
  Color            _coloreBottone        = const Color(0xFF1829E8);
  double           _opacitaBottone       = 0.92;
  Color            _coloreBottoneGiorno  = const Color(0xFF1829E8);
  Color            _coloreBottoneNotte   = const Color(0xFF1829E8);
  double           _opacitaBottoneGiorno = 0.92;
  double           _opacitaBottoneNotte  = 0.92;
  Color?           _coloreTesto;       // null = automatico (calcolato dalla luminanza)
  Color?           _coloreTestoGiorno; // null = usa _coloreTesto
  Color?           _coloreTestoNotte;  // null = usa _coloreTesto
  AlternanzaSfondo _alternanza           = AlternanzaSfondo.fisso;
  String _sfondoFissoId      = 'chiaro_primavera';
  String _sfondoGiornoId     = 'chiaro_primavera';
  String _sfondoNotteId      = 'scuro_lago';
  String _sfondoRandomId     = 'chiaro_primavera';
  String _sfondoRandGiornoId = 'chiaro_primavera';
  String _sfondoRandNotteId  = 'scuro_lago';
  int    _ultimoGiornoRandom = -1;
  String _ultimaDataRandom   = '';

  List<TemaPersonalizzatoSalvato> _temiSalvati = [];

  // ── Getter principali ────────────────────────────────────────
  AppTema        get tema                       => _tema;
  AppTemaModerno get temaModerno                => _temaModerno;
  String?        get temaPersonalizzatoAttivoId => _temaPersonalizzatoAttivoId;
  bool           get isClassico                 => _tema == AppTema.classico;
  bool           get isModerno                  => _tema == AppTema.moderno;
  bool           get isPersonalizzato           => _tema == AppTema.personalizzato;
  double         get fontSize                   => _fontSize;
  double         get fontSizeBottone            => _fontSize;
  double         get fontSizeHome               => _fontSize;
  List<TemaPersonalizzatoSalvato> get temiSalvati =>
      List.unmodifiable(_temiSalvati);
  bool get puoAggiungereNuovoTema => _temiSalvati.length < _maxTemi;

  StileBottone get stileBottone    => _stileBottone;
  bool   get isStileLista          => _stileBottone == StileBottone.lista;
  double get radiusBottone         => _stileBottone == StileBottone.pill  ? 30.0
      : _stileBottone == StileBottone.sharp ?  2.0 : 14.0;
  bool   get isStileOutline        => _stileBottone == StileBottone.outline;
  Color  get coloreBottonePersonalizzato => _coloreBottone;
  double get opacitaBottone        => _opacitaBottone;
  Color  get coloreBottoneGiorno   => _coloreBottoneGiorno;
  Color  get coloreBottoneNotte    => _coloreBottoneNotte;
  double get opacitaBottoneGiorno  => _opacitaBottoneGiorno;
  double get opacitaBottoneNotte   => _opacitaBottoneNotte;
  AlternanzaSfondo get alternanza  => _alternanza;
  String get sfondoFissoId         => _sfondoFissoId;
  String get sfondoGiornoId        => _sfondoGiornoId;
  String get sfondoNotteId         => _sfondoNotteId;
  String get sfondoRandGiornoId    => _sfondoRandGiornoId;
  String get sfondoRandNotteId     => _sfondoRandNotteId;

  // ── Getter compatibilità schermate esistenti ─────────────────
  bool get moderno      => _tema == AppTema.moderno;
  bool get isAutomatico => _tema == AppTema.moderno &&
      _temaModerno == AppTemaModerno.automatico;

  // temaImpostato restituisce modernoChiaro/Scuro/classico
  // per compatibilità con switch nelle schermate esistenti
  AppTema get temaImpostato => _temaEffettivoCompat;

  AppTema get _temaEffettivoCompat {
    if (_tema == AppTema.classico)       return AppTema.classico;
    if (_tema == AppTema.personalizzato) return AppTema.classico;
    // tema == moderno
    switch (_temaModerno) {
      case AppTemaModerno.chiaro:
        return AppTema.modernoChiaro;
      case AppTemaModerno.scuro:
        return AppTema.modernoScuro;
      case AppTemaModerno.automatico:
        return _isGiornoOra ? AppTema.modernoChiaro : AppTema.modernoScuro;
    }
  }

  bool get isChiaro {
    if (_tema == AppTema.moderno) {
      if (_temaModerno == AppTemaModerno.chiaro) return true;
      if (_temaModerno == AppTemaModerno.scuro)  return false;
      return _isGiornoOra;
    }
    return false;
  }

  bool get isScuro {
    if (_tema == AppTema.moderno) {
      if (_temaModerno == AppTemaModerno.scuro)  return true;
      if (_temaModerno == AppTemaModerno.chiaro) return false;
      return !_isGiornoOra;
    }
    return false;
  }

  bool get _isOraLegale => DateTime.now().timeZoneOffset.inHours >= 2;
  int  get _oraAlba     => 7;
  int  get _oraTramonto => _isOraLegale ? 21 : 18;

  bool get _isGiornoOra {
    final min = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
    return min >= _oraAlba * 60 && min < _oraTramonto * 60;
  }

  bool get _usaColoriGiornoNotte =>
      _alternanza == AlternanzaSfondo.giornoNotte ||
          _alternanza == AlternanzaSfondo.giornoNotteRandom;

  Color get coloreBottoneAttivo {
    if (_tema != AppTema.personalizzato) return const Color(0xFF1829E8);
    if (_usaColoriGiornoNotte)
      return _isGiornoOra ? _coloreBottoneGiorno : _coloreBottoneNotte;
    return _coloreBottone;
  }

  double get opacitaBottoneAttiva {
    if (_tema != AppTema.personalizzato) return 0.92;
    if (_usaColoriGiornoNotte)
      return _isGiornoOra ? _opacitaBottoneGiorno : _opacitaBottoneNotte;
    return _opacitaBottone;
  }

  Color get coloreTestoAppBar {
    if (!isPersonalizzato) return Colors.white;
    final c = coloreBottoneAttivo;
    final lum = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return lum > 0.5 ? Colors.black : Colors.white;
  }

  bool get isTestoAutomatico => _coloreTesto == null;

  Color get coloreTestoBottone {
    // Giorno/notte ha precedenza se impostato
    if (_usaColoriGiornoNotte) {
      final testoGN = _isGiornoOra ? _coloreTestoGiorno : _coloreTestoNotte;
      if (testoGN != null) return testoGN;
    }
    if (_coloreTesto != null) return _coloreTesto!;
    final c = coloreBottoneAttivo;
    final lum = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return lum > 0.5 ? Colors.black : Colors.white;
  }

  Color? get coloreTestoGiorno => _coloreTestoGiorno;
  Color? get coloreTestoNotte  => _coloreTestoNotte;

  Future<void> setColoreTesto(Color? c) async {
    _coloreTesto = c;
    final prefs = await SharedPreferences.getInstance();
    if (c == null) { await prefs.remove(_keyColoreTesto); }
    else { await prefs.setInt(_keyColoreTesto, c.value); }
    notifyListeners();
  }

  Future<void> setColoreTestoGiorno(Color? c) async {
    _coloreTestoGiorno = c;
    final prefs = await SharedPreferences.getInstance();
    if (c == null) { await prefs.remove(_keyColoreTestoGiorno); }
    else { await prefs.setInt(_keyColoreTestoGiorno, c.value); }
    notifyListeners();
  }

  Future<void> setColoreTestoNotte(Color? c) async {
    _coloreTestoNotte = c;
    final prefs = await SharedPreferences.getInstance();
    if (c == null) { await prefs.remove(_keyColoreTestoNotte); }
    else { await prefs.setInt(_keyColoreTestoNotte, c.value); }
    notifyListeners();
  }

  AppThemeProvider() { _carica(); }

  Future<void> _carica() async {
    final prefs = await SharedPreferences.getInstance();

    final val = prefs.getInt(_keyTema) ?? 0;
    _tema = AppTema.values[val.clamp(0, 2)];

    final valModerno = prefs.getInt(_keyTemaModerno) ?? 2;
    _temaModerno = AppTemaModerno.values[valModerno
        .clamp(0, AppTemaModerno.values.length - 1)];

    _temaPersonalizzatoAttivoId = prefs.getString(_keyTemaPersonalizzatoId);
    _fontSize = prefs.getDouble(_keyFontSize) ?? 16.0;

    final stileVal = prefs.getInt(_keyStileBottone) ?? 0;
    _stileBottone = StileBottone.values[stileVal
        .clamp(0, StileBottone.values.length - 1)];

    _coloreBottone        = Color(prefs.getInt(_keyColoreBottone)       ?? 0xFF1829E8);
    _opacitaBottone       = prefs.getDouble(_keyOpacitaBottone)         ?? 0.92;
    _coloreBottoneGiorno  = Color(prefs.getInt(_keyColoreBottoneGiorno) ?? 0xFF1829E8);
    _coloreBottoneNotte   = Color(prefs.getInt(_keyColoreBottoneNotte)  ?? 0xFF1829E8);
    _opacitaBottoneGiorno = prefs.getDouble(_keyOpacitaBottoneGiorno)   ?? 0.92;
    _opacitaBottoneNotte  = prefs.getDouble(_keyOpacitaBottoneNotte)    ?? 0.92;
    final coloreTestoVal       = prefs.getInt(_keyColoreTesto);
    _coloreTesto       = coloreTestoVal != null ? Color(coloreTestoVal) : null;
    final coloreTestoGiornoVal = prefs.getInt(_keyColoreTestoGiorno);
    _coloreTestoGiorno = coloreTestoGiornoVal != null ? Color(coloreTestoGiornoVal) : null;
    final coloreTestoNotteVal  = prefs.getInt(_keyColoreTestoNotte);
    _coloreTestoNotte  = coloreTestoNotteVal  != null ? Color(coloreTestoNotteVal)  : null;

    final alternanzaVal = prefs.getInt(_keyAlternanza) ?? 0;
    _alternanza = AlternanzaSfondo.values[alternanzaVal
        .clamp(0, AlternanzaSfondo.values.length - 1)];

    _sfondoFissoId      = prefs.getString(_keySfondoFissoId)    ?? 'chiaro_primavera';
    _sfondoGiornoId     = prefs.getString(_keySfondoGiornoId)   ?? 'chiaro_primavera';
    _sfondoNotteId      = prefs.getString(_keySfondoNotteId)    ?? 'scuro_lago';
    _ultimoGiornoRandom = prefs.getInt(_keyUltimoGiornoRandom)  ?? -1;
    _ultimaDataRandom   = prefs.getString(_keyUltimaDataRandom) ?? '';

    final temiJson = prefs.getString(_keyTemiSalvati);
    if (temiJson != null) {
      try {
        final lista = json.decode(temiJson) as List;
        _temiSalvati = lista
            .map((e) => TemaPersonalizzatoSalvato.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) { _temiSalvati = []; }
    }

    if (_tema == AppTema.personalizzato && _temaPersonalizzatoAttivoId != null) {
      final attivo = _temiSalvati.firstWhere(
            (t) => t.id == _temaPersonalizzatoAttivoId,
        orElse: () => _temiSalvati.isNotEmpty ? _temiSalvati.first : _temaDiDefault(),
      );
      _applicaTema(attivo);
    }

    _aggiornaRandomSeNecessario(prefs);
    _aggiornaTimer();
    notifyListeners();
  }

  TemaPersonalizzatoSalvato _temaDiDefault() =>
      TemaPersonalizzatoSalvato(
        id: 'default', nome: 'Default',
        alternanza: AlternanzaSfondo.fisso,
        sfondoFissoId: 'chiaro_primavera',
        sfondoGiornoId: 'chiaro_primavera',
        sfondoNotteId: 'scuro_lago',
        stileBottone: StileBottone.classico,
        coloreBottone: 0xFF1829E8, opacitaBottone: 0.92,
        coloreBottoneGiorno: 0xFF1829E8, opacitaBottoneGiorno: 0.92,
        coloreBottoneNotte: 0xFF1829E8, opacitaBottoneNotte: 0.92,
      );

  void _applicaTema(TemaPersonalizzatoSalvato t) {
    _alternanza           = t.alternanza;
    _sfondoFissoId        = t.sfondoFissoId;
    _sfondoGiornoId       = t.sfondoGiornoId;
    _sfondoNotteId        = t.sfondoNotteId;
    _stileBottone         = t.stileBottone;
    _coloreBottone        = Color(t.coloreBottone);
    _opacitaBottone       = t.opacitaBottone;
    _coloreBottoneGiorno  = Color(t.coloreBottoneGiorno);
    _opacitaBottoneGiorno = t.opacitaBottoneGiorno;
    _coloreBottoneNotte   = Color(t.coloreBottoneNotte);
    _opacitaBottoneNotte  = t.opacitaBottoneNotte;
  }

  // ── Helpers stagione ─────────────────────────────────────────
  int _stagione(DateTime d) {
    final m = d.month;
    if (m >= 3 && m <= 5)  return 0; // primavera
    if (m >= 6 && m <= 8)  return 1; // estate
    if (m >= 9 && m <= 11) return 2; // autunno
    return 3;                         // inverno
  }

  String _nomeStagione(DateTime d) {
    final m = d.month;
    if (m >= 3 && m <= 5)  return 'primavera';
    if (m >= 6 && m <= 8)  return 'estate';
    if (m >= 9 && m <= 11) return 'autunno';
    return 'inverno';
  }

  // ── Sfondo random ─────────────────────────────────────────────
  // stagione: se passato, filtra i file che contengono quel nome nel path
  String _sfondoRandom({bool? soloChiari, bool? soloScuri, String? stagione}) {
    List<SfondoApp> lista;
    if (stagione != null) {
      if (soloChiari == true) {
        lista = sfondiDisponibili
            .where((s) => s.isChiaro && s.pathMobile.toLowerCase().contains(stagione))
            .toList();
        if (lista.isEmpty) lista = sfondiChiari;
      } else {
        lista = sfondiDisponibili
            .where((s) => !s.isChiaro && s.pathMobile.toLowerCase().contains(stagione))
            .toList();
        if (lista.isEmpty) lista = sfondiScuri;
      }
    } else if (soloChiari == true) {
      lista = sfondiChiari;
    } else if (soloScuri == true) {
      lista = sfondiScuri;
    } else {
      lista = sfondiDisponibili;
    }
    if (lista.isEmpty) return 'chiaro_primavera';
    return lista[Random().nextInt(lista.length)].id;
  }

  void _aggiornaRandomSeNecessario(SharedPreferences prefs) {
    final now = DateTime.now();

    if (_alternanza == AlternanzaSfondo.giornoNotteRandom) {
      // Random ad ogni apertura: chiaro di giorno, scuro di notte
      _sfondoRandGiornoId = _sfondoRandom(soloChiari: true);
      _sfondoRandNotteId  = _sfondoRandom(soloScuri: true);

    } else if (_alternanza == AlternanzaSfondo.randomGiornaliero) {
      // Stesso sfondo per tutto il giorno (completamente random)
      final oggi = '${now.year}-${now.month}-${now.day}';
      if (_ultimaDataRandom != oggi) {
        _sfondoRandomId   = _sfondoRandom();
        _ultimaDataRandom = oggi;
        prefs.setString(_keySfondoRandomId,   _sfondoRandomId);
        prefs.setString(_keyUltimaDataRandom, oggi);
      } else {
        _sfondoRandomId = prefs.getString(_keySfondoRandomId) ?? _sfondoRandom();
      }

    } else if (_alternanza == AlternanzaSfondo.randomStagionale) {
      // Sfondo stagionale: chiaro di giorno, scuro di notte, della stagione attuale
      final stagione     = _stagione(now);
      final nomeStagione = _nomeStagione(now);
      if (_ultimoGiornoRandom != stagione) {
        _sfondoRandGiornoId = _sfondoRandom(soloChiari: true, stagione: nomeStagione);
        _sfondoRandNotteId  = _sfondoRandom(soloScuri: true,  stagione: nomeStagione);
        _ultimoGiornoRandom = stagione;
        prefs.setInt(_keyUltimoGiornoRandom,    stagione);
        prefs.setString(_keySfondoRandGiornoId, _sfondoRandGiornoId);
        prefs.setString(_keySfondoRandNotteId,  _sfondoRandNotteId);
      } else {
        _sfondoRandGiornoId = prefs.getString(_keySfondoRandGiornoId)
            ?? _sfondoRandom(soloChiari: true, stagione: nomeStagione);
        _sfondoRandNotteId  = prefs.getString(_keySfondoRandNotteId)
            ?? _sfondoRandom(soloScuri: true,  stagione: nomeStagione);
      }

    } else if (_alternanza == AlternanzaSfondo.randomApertura) {
      // Completamente random ad ogni apertura
      _sfondoRandomId = _sfondoRandom();
    }
  }

  String _sfondoEffettivo({required bool desktop}) {
    if (_tema == AppTema.classico) {
      return desktop
          ? 'assets/sfondo_home_desktop.jpeg'
          : 'assets/sfondo_home.jpeg';
    }
    if (_tema == AppTema.moderno) {
      if (desktop) {
        return isChiaro
            ? 'assets/sfondo_chiaro_desktop.png'
            : 'assets/sfondo_scuro_desktop.png';
      }
      return isChiaro
          ? 'assets/sfondo_chiaro.png'
          : 'assets/sfondo_scuro.png';
    }

    // Personalizzato
    final min = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
    final isGiorno = min >= _oraAlba * 60 && min < _oraTramonto * 60;

    String id;
    switch (_alternanza) {
      case AlternanzaSfondo.fisso:
        id = _sfondoFissoId;
        break;
      case AlternanzaSfondo.giornoNotte:
        id = isGiorno ? _sfondoGiornoId : _sfondoNotteId;
        break;
      case AlternanzaSfondo.giornoNotteRandom:
      // chiaro di giorno, scuro di notte, random ad ogni apertura
        id = isGiorno ? _sfondoRandGiornoId : _sfondoRandNotteId;
        break;
      case AlternanzaSfondo.randomApertura:
      case AlternanzaSfondo.randomGiornaliero:
      // stesso sfondo tutto il giorno (o ogni apertura), completamente random
        id = _sfondoRandomId;
        break;
      case AlternanzaSfondo.randomStagionale:
      // chiaro di giorno, scuro di notte, della stagione
        id = isGiorno ? _sfondoRandGiornoId : _sfondoRandNotteId;
        break;
    }

    final sfondo = sfondiDisponibili.firstWhere(
            (s) => s.id == id, orElse: () => sfondiDisponibili.first);
    return desktop && sfondo.pathDesktop != null
        ? sfondo.pathDesktop! : sfondo.pathMobile;
  }

  // ── Setter tema principale ───────────────────────────────────
  Future<void> setTemaClassico() async {
    _tema = AppTema.classico;
    _temaPersonalizzatoAttivoId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, AppTema.classico.index);
    _aggiornaTimer();
    notifyListeners();
  }

  Future<void> setTemaModerno(AppTemaModerno moderno) async {
    _tema = AppTema.moderno;
    _temaModerno = moderno;
    _temaPersonalizzatoAttivoId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, AppTema.moderno.index);
    await prefs.setInt(_keyTemaModerno, moderno.index);
    _aggiornaTimer();
    notifyListeners();
  }

  Future<void> selezionaTemaPersonalizzato(String id) async {
    final t = _temiSalvati.firstWhere((t) => t.id == id,
        orElse: () => _temaDiDefault());
    _tema = AppTema.personalizzato;
    _temaPersonalizzatoAttivoId = id;
    _applicaTema(t);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, AppTema.personalizzato.index);
    await prefs.setString(_keyTemaPersonalizzatoId, id);
    _aggiornaTimer();
    notifyListeners();
  }

  Future<void> setTema(AppTema tema) async {
    if (tema == AppTema.classico)      { await setTemaClassico(); return; }
    if (tema == AppTema.modernoChiaro) { await setTemaModerno(AppTemaModerno.chiaro); return; }
    if (tema == AppTema.modernoScuro)  { await setTemaModerno(AppTemaModerno.scuro); return; }
    if (tema == AppTema.automatico)    { await setTemaModerno(AppTemaModerno.automatico); return; }
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
    notifyListeners();
  }

  Future<void> setStileBottone(StileBottone stile) async {
    _stileBottone = stile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStileBottone, stile.index);
    notifyListeners();
  }

  Future<void> setColoreBottone(Color c) async {
    _coloreBottone = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColoreBottone, c.value);
    notifyListeners();
  }

  Future<void> setOpacitaBottone(double v) async {
    _opacitaBottone = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyOpacitaBottone, v);
    notifyListeners();
  }

  Future<void> setColoreBottoneGiorno(Color c) async {
    _coloreBottoneGiorno = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColoreBottoneGiorno, c.value);
    notifyListeners();
  }

  Future<void> setColoreBottoneNotte(Color c) async {
    _coloreBottoneNotte = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColoreBottoneNotte, c.value);
    notifyListeners();
  }

  Future<void> setOpacitaBottoneGiorno(double v) async {
    _opacitaBottoneGiorno = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyOpacitaBottoneGiorno, v);
    notifyListeners();
  }

  Future<void> setOpacitaBottoneNotte(double v) async {
    _opacitaBottoneNotte = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyOpacitaBottoneNotte, v);
    notifyListeners();
  }

  Future<void> setAlternanza(AlternanzaSfondo alternanza) async {
    _alternanza = alternanza;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAlternanza, alternanza.index);
    // Aggiorna subito i random se necessario
    if (alternanza == AlternanzaSfondo.randomApertura) {
      _sfondoRandomId = _sfondoRandom();
    } else if (alternanza == AlternanzaSfondo.giornoNotteRandom) {
      _sfondoRandGiornoId = _sfondoRandom(soloChiari: true);
      _sfondoRandNotteId  = _sfondoRandom(soloScuri: true);
      prefs.setString(_keySfondoRandGiornoId, _sfondoRandGiornoId);
      prefs.setString(_keySfondoRandNotteId,  _sfondoRandNotteId);
    } else if (alternanza == AlternanzaSfondo.randomStagionale) {
      final nomeStagione = _nomeStagione(DateTime.now());
      _sfondoRandGiornoId = _sfondoRandom(soloChiari: true, stagione: nomeStagione);
      _sfondoRandNotteId  = _sfondoRandom(soloScuri: true,  stagione: nomeStagione);
      prefs.setString(_keySfondoRandGiornoId, _sfondoRandGiornoId);
      prefs.setString(_keySfondoRandNotteId,  _sfondoRandNotteId);
    }
    notifyListeners();
  }

  Future<void> setSfondoFisso(String id) async {
    _sfondoFissoId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySfondoFissoId, id);
    notifyListeners();
  }

  Future<void> setSfondoGiorno(String id) async {
    _sfondoGiornoId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySfondoGiornoId, id);
    notifyListeners();
  }

  Future<void> setSfondoNotte(String id) async {
    _sfondoNotteId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySfondoNotteId, id);
    notifyListeners();
  }

  Future<bool> salvaTema(String nome) async {
    if (_temiSalvati.length >= _maxTemi) return false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final nuovo = TemaPersonalizzatoSalvato(
      id: id, nome: nome,
      alternanza: _alternanza,
      sfondoFissoId: _sfondoFissoId,
      sfondoGiornoId: _sfondoGiornoId,
      sfondoNotteId: _sfondoNotteId,
      stileBottone: _stileBottone,
      coloreBottone: _coloreBottone.value,
      opacitaBottone: _opacitaBottone,
      coloreBottoneGiorno: _coloreBottoneGiorno.value,
      opacitaBottoneGiorno: _opacitaBottoneGiorno,
      coloreBottoneNotte: _coloreBottoneNotte.value,
      opacitaBottoneNotte: _opacitaBottoneNotte,
    );
    _temiSalvati.add(nuovo);
    _tema = AppTema.personalizzato;
    _temaPersonalizzatoAttivoId = id;
    await _salvaTemiSuPrefs();
    notifyListeners();
    return true;
  }

  Future<void> aggiornaTema(String id, String nuovoNome) async {
    final idx = _temiSalvati.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _temiSalvati[idx].nome = nuovoNome;
    await _salvaTemiSuPrefs();
    notifyListeners();
  }

  Future<void> eliminaTema(String id) async {
    _temiSalvati.removeWhere((t) => t.id == id);
    if (_temaPersonalizzatoAttivoId == id) {
      _temaPersonalizzatoAttivoId = null;
      _tema = AppTema.classico;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTema, AppTema.classico.index);
    }
    await _salvaTemiSuPrefs();
    notifyListeners();
  }

  Future<void> _salvaTemiSuPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_temiSalvati.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTemiSalvati, jsonStr);
    await prefs.setInt(_keyTema, _tema.index);
    if (_temaPersonalizzatoAttivoId != null) {
      await prefs.setString(_keyTemaPersonalizzatoId, _temaPersonalizzatoAttivoId!);
    }
  }

  Future<void> setModerno(bool value) async {
    if (value) await setTemaModerno(AppTemaModerno.automatico);
    else await setTemaClassico();
  }

  void _aggiornaTimer() {
    _timerAutomatico?.cancel();
    if (_tema == AppTema.moderno && _temaModerno == AppTemaModerno.automatico) {
      _timerAutomatico = Timer.periodic(
          const Duration(minutes: 1), (_) => notifyListeners());
    }
  }

  @override
  void dispose() {
    _timerAutomatico?.cancel();
    super.dispose();
  }

  String get sfondoMobile  => _sfondoEffettivo(desktop: false);
  String get sfondoDesktop => _sfondoEffettivo(desktop: true);

  Color get coloreTesto {
    if (isChiaro) return const Color(0xFF2C1A0E);
    return Colors.white;
  }

  Color get coloreTestoSecondario {
    if (isChiaro) return const Color(0xFF5C3D1E);
    return Colors.white70;
  }

  Color get bottoneColore {
    if (isChiaro) return const Color(0x88FFFFFF);
    if (isScuro)  return const Color(0x33000000);
    return Colors.transparent;
  }

  Color get bottoneBordo {
    if (isChiaro) return const Color(0xAAFFFFFF);
    if (isScuro)  return const Color(0x33FFFFFF);
    return Colors.transparent;
  }

  double get gradienteTop {
    if (isChiaro) return 0.0;
    if (isScuro)  return 0.3;
    return 0.2;
  }

  double get gradienteBottom {
    if (isChiaro) return 0.08;
    if (isScuro)  return 0.6;
    return 0.3;
  }
}