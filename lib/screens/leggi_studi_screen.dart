import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categorie.dart';

class LeggiStudiScreen extends StatefulWidget {
  final List<VocePdf> voci;
  final String titoloCategoria;
  final VocePdf? voceDiPartenza;

  const LeggiStudiScreen({
    super.key,
    required this.voci,
    required this.titoloCategoria,
    this.voceDiPartenza,
  });

  @override
  State<LeggiStudiScreen> createState() => _LeggiStudiScreenState();
}

class _LeggiStudiScreenState extends State<LeggiStudiScreen> {
  static const String _baseUrl =
      'https://archive.org/download/jhwh-1-1-f-a_202604/';

  static const _audioServiceChannel =
  MethodChannel('com.ognitipodiinsegnamento/audio_service');
  static const _playerControlChannel =
  MethodChannel('com.ognitipodiinsegnamento/player_control');
  static const _nowPlayingChannel =
  MethodChannel('com.ognitipodiinsegnamento/nowplaying');

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<VocePdf> _risultati = [];
  String? _audioAttivo;
  bool _isPlaying = false;
  bool _isLoading = false;
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
    _risultati = List.from(widget.voci);

    if (widget.voceDiPartenza != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _riproduci(widget.voceDiPartenza!.nomePdf);
      });
    }

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

  void _cerca(String query) {
    query = query.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _risultati = List.from(widget.voci);
      } else {
        _risultati = widget.voci
            .where((v) => v.titolo.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _displayName(String nomePdf) {
    return nomePdf.replaceAll('.pdf', '');
  }

  String _nomeAudio(String nomePdf) {
    return nomePdf.replaceAll('.pdf', '.mp3');
  }

  Future<void> _riproduci(String nomePdf) async {
    final filename = _nomeAudio(nomePdf);
    final titolo = _displayName(nomePdf);

    if (_useExternalPlayer) {
      final url = Uri.encodeFull(_baseUrl + filename);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

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
        title: Text('Ascolta: ${widget.titoloCategoria}'),
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
                            padding:
                            const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Column(
                              children: [
                                const Icon(Icons.record_voice_over_rounded,
                                    color: Colors.white70, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  widget.titoloCategoria,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                                  '${_risultati.length} studi',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.white60),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _controller,
                                  onChanged: _cerca,
                                  style:
                                  const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Cerca studio...',
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
                                    fillColor:
                                    Colors.white.withOpacity(0.15),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
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
                                  color: Colors.white60,
                                  fontSize: 16),
                            ),
                          ),
                        )
                            : SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              _audioAttivo != null &&
                                  !_useExternalPlayer
                                  ? 8
                                  : 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final voce = _risultati[index];
                                final isAttivo =
                                    _audioAttivo == voce.nomePdf;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 6),
                                  child: SizedBox(
                                    height: 52,
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      child: Material(
                                        color: (isAttivo &&
                                            !_useExternalPlayer
                                            ? const Color(
                                            0xFF4A0072)
                                            : const Color(
                                            0xFF7B1FA2))
                                            .withOpacity(isAttivo &&
                                            !_useExternalPlayer
                                            ? 0.95
                                            : 0.88),
                                        child: InkWell(
                                          onTap: () => _riproduci(
                                              voce.nomePdf),
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
                                                      color:
                                                      Colors.white,
                                                      strokeWidth: 2,
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
                                                    color: Colors.white,
                                                  ),
                                                const SizedBox(
                                                    width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _displayName(
                                                        voce.nomePdf)
                                                        .toUpperCase(),
                                                    textAlign: TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                      fontSize:
                                                      fontSize,
                                                      color:
                                                      Colors.white,
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
                  if (_audioAttivo != null && !_useExternalPlayer)
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
                      padding: EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          16 + MediaQuery.of(context).padding.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
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