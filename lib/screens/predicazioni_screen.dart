import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme_provider.dart';
import 'webview_audio_player_windows.dart';

const _kBottoneClassicoP = Color(0xFF1565C0);
const _kAttivoClassicoP = Color(0xFF0D47A1);
const _kPlayerClassicoP = Color(0xFF0D47A1);
const _kAppBarClassicoP = Color(0xFF1829E8);
const _kPlayerScuroP = Color(0xDD0A0A1A);
const _kAppBarScuroP = Color(0xCC0A0A1A);
const _kPlayerChiaroP = Color(0xDDFFFFFF);
const _kAppBarChiaroP = Color(0xCCFFFFFF);

// ── Icona cassetta SVG custom ────────────────────────────────────
class _IconaCassetta extends StatelessWidget {
  final Color colore;
  final double size;
  const _IconaCassetta({required this.colore, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.68),
      painter: _CassettaPainter(colore),
    );
  }
}

class _CassettaPainter extends CustomPainter {
  final Color colore;
  _CassettaPainter(this.colore);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = colore
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Corpo cassetta
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(rrect, paint);

    // Finestra superiore
    final finestra = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.08, w * 0.76, h * 0.35),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(finestra, paint);

    // Rocchetto sinistro
    canvas.drawCircle(Offset(w * 0.3, h * 0.72), w * 0.14, paint);
    final paintFill = Paint()..color = colore..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.3, h * 0.72), w * 0.05, paintFill);

    // Rocchetto destro
    canvas.drawCircle(Offset(w * 0.7, h * 0.72), w * 0.14, paint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.72), w * 0.05, paintFill);

    // Nastro tra rocchetti
    final path = Path()
      ..moveTo(w * 0.3 + w * 0.14, h * 0.72)
      ..lineTo(w * 0.7 - w * 0.14, h * 0.72);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CassettaPainter old) => old.colore != colore;
}

// ── Struttura gruppi ─────────────────────────────────────────────
class _GruppoPredicazione {
  final String titolo;
  final List<String> parti;
  final bool isSerie;
  final bool isCassetta; // true se ha Lato A/B
  _GruppoPredicazione({
    required this.titolo,
    required this.parti,
    required this.isSerie,
    required this.isCassetta,
  });
}

class PredicazioniScreen extends StatefulWidget {
  const PredicazioniScreen({super.key});

  @override
  State<PredicazioniScreen> createState() => _PredicazioniScreenState();
}

class _PredicazioniScreenState extends State<PredicazioniScreen> {
  static const String _baseUrl =
      'https://archive.org/download/giudicare-14/';

  static const List<String> _predicazioni = [
    'Alcuni errori della chiesa cattolico romana - La morte di gesù.mp3',
    'Cosa ti impedisce di credere.mp3',
    'Come essere felici 1 - Lato A.mp3',
    'Come essere felici 2 - Lato A.mp3',
    'Come essere felici 2 - Lato B.mp3',
    'Come essere felici 3 - Lato A.mp3',
    'Come essere felici 4 - Lato A.mp3',
    'Come essere felici 5 - Lato A.mp3',
    'Come essere felici 6 - Lato A.mp3',
    'Come essere felici 7 - Lato A.mp3',
    'Come evangelizzare 1 - lato A.mp3',
    'Come evangelizzare 1 - lato B.mp3',
    'Come evangelizzare 2 - lato A.mp3',
    'Come evangelizzare 3 - lato A.mp3',
    "Cos'è la fede - lato A.mp3",
    "Cos'è la fede - lato B.mp3",
    'Giudicare_1.mp3',
    'Giudicare_2.mp3',
    'Giudicare_3.mp3',
    'Giudicare_4.mp3',
    'Giudicare_5.mp3',
    'Giudicare_6.mp3',
    'Giudicare_7.mp3',
    'Giudicare_8.mp3',
    'Giudicare_9.mp3',
    'Giudicare_10.mp3',
    'Giudicare_11.mp3',
    'Giudicare_12.mp3',
    'Giudicare_13.mp3',
    'Giudicare_14.mp3',
    'Giudicare_15.mp3',
    'Giudicare_16.mp3',
    'Giudicare_17.mp3',
    'Giudicare_18.mp3',
    'Giudicare_19.mp3',
    'Gli elementi della fede che salva - lato A.mp3',
    'Gli elementi della fede che salva - lato B.mp3',
    "Il Patto  - 1.  L'insegnamento nel nuovo patto.mp3",
    'Il Patto - 2. Il sangue del patto.mp3',
    'Il Patto - 4. Il peccato e la coscienza.mp3',
    'Il Patto - 5. Il sacerdote e la presenza di Dio.mp3',
    'Il Patto - 6. La sottomissione e la coscienza.mp3',
    'Il Patto - 8. Chi appartiene a Dio.mp3',
    'Il Sangue di Cristo.mp3',
    'La coscienza 1 - Lato A.mp3',
    'La coscienza 1 - Lato B.mp3',
    'La coscienza 2 - Lato A.mp3',
    'La coscienza 2 - Lato B.mp3',
    'La fede ebraica Risposta a un interrogativo.mp3',
    'La donna nel matrimonio - intuizione e saggezza.mp3',
    'La legge civile, morale, religiosa - lato A.mp3',
    'La legge civile, morale, religiosa - lato B.mp3',
    'La Mia Fede1-YHWH.mp3',
    'La necessità della fede - lato A.mp3',
    'La necessità della fede - lato B.mp3',
    'La prova di una vera fede - lato A.mp3',
    'La prova di una vera fede - lato B.mp3',
    'La sofferenza e la prosperità dei malvagi.mp3',
    'Le offerte e il dare.mp3',
    "Qual'è la religione giusta - Lato A.mp3",
    "Qual'è la religione giusta - Lato B.mp3",
    "Qual'è la religione giusta 2 - Lato A.mp3",
    'Rimettere i peccati.mp3',
    'Studio parola - rema logos - lato A.mp3',
    'Studio parola - rema logos - lato B.mp3',
    'Studio sulla Fede.mp3',
    'Unità della Chiesa.mp3',
  ];
  static const Map<String, String> _nomiPersonalizzati = {
    'Cosa ti impedisce di credere.mp3': 'Cosa ti impedisce di credere?',
  };

  static const _audioServiceChannel =
  MethodChannel('com.ognitipodiinsegnamento/audio_service');
  static const _playerControlChannel =
  MethodChannel('com.ognitipodiinsegnamento/player_control_predicazioni');
  static const _nowPlayingChannel =
  MethodChannel('com.ognitipodiinsegnamento/nowplaying');

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<String> _risultati = List.from(_predicazioni);
  String? _audioAttivo;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isDownloading = false;
  Duration _posizione = Duration.zero;
  Duration _durata = Duration.zero;
  DateTime _ultimoAggiornaService = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _ultimoAggiornaPosizioneService =
  DateTime.fromMillisecondsSinceEpoch(0);

  final Set<String> _gruppiEspansi = {};

  bool get _isWindows => !kIsWeb && Platform.isWindows;
  bool get _isMacOS => !kIsWeb && Platform.isMacOS;
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  // ── Helpers ──────────────────────────────────────────────────

  bool _haLato(String filename) =>
      RegExp(r'[Ll]ato\s+[AaBb]').hasMatch(filename);

  bool _hasNumero(String filename) =>
      RegExp(r'_\d+').hasMatch(filename.replaceAll('.mp3', ''));

  // Chiave di raggruppamento
  String _chiaveGruppo(String filename) {
    String nome = filename.replaceAll('.mp3', '').toLowerCase().trim();
    // Rimuove " - lato a/b"
    nome = nome.replaceAll(RegExp(r'\s*[-–]\s*lato\s+[ab]', caseSensitive: false), '').trim();
    // Rimuove "_N" finale (Giudicare_1 → giudicare)
    nome = nome.replaceAll(RegExp(r'_\d+$'), '').trim();
    // Rimuove " N" finale numerico (Come evangelizzare 1 → come evangelizzare)
    nome = nome.replaceAll(RegExp(r'\s+\d+$'), '').trim();
    // Rimuove " - N. titolo" (Il Patto - 2. Il sangue → il patto)
    nome = nome.replaceAll(RegExp(r'\s*[-–]\s*\d+\.\s*.+$'), '').trim();
    return nome;
  }

  String _titoloGruppo(String filename) {
    String nome = filename.replaceAll('.mp3', '').trim();
    nome = nome.replaceAll(RegExp(r'\s*[-–]\s*[Ll]ato\s+[AaBb]', caseSensitive: false), '').trim();
    nome = nome.replaceAll(RegExp(r'_\d+$'), '').trim();
    nome = nome.replaceAll(RegExp(r'\s+\d+$'), '').trim();
    // Rimuove " - N. titolo" (Il Patto - 2. Il sangue → Il Patto)
    nome = nome.replaceAll(RegExp(r'\s*[-–]\s*\d+\.\s*.+$'), '').trim();
    return nome;
  }

  // Etichetta della singola parte nell'accordion
  String _etichettaParte(String filename) {
    final nome = filename.replaceAll('.mp3', '');
    // "Come evangelizzare 1 - lato A" → "Cassetta 1 - Lato A"
    final numLato = RegExp(r'(\d+)\s*[-–]\s*[Ll]ato\s+([AaBb])').firstMatch(nome);
    if (numLato != null) return 'Cassetta ${numLato.group(1)} - Lato ${numLato.group(2)!.toUpperCase()}';
    // Solo lato senza numero → "Cassetta - Lato A"
    final soloLato = RegExp(r'[Ll]ato\s+([AaBb])').firstMatch(nome);
    if (soloLato != null) return 'Cassetta - Lato ${soloLato.group(1)!.toUpperCase()}';
    // Giudicare_N → "Parte N"
    final numUnder = RegExp(r'_(\d+)$').firstMatch(nome);
    if (numUnder != null) return 'Parte ${numUnder.group(1)}';
    // "Il Patto  - 1.  L'insegnamento..." → "1. L'insegnamento..."
    final numTitolo = RegExp(r'[-–]\s*(\d+)\.\s*(.+)$').firstMatch(nome);
    if (numTitolo != null) return '${numTitolo.group(1)}. ${numTitolo.group(2)!.trim()}';
    return nome;
  }

  List<_GruppoPredicazione> _buildGruppi(List<String> lista) {
    final Map<String, List<String>> map = {};
    final List<String> ordine = [];

    for (final f in lista) {
      final chiave = _chiaveGruppo(f);
      if (!map.containsKey(chiave)) {
        map[chiave] = [];
        ordine.add(chiave);
      }
      map[chiave]!.add(f);
    }

    return ordine.map((chiave) {
      final parti = map[chiave]!;
      final isSerie = parti.length > 1 || _haLato(parti.first) || _hasNumero(parti.first);
      final isCassetta = parti.any((p) => _haLato(p));
      final titolo = _titoloGruppo(parti.first);
      return _GruppoPredicazione(
        titolo: titolo,
        parti: parti,
        isSerie: isSerie,
        isCassetta: isCassetta,
      );
    }).toList();
  }

  String _displayName(String filename) =>
      _nomiPersonalizzati[filename] ?? filename.replaceAll('.mp3', '');

  @override
  void initState() {
    super.initState();
    if (!_isWindows) {
      _configuraAudioSession();
      if (!kIsWeb) {
        _playerControlChannel.setMethodCallHandler((call) async {
          if (!mounted) return;
          switch (call.method) {
            case 'play': await _player.play(); break;
            case 'pause': await _player.pause(); break;
            case 'togglePlayPause':
              if (_isPlaying) await _player.pause();
              else await _player.play();
              break;
            case 'seekTo':
              final posMs = call.arguments as int?;
              if (posMs != null) await _player.seek(Duration(milliseconds: posMs));
              break;
          }
        });
      }

      _player.playerStateStream.listen((state) {
        if (mounted) {
          final wasPlaying = _isPlaying;
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
          if (state.playing != wasPlaying && _audioAttivo != null) {
            if (!kIsWeb) _aggiornaService(_displayName(_audioAttivo!), state.playing);
            if (_isIOS || _isMacOS) _aggiornaNowPlaying(_displayName(_audioAttivo!), state.playing);
          }
        }
      });

      _player.positionStream.listen((pos) {
        if (mounted) {
          setState(() => _posizione = pos);
          final now = DateTime.now();
          if (now.difference(_ultimoAggiornaPosizioneService).inSeconds >= 5 &&
              _audioAttivo != null && _isPlaying) {
            _ultimoAggiornaPosizioneService = now;
            if (!kIsWeb && Platform.isAndroid) _aggiornaPosizioneService(pos, _durata);
            if (_isIOS || _isMacOS) _aggiornaNowPlaying(_displayName(_audioAttivo!), _isPlaying);
          }
        }
      });

      _player.durationStream.listen((dur) {
        if (mounted) setState(() => _durata = dur ?? Duration.zero);
      });

      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && mounted) {
          setState(() { _isPlaying = false; _posizione = Duration.zero; });
          _player.seek(Duration.zero);
          _player.stop();
          if (!kIsWeb) _fermaService();
          if (_isIOS || _isMacOS) _nowPlayingChannel.invokeMethod('clear');
        }
      });
    }
  }

  Future<void> _configuraAudioSession() async {
    if (kIsWeb) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> _avviaService(String titolo) async {
    if (kIsWeb) return;
    try { await _audioServiceChannel.invokeMethod('startService', {'title': titolo, 'isPlaying': true}); }
    catch (e) { debugPrint('Errore avvio service: $e'); }
  }

  Future<void> _aggiornaService(String titolo, bool isPlaying) async {
    if (kIsWeb) return;
    final now = DateTime.now();
    if (now.difference(_ultimoAggiornaService).inMilliseconds < 200) return;
    _ultimoAggiornaService = now;
    try { await _audioServiceChannel.invokeMethod('updateService', {'title': titolo, 'isPlaying': isPlaying}); }
    catch (e) { debugPrint('Errore aggiornamento service: $e'); }
  }

  Future<void> _aggiornaPosizioneService(Duration posizione, Duration durata) async {
    try {
      await _audioServiceChannel.invokeMethod('updatePosition', {
        'positionMs': posizione.inMilliseconds, 'durationMs': durata.inMilliseconds,
      });
    } catch (e) { debugPrint('Errore aggiornamento posizione: $e'); }
  }

  Future<void> _aggiornaNowPlaying(String titolo, bool isPlaying) async {
    if (!(_isIOS || _isMacOS)) return;
    try {
      await _nowPlayingChannel.invokeMethod('update', {
        'title': titolo, 'isPlaying': isPlaying,
        'positionMs': _posizione.inMilliseconds, 'durationMs': _durata.inMilliseconds,
      });
    } catch (e) { debugPrint('Errore NowPlaying: $e'); }
  }

  Future<void> _fermaService() async {
    if (kIsWeb) return;
    try { await _audioServiceChannel.invokeMethod('stopService'); }
    catch (e) { debugPrint('Errore stop service: $e'); }
  }

  Future<void> _scarica(String filename) async {
    final url = Uri.encodeFull(_baseUrl + filename);
    if (kIsWeb || _isIOS || _isMacOS || _isWindows) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await _audioServiceChannel.invokeMethod('downloadPodcast', {
        'url': url, 'filename': filename, 'title': _displayName(filename),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Download avviato: ${_displayName(filename)}'),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) { debugPrint('Errore download: $e'); }
    finally { if (mounted) setState(() => _isDownloading = false); }
  }

  @override
  void dispose() {
    if (!_isWindows) {
      if (!kIsWeb) _fermaService();
      if (_isIOS || _isMacOS) _nowPlayingChannel.invokeMethod('clear');
      _player.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _cerca(String query) {
    query = query.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _risultati = List.from(_predicazioni);
      } else {
        _risultati = _predicazioni
            .where((p) => _displayName(p).toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _riproduci(String filename) async {
    if (_isWindows) {
      setState(() => _audioAttivo = filename);
      return;
    }
    try {
      if (_audioAttivo == filename) {
        if (_isPlaying) await _player.pause();
        else await _player.play();
        return;
      }
      setState(() {
        _audioAttivo = filename;
        _isLoading = true;
        _posizione = Duration.zero;
        _durata = Duration.zero;
      });
      final url = Uri.encodeFull(_baseUrl + filename);
      if (!kIsWeb && !(_isIOS || _isMacOS)) await _avviaService(_displayName(filename));
      await _player.setUrl(url);
      if (kIsWeb) { _player.play(); } else { await _player.play(); }
      if (_isIOS || _isMacOS) await _aggiornaNowPlaying(_displayName(filename), true);
    } catch (e, stack) {
      debugPrint('ERRORE RIPRODUZIONE: $e\nSTACK: $stack');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella riproduzione')));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Widget icona nel player ──────────────────────────────────
  Widget _iconaPlayer(String filename, Color colore) {
    if (_haLato(filename)) {
      return _IconaCassetta(colore: colore, size: 22);
    }
    return Icon(Icons.mic_rounded, size: 18, color: colore);
  }

  Widget _iconaRiga(String filename, Color colore, {double size = 20}) {
    if (_haLato(filename)) {
      return _IconaCassetta(colore: colore, size: size);
    }
    return Icon(Icons.mic_rounded, size: size * 0.8, color: colore);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final tema = provider.temaImpostato;
    final isModerno = tema != AppTema.classico;
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final sfondo = isDesktop ? provider.sfondoDesktop : provider.sfondoMobile;
    final fontSize = provider.fontSizeBottone;

    final Color kAttivoColore;
    final Color kPlayerColore;
    final Color kAppBarColore;
    final Color kTestoColore;
    final Color kTestoSecColore;
    final Color kSliderAttivo;
    final Color kSliderInattivo;
    final Color kSearchFill;
    final Color kSearchBordo;
    final Color kDivisoreColore;
    final Color kSfondoRiga;
    final Color kBottoneColore;
    final Color kBottoneBordo;

    switch (tema) {
      case AppTema.modernoScuro:
        kBottoneColore = Colors.transparent;
        kBottoneBordo = Colors.transparent;
        kAttivoColore = Colors.white.withOpacity(0.08);
        kPlayerColore = _kPlayerScuroP;
        kAppBarColore = _kPlayerScuroP;
        kTestoColore = Colors.white;
        kTestoSecColore = Colors.white60;
        kSliderAttivo = Colors.white;
        kSliderInattivo = Colors.white30;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.black.withOpacity(0.25);
        kSearchFill = provider.coloreTestoBottone.withOpacity(0.08);
        kSearchBordo = provider.coloreTestoBottone.withOpacity(0.3);
        break;
      case AppTema.modernoChiaro:
        kBottoneColore = Colors.transparent;
        kBottoneBordo = Colors.transparent;
        kAttivoColore = Colors.black.withOpacity(0.08);
        kPlayerColore = _kPlayerChiaroP;
        kAppBarColore = _kPlayerChiaroP;
        kTestoColore = const Color(0xFF1A0A00);
        kTestoSecColore = const Color(0xFF5C3D1E);
        kSliderAttivo = const Color(0xFF7B4F2E);
        kSliderInattivo = const Color(0xFFD4A574);
        kDivisoreColore = const Color(0x445C3D1E);
        kSfondoRiga = Colors.white.withOpacity(0.45);
        kSearchFill = Colors.black.withOpacity(0.05);
        kSearchBordo = const Color(0x445C3D1E);
        break;
      default:
        kBottoneColore = _kBottoneClassicoP;
        kBottoneBordo = _kBottoneClassicoP;
        kAttivoColore = _kAttivoClassicoP;
        kPlayerColore = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo : _kPlayerClassicoP;
        kAppBarColore = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo.withOpacity(provider.opacitaBottoneAttiva)
            : _kAppBarClassicoP;
        kTestoColore = provider.isPersonalizzato
            ? provider.coloreTestoBottone : Colors.white;
        kTestoSecColore = provider.isPersonalizzato
            ? provider.coloreTestoBottone.withOpacity(0.7) : Colors.white70;
        kSliderAttivo = Colors.white;
        kSliderInattivo = Colors.white30;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.transparent;
        kSearchFill = provider.coloreTestoBottone.withOpacity(0.08);
        kSearchBordo = provider.coloreTestoBottone.withOpacity(0.3);
        break;
    }

    final bool mostraPlayerWindows = _isWindows && _audioAttivo != null;
    final bool mostraPlayerFlutter = !_isWindows && _audioAttivo != null;
    final gruppi = _buildGruppi(_risultati);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kAppBarColore,
        foregroundColor: kTestoColore,
        elevation: 0,
        title: Text('Predicazioni',
            style: TextStyle(color: kTestoColore,
                fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kTestoColore),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(sfondo), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(provider.gradienteTop),
                Colors.black.withOpacity(provider.gradienteBottom),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Column(
                              children: [
                                Icon(Icons.record_voice_over_rounded,
                                    color: kTestoSecColore, size: 36),
                                const SizedBox(height: 8),
                                Text('Predicazioni di Ellero Balzani',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic, color: kTestoColore,
                                      shadows: tema == AppTema.modernoChiaro
                                          ? [] : const [Shadow(blurRadius: 6, color: Colors.black54)],
                                    )),
                                const SizedBox(height: 4),
                                Text('${_risultati.length} predicazioni',
                                    style: TextStyle(fontSize: 13, color: kTestoSecColore)),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _controller,
                                  onChanged: _cerca,
                                  style: TextStyle(color: kTestoColore),
                                  decoration: InputDecoration(
                                    hintText: 'Cerca predicazioni...',
                                    hintStyle: TextStyle(color: kTestoSecColore),
                                    prefixIcon: Icon(Icons.search, color: kTestoSecColore),
                                    suffixIcon: _controller.text.isNotEmpty
                                        ? IconButton(
                                        icon: Icon(Icons.clear, color: kTestoSecColore),
                                        onPressed: () { _controller.clear(); _cerca(''); })
                                        : null,
                                    filled: true,
                                    fillColor: kSearchFill,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kSearchBordo, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: kTestoColore, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        gruppi.isEmpty
                            ? SliverFillRemaining(
                            child: Center(child: Text('Nessun risultato',
                                style: TextStyle(color: kTestoSecColore, fontSize: 16))))
                            : SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16,
                              _audioAttivo != null ? 8 : 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, gIdx) {
                                final gruppo = gruppi[gIdx];
                                final isUltimoGruppo = gIdx == gruppi.length - 1;
                                final isEspanso = _gruppiEspansi.contains(gruppo.titolo);
                                final haAttivoInGruppo = gruppo.parti.any((p) => p == _audioAttivo);

                                if (!gruppo.isSerie) {
                                  // ── Singolo ──────────────────────────
                                  final file = gruppo.parti.first;
                                  final isAttivo = _audioAttivo == file;

                                  if (isModerno) {
                                    return Container(
                                      color: isAttivo ? kAttivoColore : kSfondoRiga,
                                      child: Column(
                                        children: [
                                          IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                InkWell(
                                                  onTap: () => _riproduci(file),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 14),
                                                    child: isAttivo && _isLoading && !_isWindows
                                                        ? SizedBox(width: 22, height: 22,
                                                        child: CircularProgressIndicator(
                                                            color: kTestoColore, strokeWidth: 2))
                                                        : _iconaRiga(file,
                                                        isAttivo ? kTestoColore : kTestoSecColore,
                                                        size: 22),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () => _riproduci(file),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 14, horizontal: 4),
                                                      child: Text(_displayName(file),
                                                          style: TextStyle(
                                                            color: kTestoColore,
                                                            fontSize: fontSize,
                                                            fontWeight: isAttivo
                                                                ? FontWeight.bold : FontWeight.normal,
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => _scarica(file),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 14),
                                                    child: Icon(Icons.download_rounded,
                                                        size: 18, color: kTestoSecColore),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isUltimoGruppo)
                                            Divider(height: 1, thickness: 1, color: kDivisoreColore),
                                        ],
                                      ),
                                    );
                                  } else {
                                    final pColore  = provider.isPersonalizzato
                                        ? provider.coloreBottoneAttivo : _kBottoneClassicoP;
                                    final pOpacita = provider.isPersonalizzato
                                        ? provider.opacitaBottoneAttiva : 0.92;
                                    final pRadius  = provider.isPersonalizzato
                                        ? provider.radiusBottone : 12.0;
                                    final pOutline = provider.isPersonalizzato && provider.isStileOutline;
                                    final pLista   = provider.isPersonalizzato && provider.isStileLista;
                                    final testoC = pOutline ? pColore : provider.coloreTestoBottone;

                                    if (pLista) {
                                      return Column(children: [
                                        InkWell(
                                          onTap: () => _riproduci(file),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 14),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _iconaRiga(file, kTestoSecColore, size: 20),
                                                const SizedBox(width: 12),
                                                Expanded(child: Text(
                                                  _displayName(file),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: kTestoColore,
                                                      fontSize: fontSize),
                                                )),
                                                InkWell(
                                                  onTap: () => _scarica(file),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Icon(Icons.download_rounded,
                                                        size: 18, color: kTestoSecColore),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isUltimoGruppo)
                                          Divider(height: 1, thickness: 1, color: kDivisoreColore),
                                      ]);
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Container(
                                        decoration: pOutline ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(pRadius),
                                          border: Border.all(color: pColore, width: 1.5),
                                        ) : null,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(pRadius),
                                          child: Material(
                                            color: pOutline ? Colors.transparent
                                                : pColore.withOpacity(isAttivo ? 1.0 : pOpacita),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () => _riproduci(file),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 12, vertical: 14),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            _iconaRiga(file, testoC, size: 16),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                _displayName(file).toUpperCase(),
                                                                textAlign: TextAlign.center,
                                                                softWrap: true,
                                                                style: TextStyle(
                                                                  fontSize: fontSize,
                                                                  color: testoC,
                                                                  letterSpacing: 0.3,
                                                                  fontWeight: isAttivo
                                                                      ? FontWeight.bold : FontWeight.w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(width: 1,
                                                      color: pOutline ? pColore : pColore.withOpacity(pOpacita)),
                                                  InkWell(
                                                    onTap: () => _scarica(file),
                                                    child: SizedBox(
                                                      width: 44,
                                                      child: Center(
                                                        child: Icon(Icons.download_rounded,
                                                            size: 18, color: testoC),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  // ── Serie accordion ───────────────────
                                  if (isModerno) {
                                    return Container(
                                      color: kSfondoRiga,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () => setState(() {
                                              if (isEspanso) _gruppiEspansi.remove(gruppo.titolo);
                                              else _gruppiEspansi.add(gruppo.titolo);
                                            }),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 14),
                                              child: Row(
                                                children: [
                                                  _iconaRiga(gruppo.parti.first,
                                                      haAttivoInGruppo ? kTestoColore : kTestoSecColore,
                                                      size: 20),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(gruppo.titolo,
                                                            style: TextStyle(
                                                              color: kTestoColore,
                                                              fontSize: fontSize,
                                                              fontWeight: haAttivoInGruppo
                                                                  ? FontWeight.bold : FontWeight.normal,
                                                            )),
                                                        Text('${gruppo.parti.length} parti',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: kTestoSecColore)),
                                                      ],
                                                    ),
                                                  ),
                                                  AnimatedRotation(
                                                    turns: isEspanso ? 0.5 : 0,
                                                    duration: const Duration(milliseconds: 200),
                                                    child: Icon(Icons.keyboard_arrow_down_rounded,
                                                        color: kTestoSecColore, size: 22),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          AnimatedSize(
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            child: isEspanso
                                                ? Column(
                                              children: gruppo.parti.map((parte) {
                                                final isAttivo = _audioAttivo == parte;
                                                return Container(
                                                  color: isAttivo ? kAttivoColore : kSfondoRiga,
                                                  child: IntrinsicHeight(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                      children: [
                                                        Container(
                                                          width: 3,
                                                          margin: const EdgeInsets.only(
                                                              left: 20, right: 8,
                                                              top: 6, bottom: 6),
                                                          decoration: BoxDecoration(
                                                            color: isAttivo
                                                                ? kTestoColore
                                                                : kTestoSecColore.withOpacity(0.4),
                                                            borderRadius: BorderRadius.circular(2),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 6, vertical: 12),
                                                          child: _iconaRiga(parte,
                                                              isAttivo ? kTestoColore : kTestoSecColore,
                                                              size: 16),
                                                        ),
                                                        InkWell(
                                                          onTap: () => _riproduci(parte),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 6, vertical: 12),
                                                            child: isAttivo && _isLoading && !_isWindows
                                                                ? SizedBox(width: 20, height: 20,
                                                                child: CircularProgressIndicator(
                                                                    color: kTestoColore, strokeWidth: 2))
                                                                : Icon(
                                                                isAttivo && _isPlaying && !_isWindows
                                                                    ? Icons.pause_circle_outline_rounded
                                                                    : Icons.play_circle_outline_rounded,
                                                                size: 22,
                                                                color: isAttivo
                                                                    ? kTestoColore : kTestoSecColore),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () => _riproduci(parte),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 12),
                                                              child: Text(
                                                                _etichettaParte(parte),
                                                                style: TextStyle(
                                                                  color: isAttivo
                                                                      ? kTestoColore : kTestoSecColore,
                                                                  fontSize: fontSize - 1,
                                                                  fontWeight: isAttivo
                                                                      ? FontWeight.bold : FontWeight.normal,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () => _scarica(parte),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 12, vertical: 12),
                                                            child: Icon(Icons.download_rounded,
                                                                size: 16, color: kTestoSecColore),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                                : const SizedBox.shrink(),
                                          ),
                                          if (!isUltimoGruppo)
                                            Divider(height: 1, thickness: 1, color: kDivisoreColore),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Classico accordion
                                    final pColore2  = provider.isPersonalizzato
                                        ? provider.coloreBottoneAttivo : _kBottoneClassicoP;
                                    final pOpacita2 = provider.isPersonalizzato
                                        ? provider.opacitaBottoneAttiva : 0.92;
                                    final pRadius2  = provider.isPersonalizzato
                                        ? provider.radiusBottone : 12.0;
                                    final pOutline2 = provider.isPersonalizzato && provider.isStileOutline;
                                    final pLista2   = provider.isPersonalizzato && provider.isStileLista;
                                    final testoC2 = pOutline2 ? pColore2 : provider.coloreTestoBottone;

                                    if (pLista2) {
                                      return Container(
                                        color: kSfondoRiga,
                                        child: Column(children: [
                                          InkWell(
                                            onTap: () => setState(() {
                                              if (isEspanso) _gruppiEspansi.remove(gruppo.titolo);
                                              else _gruppiEspansi.add(gruppo.titolo);
                                            }),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 14),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  _iconaRiga(gruppo.parti.first,
                                                      haAttivoInGruppo ? kTestoColore : kTestoSecColore,
                                                      size: 20),
                                                  const SizedBox(width: 12),
                                                  Expanded(child: Text(gruppo.titolo,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: kTestoColore,
                                                          fontSize: fontSize,
                                                          fontWeight: haAttivoInGruppo
                                                              ? FontWeight.bold : FontWeight.normal))),
                                                  AnimatedRotation(
                                                    turns: isEspanso ? 0.5 : 0,
                                                    duration: const Duration(milliseconds: 200),
                                                    child: Icon(Icons.keyboard_arrow_down_rounded,
                                                        color: kTestoSecColore, size: 22),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          AnimatedSize(
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            child: isEspanso
                                                ? Column(children: gruppo.parti.map((parte) {
                                              final isAttivo = _audioAttivo == parte;
                                              return Column(children: [
                                                InkWell(
                                                  onTap: () => _riproduci(parte),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 4, vertical: 12),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        _iconaRiga(parte,
                                                            isAttivo ? kTestoColore : kTestoSecColore,
                                                            size: 16),
                                                        const SizedBox(width: 8),
                                                        Text(_etichettaParte(parte),
                                                            style: TextStyle(
                                                                color: isAttivo
                                                                    ? kTestoColore : kTestoSecColore,
                                                                fontSize: fontSize - 1)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Divider(height: 1, color: kDivisoreColore),
                                              ]);
                                            }).toList())
                                                : const SizedBox.shrink(),
                                          ),
                                          if (!isUltimoGruppo)
                                            Divider(height: 1, thickness: 1, color: kDivisoreColore),
                                        ]),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Container(
                                        decoration: pOutline2 ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(pRadius2),
                                          border: Border.all(color: pColore2, width: 1.5),
                                        ) : null,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(pRadius2),
                                          child: Material(
                                            color: pOutline2 ? Colors.transparent
                                                : pColore2.withOpacity(haAttivoInGruppo ? 1.0 : pOpacita2),
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () => setState(() {
                                                    if (isEspanso) _gruppiEspansi.remove(gruppo.titolo);
                                                    else _gruppiEspansi.add(gruppo.titolo);
                                                  }),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 14),
                                                    child: Row(
                                                      children: [
                                                        _iconaRiga(gruppo.parti.first,
                                                            testoC2, size: 18),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            gruppo.titolo.toUpperCase(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: fontSize,
                                                              color: testoC2,
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 0.3,
                                                            ),
                                                          ),
                                                        ),
                                                        Text('${gruppo.parti.length} parti',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: testoC2)),
                                                        const SizedBox(width: 6),
                                                        AnimatedRotation(
                                                          turns: isEspanso ? 0.5 : 0,
                                                          duration: const Duration(milliseconds: 200),
                                                          child: Icon(Icons.keyboard_arrow_down_rounded,
                                                              color: testoC2, size: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                AnimatedSize(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                  child: isEspanso
                                                      ? Column(
                                                    children: gruppo.parti.map((parte) {
                                                      final isAttivo = _audioAttivo == parte;
                                                      return IntrinsicHeight(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.stretch,
                                                          children: [
                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () => _riproduci(parte),
                                                                child: Container(
                                                                  color: isAttivo
                                                                      ? pColore2.withOpacity(1.0)
                                                                      : pOutline2 ? Colors.transparent
                                                                      : Colors.black.withOpacity(0.15),
                                                                  padding: const EdgeInsets.symmetric(
                                                                      horizontal: 16, vertical: 12),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                    children: [
                                                                      _iconaRiga(parte,
                                                                          testoC2, size: 14),
                                                                      const SizedBox(width: 6),
                                                                      if (isAttivo && _isLoading && !_isWindows)
                                                                        SizedBox(width: 18, height: 18,
                                                                            child: CircularProgressIndicator(
                                                                                color: kTestoColore, strokeWidth: 2))
                                                                      else
                                                                        Icon(
                                                                            isAttivo && _isPlaying && !_isWindows
                                                                                ? Icons.pause_circle_outline_rounded
                                                                                : Icons.play_circle_outline_rounded,
                                                                            size: 18, color: testoC2),
                                                                      const SizedBox(width: 8),
                                                                      Text(
                                                                        _etichettaParte(parte).toUpperCase(),
                                                                        style: TextStyle(
                                                                          fontSize: fontSize - 1,
                                                                          color: testoC2,
                                                                          fontWeight: isAttivo
                                                                              ? FontWeight.bold : FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () => _scarica(parte),
                                                              child: Container(
                                                                width: 44,
                                                                color: isAttivo
                                                                    ? pColore2.withOpacity(1.0)
                                                                    : pOutline2 ? Colors.transparent
                                                                    : Colors.black.withOpacity(0.15),
                                                                child: Center(
                                                                  child: Icon(Icons.download_rounded,
                                                                      size: 16, color: testoC2),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              childCount: gruppi.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Player Windows
              if (mostraPlayerWindows) ...[
                Container(
                  color: kPlayerColore,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _scarica(_audioAttivo!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.download_rounded, color: kTestoSecColore, size: 18),
                              const SizedBox(width: 4),
                              Text('Scarica', style: TextStyle(color: kTestoSecColore, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                WebviewAudioPlayerWindows(
                  audioUrl: Uri.encodeFull(_baseUrl + _audioAttivo!),
                  titolo: _displayName(_audioAttivo!),
                  playerColore: kPlayerColore,
                  testoColore: kTestoColore,
                  testoSecColore: kTestoSecColore,
                ),
              ],
              // Player Flutter
              if (mostraPlayerFlutter)
                Container(
                  decoration: BoxDecoration(
                    color: kPlayerColore,
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  padding: EdgeInsets.fromLTRB(
                      16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _iconaPlayer(_audioAttivo!, kTestoSecColore),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_displayName(_audioAttivo!),
                                textAlign: TextAlign.center,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: kTestoColore,
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          GestureDetector(
                            onTap: () => _scarica(_audioAttivo!),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _isDownloading
                                  ? SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      color: kTestoSecColore, strokeWidth: 2))
                                  : Icon(Icons.download_rounded,
                                  color: kTestoSecColore, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: kSliderAttivo,
                          inactiveTrackColor: kSliderInattivo,
                          thumbColor: kTestoColore,
                          overlayColor: kTestoColore.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _durata.inMilliseconds > 0
                              ? _posizione.inMilliseconds
                              .clamp(0, _durata.inMilliseconds).toDouble() : 0,
                          min: 0,
                          max: _durata.inMilliseconds > 0
                              ? _durata.inMilliseconds.toDouble() : 1,
                          onChanged: (val) =>
                              _player.seek(Duration(milliseconds: val.toInt())),
                        ),
                      ),
                      Row(
                        children: [
                          Text(_formatDuration(_posizione),
                              style: TextStyle(color: kTestoSecColore, fontSize: 11)),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.replay_10, color: kTestoSecColore, size: 26),
                            onPressed: () {
                              final newPos = _posizione - const Duration(seconds: 10);
                              _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
                            },
                          ),
                          _isLoading
                              ? SizedBox(width: 40, height: 40,
                              child: CircularProgressIndicator(
                                  color: kTestoColore, strokeWidth: 2))
                              : IconButton(
                              icon: Icon(_isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                                  color: kTestoColore, size: 44),
                              onPressed: () {
                                if (_isPlaying) _player.pause();
                                else _player.play();
                              }),
                          IconButton(
                            icon: Icon(Icons.forward_10, color: kTestoSecColore, size: 26),
                            onPressed: () {
                              final newPos = _posizione + const Duration(seconds: 10);
                              if (newPos < _durata) _player.seek(newPos);
                            },
                          ),
                          const Spacer(),
                          Text(_formatDuration(_durata),
                              style: TextStyle(color: kTestoSecColore, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}