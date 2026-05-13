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

const _kBottoneClassico = Color(0xFF7B1FA2);
const _kAttivoClassico = Color(0xFF4A0072);
const _kPlayerClassico = Color(0xFF4A0072);
const _kAppBarClassico = Color(0xFF1829E8);
const _kPlayerScuro = Color(0xDD0A0A1A);
const _kAppBarScuro = Color(0xCC0A0A1A);
const _kPlayerChiaro = Color(0xDDFFFFFF);
const _kAppBarChiaro = Color(0xCCFFFFFF);

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  static const String _baseUrl =
      'https://archive.org/download/podcast_revisionati/';

  static const List<String> _podcast = [
    'Chi non è con Cristo.mp3',
    'Credente o Cristiano - Parte 1 di 4.mp3',
    'Credente o Cristiano - Parte 2 di 4.mp3',
    'Credente o Cristiano - Parte 3 di 4.mp3',
    'Credente o Cristiano - Parte 4 di 4.mp3',
    'Cristiano o religioso.mp3',
    'Dio è Spirito.mp3',
    'Gesù è Geova.mp3',
    'Gesù il figlio di Dio - Parte 1 di 2.mp3',
    'Gesù il figlio di Dio - Parte 2 di 2.mp3',
    'I nomi di Dio - Parte 1 di 3.mp3',
    'I nomi di Dio - Parte 2 di 3.mp3',
    'I nomi di Dio - Parte 3 di 3.mp3',
    'Il Dio tremendo.mp3',
    'Il Dio uno e trino.mp3',
    'Il termine Dio.mp3',
    'Il termine immagine.mp3',
    'Il termine nome.mp3',
    'Il termine Padre.mp3',
    'Io Sono.mp3',
    'JHWH 01 - I nomi della divinita - Parte 1 di 4.mp3',
    'JHWH 01 - I nomi della divinita - Parte 2 di 4.mp3',
    'JHWH 01 - I nomi della divinita - Parte 3 di 4.mp3',
    'JHWH 01 - I nomi della divinita - Parte 4 di 4.mp3',
    'JHWH 02 - Elohim - Parte 1 di 3.mp3',
    'JHWH 02 - Elohim - Parte 2 di 3.mp3',
    'JHWH 02 - Elohim - Parte 3 di 3.mp3',
    "JHWH 03 - La polideità e pluralità di Dio - Parte 1 di 3.mp3",
    "JHWH 03 - La polideità e pluralità di Dio - Parte 2 di 3.mp3",
    "JHWH 03 - La polideità e pluralità di Dio - Parte 3 di 3.mp3",
    'JHWH 04 - Lo Spirito di Dio.mp3',
    "JHWH 05 - L'antropomorfismo di Dio - Parte 1 di 3.mp3",
    "JHWH 05 - L'antropomorfismo di Dio - Parte 2 di 3.mp3",
    "JHWH 05 - L'antropomorfismo di Dio - Parte 3 di 3.mp3",
    "JHWH 06 - L'angelo dell'Eterno - Parte 1 di 3.mp3",
    "JHWH 06 - L'angelo dell'Eterno - Parte 2 di 3.mp3",
    "JHWH 06 - L'angelo dell'Eterno - Parte 3 di 3.mp3",
    "JHWH 07 - L'Io sono - Parte 1 di 2.mp3",
    "JHWH 07 - L'Io sono - Parte 2 di 2.mp3",
    'JHWH 08 - La presenza di Cristo nel AT - Parte 1 di 3.mp3',
    'JHWH 08 - La presenza di Cristo nel AT - Parte 2 di 3.mp3',
    'JHWH 08 - La presenza di Cristo nel AT - Parte 3 di 3.mp3',
    "JHWH 09 - Cristo nell'Antico Testamento - Parte 1 di 2.mp3",
    "JHWH 09 - Cristo nell'Antico Testamento - Parte 2 di 2.mp3",
    "JHWH 10 - Gesù è il Signore - Parte 1 di 4.mp3",
    "JHWH 10 - Gesù è il Signore - Parte 2 di 4.mp3",
    "JHWH 10 - Gesù è il Signore - Parte 3 di 4.mp3",
    "JHWH 10 - Gesù è il Signore - Parte 4 di 4.mp3",
    'JHWH 11 - Un Dio trino - Parte 1 di 4.mp3',
    'JHWH 11 - Un Dio trino - Parte 2 di 4.mp3',
    'JHWH 11 - Un Dio trino - Parte 3 di 4.mp3',
    'JHWH 11 - Un Dio trino - Parte 4 di 4.mp3',
    "JHWH 12 - Gesù rivela il Padre - Parte 1 di 4.mp3",
    "JHWH 12 - Gesù rivela il Padre - Parte 2 di 4.mp3",
    "JHWH 12 - Gesù rivela il Padre - Parte 3 di 4.mp3",
    "JHWH 12 - Gesù rivela il Padre - Parte 4 di 4.mp3",
    "La divinità di Gesù - Parte 1 di 3.mp3",
    "La divinità di Gesù - Parte 2 di 3.mp3",
    "La divinità di Gesù - Parte 3 di 3.mp3",
    "La pluralità di Dio - Parte 1 di 2.mp3",
    "La pluralità di Dio _ Parte 2 di 2.mp3",
    "La polideità dell'Elohim.mp3",
    'La vita comunitaria dei primi cristiani.mp3',
    "Lo spirito dell'Elohim.mp3",
    "L'unicità del Cristianesimo.mp3",
    "Perché i figli di Dio sono divisi.mp3",
    'Prefazione al Libro.mp3',
    'Sei guidato dallo Spirito Santo o da uno spirito maligno - Parte 1 di 2.mp3',
    'Sei guidato dallo Spirito Santo o da uno spirito maligno - Parte 2 di 2.mp3',
    'Unico Dio - Parte 1 di 2.mp3',
    'Unico Dio - Parte 2 di 2.mp3',
    'Uno stesso Dio.mp3',
    'Vi è un solo Dio.mp3',
  ];

  static const Map<String, String> _nomiPersonalizzati = {
    "La pluralità di Dio _ Parte 2 di 2.mp3":
    "La pluralità di Dio - Parte 2 di 2",
  };

  static const _audioServiceChannel =
  MethodChannel('com.ognitipodiinsegnamento/audio_service');
  static const _playerControlChannel =
  MethodChannel('com.ognitipodiinsegnamento/player_control');
  static const _nowPlayingChannel =
  MethodChannel('com.ognitipodiinsegnamento/nowplaying');

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<String> _risultati = List.from(_podcast);
  String? _podcastAttivo;
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
    // Inizializza player su tutte le piattaforme tranne Windows
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
          if (state.playing != wasPlaying && _podcastAttivo != null) {
            if (!kIsWeb) _aggiornaService(_displayName(_podcastAttivo!), state.playing);
            if (_isIOS || _isMacOS) _aggiornaNowPlaying(_displayName(_podcastAttivo!), state.playing);
          }
        }
      });

      _player.positionStream.listen((pos) {
        if (mounted) {
          setState(() => _posizione = pos);
          final now = DateTime.now();
          if (now.difference(_ultimoAggiornaPosizioneService).inSeconds >= 5 &&
              _podcastAttivo != null && _isPlaying) {
            _ultimoAggiornaPosizioneService = now;
            if (!kIsWeb && Platform.isAndroid) _aggiornaPosizioneService(pos, _durata);
            if (_isIOS || _isMacOS) _aggiornaNowPlaying(_displayName(_podcastAttivo!), _isPlaying);
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

  Future<void> _scaricaPodcast(String filename) async {
    // Web, iOS, macOS, Windows → apri nel browser
    if (kIsWeb || _isIOS || _isMacOS || _isWindows) {
      await launchUrl(Uri.parse(Uri.encodeFull(_baseUrl + filename)),
          mode: LaunchMode.externalApplication);
      return;
    }
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await _audioServiceChannel.invokeMethod('downloadPodcast', {
        'url': Uri.encodeFull(_baseUrl + filename),
        'filename': filename, 'title': _displayName(filename),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download avviato: ${_displayName(filename)}'),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) { debugPrint('Errore download: $e'); }
    finally { if (mounted) setState(() => _isDownloading = false); }
  }

  @override
  void dispose() {
    // Ferma sempre il player al dispose su tutte le piattaforme tranne Windows
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
        _risultati = List.from(_podcast);
      } else {
        _risultati = _podcast
            .where((p) => _displayName(p).toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _displayName(String filename) {
    return _nomiPersonalizzati[filename] ?? filename.replaceAll('.mp3', '');
  }

  Future<void> _riproduci(String filename) async {
    if (_isWindows) {
      setState(() => _podcastAttivo = filename);
      return;
    }
    try {
      if (_podcastAttivo == filename) {
        if (_isPlaying) await _player.pause();
        else await _player.play();
        return;
      }
      setState(() {
        _podcastAttivo = filename;
        _isLoading = true;
        _posizione = Duration.zero;
        _durata = Duration.zero;
      });
      final url = Uri.encodeFull(_baseUrl + filename);
      if (!kIsWeb && !(_isIOS || _isMacOS)) await _avviaService(_displayName(filename));
      await _player.setUrl(url);
      await _player.play();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final tema = provider.tema;
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
      case AppTema.automatico:
      case AppTema.classico:
        kBottoneColore = _kBottoneClassico;
        kBottoneBordo = _kBottoneClassico;
        kAttivoColore = _kAttivoClassico;
        kPlayerColore = _kPlayerClassico;
        kAppBarColore = _kAppBarClassico;
        kTestoColore = Colors.white;
        kTestoSecColore = Colors.white70;
        kSliderAttivo = Colors.white;
        kSliderInattivo = Colors.white30;
        kSearchFill = Colors.black.withOpacity(0.45);
        kSearchBordo = Colors.transparent;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.transparent;
        break;
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
        kSearchFill = Colors.black.withOpacity(0.3);
        kSearchBordo = Colors.white24;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.black.withOpacity(0.25);
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
        kSearchFill = Colors.white.withOpacity(0.5);
        kSearchBordo = const Color(0x445C3D1E);
        kDivisoreColore = const Color(0x445C3D1E);
        kSfondoRiga = Colors.white.withOpacity(0.45);
        break;
    }

    // Su web mostra sempre il player Flutter (no webview Windows)
    final bool mostraPlayerWindows = _isWindows && _podcastAttivo != null;
    final bool mostraPlayerFlutter = !_isWindows && _podcastAttivo != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kAppBarColore,
        foregroundColor: kTestoColore,
        elevation: 0,
        title: Text('Podcast',
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
                                Icon(Icons.headphones_rounded,
                                    color: kTestoSecColore, size: 36),
                                const SizedBox(height: 8),
                                Text('Podcast di Ellero Balzani',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic, color: kTestoColore,
                                      shadows: tema == AppTema.modernoChiaro
                                          ? [] : const [Shadow(blurRadius: 6, color: Colors.black54)],
                                    )),
                                const SizedBox(height: 4),
                                Text('${_risultati.length} episodi',
                                    style: TextStyle(fontSize: 13, color: kTestoSecColore)),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _controller,
                                  onChanged: _cerca,
                                  style: TextStyle(color: kTestoColore),
                                  decoration: InputDecoration(
                                    hintText: 'Cerca podcast...',
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
                        _risultati.isEmpty
                            ? SliverFillRemaining(
                            child: Center(child: Text('Nessun risultato',
                                style: TextStyle(color: kTestoSecColore, fontSize: 16))))
                            : SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16,
                              _podcastAttivo != null ? 8 : 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final podcast = _risultati[index];
                                final isAttivo = _podcastAttivo == podcast;
                                final isUltimo = index == _risultati.length - 1;

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
                                                onTap: () => _riproduci(podcast),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 14),
                                                  child: isAttivo && _isLoading && !_isWindows
                                                      ? SizedBox(width: 22, height: 22,
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
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => _riproduci(podcast),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    child: Text(_displayName(podcast),
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
                                                onTap: () => _scaricaPodcast(podcast),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 14),
                                                  child: _isDownloading
                                                      ? SizedBox(width: 18, height: 18,
                                                      child: CircularProgressIndicator(
                                                          color: kTestoSecColore, strokeWidth: 2))
                                                      : Icon(Icons.download_rounded,
                                                      size: 18, color: kTestoSecColore),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isUltimo)
                                          Divider(height: 1, thickness: 1, color: kDivisoreColore),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Material(
                                        color: isAttivo ? kAttivoColore : kBottoneColore,
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => _riproduci(podcast),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 14),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        if (isAttivo && _isLoading && !_isWindows)
                                                          SizedBox(width: 20, height: 20,
                                                              child: CircularProgressIndicator(
                                                                  color: kTestoColore, strokeWidth: 2))
                                                        else
                                                          Icon(
                                                              isAttivo && _isPlaying && !_isWindows
                                                                  ? Icons.pause_circle_outline_rounded
                                                                  : Icons.play_circle_outline_rounded,
                                                              size: 20, color: kTestoColore),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            _displayName(podcast).toUpperCase(),
                                                            textAlign: TextAlign.center,
                                                            softWrap: true,
                                                            style: TextStyle(
                                                              fontSize: fontSize,
                                                              color: kTestoColore,
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
                                              Container(width: 1, color: kBottoneBordo),
                                              InkWell(
                                                onTap: () => _scaricaPodcast(podcast),
                                                child: SizedBox(
                                                  width: 44,
                                                  child: Center(
                                                    child: _isDownloading
                                                        ? SizedBox(width: 16, height: 16,
                                                        child: CircularProgressIndicator(
                                                            color: kTestoSecColore, strokeWidth: 2))
                                                        : Icon(Icons.download_rounded,
                                                        size: 18, color: kTestoSecColore),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              childCount: _risultati.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Player Windows (webview)
              if (mostraPlayerWindows)
                WebviewAudioPlayerWindows(
                  audioUrl: Uri.encodeFull(_baseUrl + _podcastAttivo!),
                  titolo: _displayName(_podcastAttivo!),
                  playerColore: kPlayerColore,
                  testoColore: kTestoColore,
                  testoSecColore: kTestoSecColore,
                ),
              // Player Flutter (Android, iOS, macOS, Web)
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
                      Text(_displayName(_podcastAttivo!),
                          textAlign: TextAlign.center, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: kTestoColore,
                              fontSize: 13, fontWeight: FontWeight.w600)),
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