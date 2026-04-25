import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  static const String _baseUrl =
      'https://archive.org/download/ogni-tipo-di-insegnamento-podcast/';

  static const List<String> _podcast = [
    'Chi non e con Cristo.mp3',
    'Credente o Cristiano.mp3',
    'Cristiano o religioso.mp3',
    'Dio e Spirito.mp3',
    'Gesu e Geova.mp3',
    'Gesu il figlio di Dio.mp3',
    'I nomi di Dio.mp3',
    'Il Dio tremendo.mp3',
    'Il Dio uno e trino.mp3',
    'Il termine DIO.mp3',
    'Il termine immagine.mp3',
    'il termine nomeg.mp3',
    'il termine padre.mp3',
    'Io SONO.mp3',
    'JHWH 01 I nomi della divinita.mp3',
    'JHWH 02   Elohim.mp3',
    'JHWH 03 La polideita e pluralita di Dio.mp3',
    'JHWH 04   Lo Spirito di Dio.mp3',
    "JHWH 05   L'antropomorfismo di Dio.mp3",
    "JHWH 06   L'angelo dell'Eterno.mp3",
    "JHWH 07   L'io sono.mp3",
    'JHWH 08   La presenza di Cristo nel AT.mp3',
    "JHWH 09   Cristo nell'Antico Testamento.mp3",
    'JHWH 10 Gesu e il Signore.mp3',
    'JHWH 11 un Dio trino.mp3',
    'JHWH 12 Gesù rivela il Padre.mp3',
    'JHWH ed i profeti.mp3',
    'JHWH unico Dio.mp3',
    'JHWH é Cristo.mp3',
    "L'Angelo quale messaggero di YHWH.mp3",
    "l'Elohim dell'Antico patto.mp3",
    "L'unicità del Cristianesimo.mp3",
    'La divinità di Gesù.mp3',
    'La pluralità di Dio.mp3',
    "La polideità dell'Elohim.mp3",
    'la vita comunitaria dei primi cristiani.mp3',
    "Lo spirito dell'Elohim.mp3",
    'Perché i figli di Dio sono divisi.mp3',
    'Prefazione al Libro.mp3',
    'Sei guidato dallo Spirito Santo o da uno spirito maligno.mp3',
    'Unico-Dio.mp3',
    'uno stesso Dio.mp3',
    'vi è un solo Dio.mp3',
  ];

  static const Map<String, String> _nomiPersonalizzati = {
    'il termine nomeg.mp3': 'il termine nome',
    'Gesu e Geova.mp3': 'Gesù è Geova?',
  };

  static const _audioServiceChannel =
  MethodChannel('com.ognitipodiinsegnamento/audio_service');
  static const _playerControlChannel =
  MethodChannel('com.ognitipodiinsegnamento/player_control');

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<String> _risultati = List.from(_podcast);
  String? _podcastAttivo;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _posizione = Duration.zero;
  Duration _durata = Duration.zero;
  DateTime _ultimoAggiornaService = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _ultimoAggiornaPosizioneService = DateTime.fromMillisecondsSinceEpoch(0);
  final Set<String> _downloadInCorso = {};

  bool get _isWindows => !kIsWeb && Platform.isWindows;
  bool get _useExternalPlayer => kIsWeb || _isWindows;

  @override
  void initState() {
    super.initState();
    if (!_useExternalPlayer) {
      _configuraAudioSession();

      _playerControlChannel.setMethodCallHandler((call) async {
        if (!mounted) return;
        switch (call.method) {
          case 'play':
            await _player.play();
            break;
          case 'pause':
            await _player.pause();
            break;
          case 'seekTo':
            final posMs = call.arguments as int?;
            if (posMs != null) {
              await _player.seek(Duration(milliseconds: posMs));
            }
            break;
        }
      });

      _player.playerStateStream.listen((state) {
        if (mounted) {
          final wasPlaying = _isPlaying;
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
          if (state.playing != wasPlaying && _podcastAttivo != null) {
            _aggiornaService(_displayName(_podcastAttivo!), state.playing);
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
            _aggiornaPosizioneService(pos, _durata);
          }
        }
      });

      _player.durationStream.listen((dur) {
        if (mounted) setState(() => _durata = dur ?? Duration.zero);
      });

      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && mounted) {
          setState(() {
            _isPlaying = false;
            _posizione = Duration.zero;
          });
          _player.seek(Duration.zero);
          _player.stop();
          _fermaService();
        }
      });
    }
  }

  Future<void> _configuraAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth,
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
    try {
      await _audioServiceChannel.invokeMethod('startService', {
        'title': titolo,
        'isPlaying': true,
      });
    } catch (e) {
      debugPrint('Errore avvio service: $e');
    }
  }

  Future<void> _aggiornaService(String titolo, bool isPlaying) async {
    final now = DateTime.now();
    if (now.difference(_ultimoAggiornaService).inMilliseconds < 200) return;
    _ultimoAggiornaService = now;
    try {
      await _audioServiceChannel.invokeMethod('updateService', {
        'title': titolo,
        'isPlaying': isPlaying,
      });
    } catch (e) {
      debugPrint('Errore aggiornamento service: $e');
    }
  }

  Future<void> _aggiornaPosizioneService(Duration posizione, Duration durata) async {
    try {
      await _audioServiceChannel.invokeMethod('updatePosition', {
        'positionMs': posizione.inMilliseconds,
        'durationMs': durata.inMilliseconds,
      });
    } catch (e) {
      debugPrint('Errore aggiornamento posizione: $e');
    }
  }

  Future<void> _fermaService() async {
    try {
      await _audioServiceChannel.invokeMethod('stopService');
    } catch (e) {
      debugPrint('Errore stop service: $e');
    }
  }

  Future<void> _scaricaPodcast(String filename) async {
    if (_downloadInCorso.contains(filename)) return;
    setState(() => _downloadInCorso.add(filename));
    try {
      await _audioServiceChannel.invokeMethod('downloadPodcast', {
        'url': Uri.encodeFull(_baseUrl + filename),
        'filename': filename,
        'title': _displayName(filename),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download avviato: ${_displayName(filename)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Errore download: $e');
    } finally {
      if (mounted) setState(() => _downloadInCorso.remove(filename));
    }
  }

  @override
  void dispose() {
    if (!_useExternalPlayer) {
      _fermaService();
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
    if (_useExternalPlayer) {
      final url = Uri.encodeFull(_baseUrl + filename);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    try {
      if (_podcastAttivo == filename) {
        if (_isPlaying) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }
      setState(() {
        _podcastAttivo = filename;
        _isLoading = true;
        _posizione = Duration.zero;
        _durata = Duration.zero;
      });
      final url = Uri.encodeFull(_baseUrl + filename);
      await _avviaService(_displayName(filename));
      await _player.setUrl(url);
      await _player.play();
    } catch (e, stack) {
      debugPrint('ERRORE RIPRODUZIONE: $e');
      debugPrint('STACK: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella riproduzione')),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final fontSize = isDesktop ? 13.0 : 14.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Podcast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sfondo_home.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Column(
                              children: [
                                const Icon(Icons.headphones_rounded,
                                    color: Colors.white70, size: 36),
                                const SizedBox(height: 8),
                                const Text(
                                  'Podcast di Ellero Balzani',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 6,
                                          color: Colors.black54)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_risultati.length} episodi',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.white60),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _controller,
                                  onChanged: _cerca,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Cerca podcast...',
                                    hintStyle: const TextStyle(
                                        color: Colors.white54),
                                    prefixIcon: const Icon(Icons.search,
                                        color: Colors.white70),
                                    suffixIcon: _controller.text.isNotEmpty
                                        ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.white70),
                                      onPressed: () {
                                        _controller.clear();
                                        _cerca('');
                                      },
                                    )
                                        : null,
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        _risultati.isEmpty
                            ? const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Nessun risultato',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 16),
                            ),
                          ),
                        )
                            : SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              _podcastAttivo != null &&
                                  !_useExternalPlayer
                                  ? 8
                                  : 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final podcast = _risultati[index];
                                final isAttivo =
                                    _podcastAttivo == podcast;
                                final isDownloading =
                                _downloadInCorso.contains(podcast);
                                return Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 6),
                                  child: SizedBox(
                                    height: 52,
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      child: Material(
                                        color: (isAttivo &&
                                            !_useExternalPlayer
                                            ? const Color(0xFF4A0072)
                                            : const Color(0xFF7B1FA2))
                                            .withOpacity(isAttivo &&
                                            !_useExternalPlayer
                                            ? 0.95
                                            : 0.88),
                                        child: Row(
                                          children: [
                                            // Bottone play
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _riproduci(podcast),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      if (isAttivo &&
                                                          _isLoading &&
                                                          !_useExternalPlayer)
                                                        const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                          CircularProgressIndicator(
                                                            color: Colors
                                                                .white,
                                                            strokeWidth:
                                                            2,
                                                          ),
                                                        )
                                                      else
                                                        Icon(
                                                          isAttivo &&
                                                              _isPlaying &&
                                                              !_useExternalPlayer
                                                              ? Icons
                                                              .pause_circle_outline_rounded
                                                              : Icons
                                                              .play_circle_outline_rounded,
                                                          size: 20,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      const SizedBox(
                                                          width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          _displayName(
                                                              podcast),
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            fontSize,
                                                            color: Colors
                                                                .white,
                                                            fontWeight: isAttivo &&
                                                                !_useExternalPlayer
                                                                ? FontWeight
                                                                .bold
                                                                : FontWeight
                                                                .normal,
                                                          ),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Separatore
                                            Container(
                                              width: 1,
                                              height: 28,
                                              color: Colors.white24,
                                            ),
                                            // Bottone download
                                            InkWell(
                                              onTap: isDownloading
                                                  ? null
                                                  : () =>
                                                  _scaricaPodcast(
                                                      podcast),
                                              child: SizedBox(
                                                width: 44,
                                                height: 52,
                                                child: Center(
                                                  child: isDownloading
                                                      ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                    CircularProgressIndicator(
                                                      color: Colors
                                                          .white54,
                                                      strokeWidth:
                                                      2,
                                                    ),
                                                  )
                                                      : const Icon(
                                                    Icons
                                                        .download_rounded,
                                                    size: 18,
                                                    color: Colors
                                                        .white60,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _risultati.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mini player
                  if (_podcastAttivo != null && !_useExternalPlayer)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D0045).withOpacity(0.97),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(16, 10, 16,
                          16 + MediaQuery.of(context).padding.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _displayName(_podcastAttivo!),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                              activeTrackColor: const Color(0xFFCE93D8),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              overlayColor: Colors.white24,
                            ),
                            child: Slider(
                              value: _durata.inMilliseconds > 0
                                  ? _posizione.inMilliseconds
                                  .clamp(0, _durata.inMilliseconds)
                                  .toDouble()
                                  : 0,
                              min: 0,
                              max: _durata.inMilliseconds > 0
                                  ? _durata.inMilliseconds.toDouble()
                                  : 1,
                              onChanged: (val) {
                                _player.seek(
                                    Duration(milliseconds: val.toInt()));
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatDuration(_posizione),
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.replay_10,
                                    color: Colors.white70, size: 26),
                                onPressed: () {
                                  final newPos = _posizione -
                                      const Duration(seconds: 10);
                                  _player.seek(newPos < Duration.zero
                                      ? Duration.zero
                                      : newPos);
                                },
                              ),
                              _isLoading
                                  ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 44,
                                ),
                                onPressed: () {
                                  if (_isPlaying) {
                                    _player.pause();
                                  } else {
                                    _player.play();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10,
                                    color: Colors.white70, size: 26),
                                onPressed: () {
                                  final newPos = _posizione +
                                      const Duration(seconds: 10);
                                  if (newPos < _durata)
                                    _player.seek(newPos);
                                },
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(_durata),
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
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
}