import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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

  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<String> _risultati = List.from(_podcast);
  String? _podcastAttivo;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _posizione = Duration.zero;
  Duration _durata = Duration.zero;

  bool get _isWindows => !kIsWeb && Platform.isWindows;

  @override
  void initState() {
    super.initState();
    if (!_isWindows) {
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
        }
      });
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _posizione = pos);
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
        }
      });
    }
  }

  @override
  void dispose() {
    if (!_isWindows) _player.dispose();
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
            .where((p) => p.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _displayName(String filename) {
    return filename.replaceAll('.mp3', '');
  }

  Future<void> _riproduci(String filename) async {
    // Su Windows apre nel player predefinito
    if (_isWindows) {
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
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
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
                                      Shadow(blurRadius: 6, color: Colors.black54)
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
                                    hintStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                    suffixIcon: _controller.text.isNotEmpty
                                        ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white70),
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
                            ? const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Nessun risultato',
                              style: TextStyle(color: Colors.white60, fontSize: 16),
                            ),
                          ),
                        )
                            : SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16, 0, 16, _podcastAttivo != null && !_isWindows ? 8 : 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final podcast = _risultati[index];
                                final isAttivo = _podcastAttivo == podcast;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      icon: isAttivo && _isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Icon(
                                          isAttivo && _isPlaying
                                              ? Icons.pause_circle_outline_rounded
                                              : Icons.play_circle_outline_rounded,
                                          size: 20,
                                          color: Colors.white),
                                      label: Text(
                                        _displayName(podcast),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.white,
                                          fontWeight: isAttivo && !_isWindows
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAttivo && !_isWindows
                                            ? const Color(0xFF4A0072).withOpacity(0.95)
                                            : const Color(0xFF7B1FA2).withOpacity(0.88),
                                        foregroundColor: Colors.white,
                                        elevation: isAttivo && !_isWindows ? 8 : 4,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _riproduci(podcast),
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

                  // Mini player — solo su non-Windows
                  if (_podcastAttivo != null && !_isWindows)
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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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
                                _player.seek(Duration(milliseconds: val.toInt()));
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatDuration(_posizione),
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.replay_10, color: Colors.white70, size: 26),
                                onPressed: () {
                                  final newPos = _posizione - const Duration(seconds: 10);
                                  _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
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
                                icon: const Icon(Icons.forward_10, color: Colors.white70, size: 26),
                                onPressed: () {
                                  final newPos = _posizione + const Duration(seconds: 10);
                                  if (newPos < _durata) _player.seek(newPos);
                                },
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(_durata),
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
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