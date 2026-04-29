import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categorie.dart';
import 'pdf_viewer_screen.dart';

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

class CercaScreen extends StatefulWidget {
  const CercaScreen({super.key});

  @override
  State<CercaScreen> createState() => _CercaScreenState();
}

class _CercaScreenState extends State<CercaScreen> {
  static const String _baseUrl =
      'https://archive.org/download/jhwh-1-1-f-a_202604/';

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
  bool get _useExternalPlayer => kIsWeb || _isWindows;
  bool get _isIOS => !kIsWeb && Platform.isIOS;
  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

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
          case 'togglePlayPause':
            if (_isPlaying) {
              await _player.pause();
            } else {
              await _player.play();
            }
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
          if (state.playing != wasPlaying && _audioAttivo != null) {
            _aggiornaService(_displayName(_audioAttivo!), state.playing);
            _aggiornaNowPlaying(_displayName(_audioAttivo!), state.playing);
          }
        }
      });

      _player.positionStream.listen((pos) {
        if (mounted) {
          setState(() => _posizione = pos);
          final now = DateTime.now();
          if (now.difference(_ultimoAggiornaPosizioneService).inSeconds >= 5 &&
              _audioAttivo != null &&
              _isPlaying) {
            _ultimoAggiornaPosizioneService = now;
            if (!kIsWeb && Platform.isAndroid) {
              _aggiornaPosizioneService(pos, _durata);
            }
            _aggiornaNowPlaying(_displayName(_audioAttivo!), _isPlaying);
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
          if (_isIOS || _isMacOS) {
            _nowPlayingChannel.invokeMethod('clear');
          }
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

  Future<void> _aggiornaPosizioneService(
      Duration posizione, Duration durata) async {
    try {
      await _audioServiceChannel.invokeMethod('updatePosition', {
        'positionMs': posizione.inMilliseconds,
        'durationMs': durata.inMilliseconds,
      });
    } catch (e) {
      debugPrint('Errore aggiornamento posizione: $e');
    }
  }

  Future<void> _aggiornaNowPlaying(String titolo, bool isPlaying) async {
    if (!(_isIOS || _isMacOS)) return;
    try {
      await _nowPlayingChannel.invokeMethod('update', {
        'title': titolo,
        'isPlaying': isPlaying,
        'positionMs': _posizione.inMilliseconds,
        'durationMs': _durata.inMilliseconds,
      });
    } catch (e) {
      debugPrint('Errore NowPlaying: $e');
    }
  }

  Future<void> _fermaService() async {
    try {
      await _audioServiceChannel.invokeMethod('stopService');
    } catch (e) {
      debugPrint('Errore stop service: $e');
    }
  }

  Future<void> _scarica(String nomePdf) async {
    if (_isDownloading) return;
    final filename = _nomeAudio(nomePdf);
    final titolo = _displayName(nomePdf);
    final url = Uri.encodeFull(_baseUrl + filename);

    if (_isIOS || _isMacOS) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    setState(() => _isDownloading = true);
    try {
      await _audioServiceChannel.invokeMethod('downloadPodcast', {
        'url': url,
        'filename': filename,
        'title': titolo,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download avviato: $titolo'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Errore download: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    if (!_useExternalPlayer) {
      _fermaService();
      if (_isIOS || _isMacOS) {
        _nowPlayingChannel.invokeMethod('clear');
      }
      _player.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  String _displayName(String nomePdf) => nomePdf.replaceAll('.pdf', '');
  String _nomeAudio(String nomePdf) => nomePdf.replaceAll('.pdf', '.mp3');

  Future<void> _riproduci(String nomePdf) async {
    final filename = _nomeAudio(nomePdf);
    final titolo = _displayName(nomePdf);

    try {
      if (_audioAttivo == nomePdf) {
        if (_isPlaying) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }
      setState(() {
        _audioAttivo = nomePdf;
        _isLoading = true;
        _posizione = Duration.zero;
        _durata = Duration.zero;
      });
      final url = Uri.encodeFull(_baseUrl + filename);
      if (!(_isIOS || _isMacOS)) {
        await _avviaService(titolo);
      }
      await _player.setUrl(url);
      await _player.play();
      if (_isIOS || _isMacOS) {
        await _aggiornaNowPlaying(titolo, true);
      }
    } catch (e) {
      debugPrint('ERRORE RIPRODUZIONE: $e');
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Cerca per parole chiave')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sfondo3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1000;
            final maxWidth = isDesktop ? 800.0 : double.infinity;
            final paddingH = isDesktop ? 0.0 : 16.0;

            return Column(
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
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          hintText: 'Inserisci parola chiave...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
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
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _controller.text.isEmpty
                            ? 'Digita per cercare'
                            : 'Nessun risultato',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
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
                          final isAttivo =
                              _audioAttivo == r.voce.nomePdf;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Material(
                                color: isAttivo && !_useExternalPlayer
                                    ? const Color(0xFF0F1BA0)
                                    : const Color(0xFF1829E8),
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
                                              builder: (_) =>
                                                  PdfViewerScreen(
                                                    nomePdf: r.voce.nomePdf,
                                                    titolo: r.voce.titolo,
                                                  ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 12,
                                                vertical: 12),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .picture_as_pdf_rounded,
                                                  size: 16,
                                                  color: Colors.white60,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        _titoloVisualizzato(
                                                            r.voce
                                                                .titolo)
                                                            .toUpperCase(),
                                                        softWrap: true,
                                                        style:
                                                        const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      ),
                                                      Text(
                                                        r.categoria
                                                            .toUpperCase(),
                                                        style:
                                                        const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: 1,
                                          color: Colors.white24),
                                      InkWell(
                                        onTap: () =>
                                            _riproduci(r.voce.nomePdf),
                                        child: SizedBox(
                                          width: 48,
                                          child: Center(
                                            child: isAttivo &&
                                                _isLoading &&
                                                !_useExternalPlayer
                                                ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                              CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : Icon(
                                              isAttivo &&
                                                  _isPlaying &&
                                                  !_useExternalPlayer
                                                  ? Icons
                                                  .pause_circle_outline_rounded
                                                  : Icons
                                                  .record_voice_over_rounded,
                                              size: 20,
                                              color: isAttivo &&
                                                  !_useExternalPlayer
                                                  ? Colors.white
                                                  : Colors.white70,
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
                      ),
                    ),
                  ),
                ),

                // Mini player
                if (_audioAttivo != null && !_useExternalPlayer)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1829E8).withOpacity(0.97),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                        16,
                        10,
                        16,
                        16 + MediaQuery.of(context).padding.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _displayName(_audioAttivo!),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _scarica(_audioAttivo!),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _isDownloading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white54,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white60,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
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
                                  color: Colors.white70, fontSize: 11),
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
                                final newPos =
                                    _posizione + const Duration(seconds: 10);
                                if (newPos < _durata) _player.seek(newPos);
                              },
                            ),
                            const Spacer(),
                            Text(
                              _formatDuration(_durata),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
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