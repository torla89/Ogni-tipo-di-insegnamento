import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categorie.dart';
import '../theme_provider.dart';
import 'pdf_viewer_screen.dart';
import 'webview_audio_player_windows.dart';

String _titoloVisualizzato(String titolo) {
  const Map<String, String> override = {
    'chiedere perdono o confessare il peccato': 'chiedere perdono o confessare il peccato?',
    'cosa vorresti che fosse scritto sulla tua epigrafe': 'cosa vorresti che fosse scritto sulla tua epigrafe?',
    'credenti o discepoli': 'credenti o discepoli?',
    'Perché la legge': 'Perché la legge?',
    'sono io chiamato a predicare': 'sono io chiamato a predicare?',
    'Chi può rimettere i peccati': 'Chi può rimettere i peccati?',
    'Chi sono i pagani': 'Chi sono i pagani?',
    'Di che cosa hai paura': 'Di che cosa hai paura?',
    'dove era il codice stradale': 'dove era il codice stradale?',
    'perché predicare il vangelo se gli uomini sono salvati senza': 'perché predicare il vangelo se gli uomini sono salvati senza?',
    'Fede sì, ma in che cosa': 'Fede sì, ma in che cosa?',
    'Dio mio, Dio mio, perchè mi hai abbandonato': 'Dio mio, Dio mio, perchè mi hai abbandonato?',
    'e se Gesù non fosse risorto': 'e se Gesù non fosse risorto?',
    'gesù si idenfica con JHWH oppure lo è': 'gesù si idenfica con JHWH oppure lo è?',
    'Perché servire Dio': 'Perché servire Dio?',
    'l\'unione degli omosessuali è naturale': 'l\'unione degli omosessuali è naturale?',
    'L\'unione dei gay è un matrimonio': 'L\'unione dei gay è un matrimonio?',
    'Ma perché quell\'uno lo fece': 'Ma perché quell\'uno lo fece?',
    'Non ti basta il Signore': 'Non ti basta il Signore?',
    'nudo integrale si o no': 'nudo integrale si o no?',
    'Sposi vinti o convinti': 'Sposi vinti o convinti?',
    'Spirito Santo o spirito maligno': 'Spirito Santo o spirito maligno?',
  };
  return override[titolo] ?? titolo;
}

const _kBottoneClassico = Color(0xFF1829E8);
const _kAttivoClassico = Color(0xFF0F1BA0);
const _kPlayerClassico = Color(0xFF0F1BA0);
const _kAppBarClassico = Color(0xFF1829E8);
const _kPlayerScuro = Color(0xDD0A0A1A);
const _kAppBarScuro = Color(0xCC0A0A1A);
const _kPlayerChiaro = Color(0xDDFFFFFF);
const _kAppBarChiaro = Color(0xCCFFFFFF);

class CercaScreen extends StatefulWidget {
  const CercaScreen({super.key});

  @override
  State<CercaScreen> createState() => _CercaScreenState();
}

class _CercaScreenState extends State<CercaScreen> {
  static const String _baseUrl =
      'https://archive.org/download/ogni-tipo-di-insegnamento-letture-fixed/';

  static const _audioServiceChannel =
  MethodChannel('com.ognitipodiinsegnamento/audio_service');
  static const _playerControlChannel =
  MethodChannel('com.ognitipodiinsegnamento/player_control_cerca');
  static const _nowPlayingChannel =
  MethodChannel('com.ognitipodiinsegnamento/nowplaying');

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<_RisultatoCerca> _risultati = [];
  String? _audioAttivo;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isDownloading = false;
  Duration _posizione = Duration.zero;
  Duration _durata = Duration.zero;
  DateTime _ultimoAggiornaService = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _ultimoAggiornaPosizioneService =
  DateTime.fromMillisecondsSinceEpoch(0);

  bool get _isWindows => !kIsWeb && Platform.isWindows;
  bool get _isMacOS => !kIsWeb && Platform.isMacOS;
  bool get _isIOS => !kIsWeb && Platform.isIOS;

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

  Future<void> _scarica(String nomePdf) async {
    final filename = _nomeAudio(nomePdf);
    final url = Uri.encodeFull(_baseUrl + filename);
    // Web, iOS, macOS, Windows → apri nel browser
    if (kIsWeb || _isIOS || _isMacOS || _isWindows) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await _audioServiceChannel.invokeMethod('downloadPodcast', {
        'url': url, 'filename': filename, 'title': _displayName(nomePdf),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download avviato: ${_displayName(nomePdf)}'),
              duration: const Duration(seconds: 2)));
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

  String _displayName(String nomePdf) => nomePdf.replaceAll('.pdf', '');
  String _nomeAudio(String nomePdf) => nomePdf.replaceAll('.pdf', '.mp3');

  Future<void> _riproduci(String nomePdf) async {
    if (_isWindows) {
      setState(() => _audioAttivo = nomePdf);
      return;
    }
    final filename = _nomeAudio(nomePdf);
    final titolo = _displayName(nomePdf);
    try {
      if (_audioAttivo == nomePdf) {
        if (_isPlaying) await _player.pause();
        else await _player.play();
        return;
      }
      setState(() {
        _audioAttivo = nomePdf;
        _isLoading = true;
        _posizione = Duration.zero;
        _durata = Duration.zero;
      });
      final url = Uri.encodeFull(_baseUrl + filename);
      if (!kIsWeb && !(_isIOS || _isMacOS)) await _avviaService(titolo);
      await _player.setUrl(url);
      // Avvia senza await su web per aggirare la restrizione autoplay del browser
      if (kIsWeb) {
        _player.play();
      } else {
        await _player.play();
      }
      if (_isIOS || _isMacOS) await _aggiornaNowPlaying(titolo, true);
    } catch (e) {
      debugPrint('ERRORE RIPRODUZIONE: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella riproduzione')));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _cerca(String query) {
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _risultati = []);
      return;
    }
    final risultati = <_RisultatoCerca>[];
    for (final cat in categorie) {
      for (final voce in cat.voci) {
        if (voce.titolo.toLowerCase().contains(query) ||
            voce.nomePdf.toLowerCase().contains(query)) {
          risultati.add(_RisultatoCerca(categoria: cat.titolo, voce: voce));
        }
      }
    }
    setState(() => _risultati = risultati);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final tema = provider.temaImpostato;
    final isModerno = tema != AppTema.classico;
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final fontSize = provider.fontSizeBottone;
    final maxWidth = isDesktop ? 800.0 : double.infinity;
    final paddingH = isDesktop ? 0.0 : 16.0;
    final sfondo = isDesktop ? provider.sfondoDesktop : provider.sfondoMobile;

    final Color kBottoneColore;
    final Color kBottoneBordo;
    final Color kAttivoColore;
    final Color kPlayerColore;
    final Color kAppBarColore;
    final Color kTestoColore;
    final Color kTestoSecColore;
    final Color kSearchFill;
    final Color kSearchBordo;
    final Color kSliderAttivo;
    final Color kSliderInattivo;
    final Color kDivisoreColore;
    final Color kSfondoRiga;

    switch (tema) {
      case AppTema.modernoScuro:
        kBottoneColore = Colors.transparent;
        kBottoneBordo = Colors.transparent;
        kAttivoColore = Colors.white.withOpacity(0.08);
        kPlayerColore = _kPlayerScuro;
        kAppBarColore = _kAppBarScuro;
        kTestoColore = Colors.white;
        kTestoSecColore = Colors.white60;
        kSliderAttivo = Colors.white;
        kSliderInattivo = Colors.white30;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.black.withOpacity(0.25);
        kSearchFill = Colors.white.withOpacity(0.08);
        kSearchBordo = Colors.white24;
        break;
      case AppTema.modernoChiaro:
        kBottoneColore = Colors.transparent;
        kBottoneBordo = Colors.transparent;
        kAttivoColore = Colors.black.withOpacity(0.08);
        kPlayerColore = _kPlayerChiaro;
        kAppBarColore = _kAppBarChiaro;
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
        kBottoneColore = _kBottoneClassico;
        kBottoneBordo = _kBottoneClassico;
        kAttivoColore = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo : _kAttivoClassico;
        kPlayerColore = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo : _kPlayerClassico;
        kAppBarColore = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo.withOpacity(provider.opacitaBottoneAttiva)
            : _kAppBarClassico;
        kTestoColore = provider.isPersonalizzato
            ? provider.coloreTestoBottone : Colors.white;
        kTestoSecColore = provider.isPersonalizzato
            ? provider.coloreTestoBottone.withOpacity(0.7) : Colors.white70;
        kSliderAttivo = Colors.white;
        kSliderInattivo = Colors.white30;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.transparent;
        kSearchFill = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo.withOpacity(0.15)
            : Colors.white.withOpacity(0.08);
        kSearchBordo = provider.isPersonalizzato
            ? provider.coloreBottoneAttivo.withOpacity(0.6)
            : Colors.white24;
        break;
    }

    final bool mostraPlayerWindows = _isWindows && _audioAttivo != null;
    final bool mostraPlayerFlutter = !_isWindows && _audioAttivo != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kAppBarColore,
        foregroundColor: kTestoColore,
        elevation: 0,
        title: Text('Cerca per parole chiave',
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
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isDesktop ? 0 : 16, 16, isDesktop ? 0 : 16, 8),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(color: kTestoColore, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Inserisci parola chiave...',
                        hintStyle: TextStyle(color: kTestoSecColore),
                        prefixIcon: Icon(Icons.search, color: kTestoSecColore),
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
                      ),
                      onChanged: _cerca,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _risultati.isEmpty
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: tema == AppTema.modernoChiaro
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kDivisoreColore, width: 1),
                    ),
                    child: Text(
                      _controller.text.isEmpty
                          ? 'Digita per cercare'
                          : 'Nessun risultato',
                      style: TextStyle(fontSize: 16, color: kTestoColore),
                    ),
                  ),
                )
                    : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: paddingH, vertical: 4),
                      itemCount: _risultati.length,
                      itemBuilder: (context, index) {
                        final r = _risultati[index];
                        final isAttivo = _audioAttivo == r.voce.nomePdf;
                        final isUltimo = index == _risultati.length - 1;

                        if (isModerno) {
                          return Container(
                            color: isAttivo ? kAttivoColore : kSfondoRiga,
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => PdfViewerScreen(
                                                    nomePdf: r.voce.nomePdf,
                                                    titolo: r.voce.titolo))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                          child: Icon(Icons.picture_as_pdf_rounded,
                                              size: 20, color: kTestoSecColore),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => PdfViewerScreen(
                                                      nomePdf: r.voce.nomePdf,
                                                      titolo: r.voce.titolo))),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _titoloVisualizzato(r.voce.titolo),
                                                  softWrap: true,
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: isAttivo
                                                        ? FontWeight.bold : FontWeight.normal,
                                                    color: kTestoColore,
                                                  ),
                                                ),
                                                Text(r.categoria,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: kTestoSecColore)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _riproduci(r.voce.nomePdf),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                          child: isAttivo && _isLoading && !_isWindows
                                              ? SizedBox(width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  color: kTestoColore, strokeWidth: 2))
                                              : Icon(
                                              isAttivo && _isPlaying && !_isWindows
                                                  ? Icons.pause_circle_outline_rounded
                                                  : Icons.play_circle_outline_rounded,
                                              size: 24,
                                              color: isAttivo ? kTestoColore : kTestoSecColore),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isUltimo)
                                  Divider(height: 1, thickness: 1,
                                      color: kDivisoreColore),
                              ],
                            ),
                          );
                        } else {
                          final pColore  = provider.isPersonalizzato
                              ? provider.coloreBottoneAttivo : _kBottoneClassico;
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
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => PdfViewerScreen(
                                        nomePdf: r.voce.nomePdf, titolo: r.voce.titolo))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf_rounded,
                                          size: 20, color: kTestoSecColore),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(_titoloVisualizzato(r.voce.titolo),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: kTestoColore,
                                                  fontSize: fontSize)),
                                          Text(r.categoria,
                                              style: TextStyle(fontSize: 12,
                                                  color: kTestoSecColore)),
                                        ],
                                      )),
                                      InkWell(
                                        onTap: () => _riproduci(r.voce.nomePdf),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Icon(Icons.record_voice_over_rounded,
                                              size: 20, color: kTestoSecColore),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isUltimo)
                                Divider(height: 1, thickness: 1, color: kDivisoreColore),
                            ]);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => PdfViewerScreen(
                                                        nomePdf: r.voce.nomePdf,
                                                        titolo: r.voce.titolo))),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 12),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.picture_as_pdf_rounded,
                                                      size: 16, color: kTestoSecColore),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _titoloVisualizzato(r.voce.titolo)
                                                              .toUpperCase(),
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            fontSize: fontSize,
                                                            fontWeight: isAttivo
                                                                ? FontWeight.bold : FontWeight.w500,
                                                            color: testoC,
                                                          ),
                                                        ),
                                                        Text(r.categoria.toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: kTestoSecColore)),
                                                      ],
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
                                          onTap: () => _riproduci(r.voce.nomePdf),
                                          child: SizedBox(
                                            width: 48,
                                            child: Center(
                                              child: isAttivo && _isLoading && !_isWindows
                                                  ? SizedBox(width: 18, height: 18,
                                                  child: CircularProgressIndicator(
                                                      color: kTestoColore, strokeWidth: 2))
                                                  : Icon(
                                                  isAttivo && _isPlaying && !_isWindows
                                                      ? Icons.pause_circle_outline_rounded
                                                      : Icons.record_voice_over_rounded,
                                                  size: 20,
                                                  color: isAttivo ? kTestoColore : kTestoSecColore),
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
                      },
                    ),
                  ),
                ),
              ),
              // Player Windows (webview) con bottone download sopra
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
                              Icon(Icons.download_rounded,
                                  color: kTestoSecColore, size: 18),
                              const SizedBox(width: 4),
                              Text('Scarica',
                                  style: TextStyle(
                                      color: kTestoSecColore, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                WebviewAudioPlayerWindows(
                  audioUrl: Uri.encodeFull(_baseUrl + _nomeAudio(_audioAttivo!)),
                  titolo: _displayName(_audioAttivo!),
                  playerColore: kPlayerColore,
                  testoColore: kTestoColore,
                  testoSecColore: kTestoSecColore,
                ),
              ],
              // Player Flutter (Android, iOS, macOS, Web)
              if (mostraPlayerFlutter)
                Container(
                  decoration: BoxDecoration(
                    color: kPlayerColore,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  padding: EdgeInsets.fromLTRB(
                      16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
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

class _RisultatoCerca {
  final String categoria;
  final VocePdf voce;
  _RisultatoCerca({required this.categoria, required this.voce});
}