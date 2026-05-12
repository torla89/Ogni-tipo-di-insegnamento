import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme_provider.dart';
import 'studi_screen.dart';
import 'podcast_screen.dart';
import 'segnalazioni_screen.dart';
import 'download_screen.dart';
import 'pdf_viewer_screen.dart';
import 'video_screen.dart';

const _kVerde = Color(0xFF2E7D32);
const _kBlu = Color(0xFF1829E8);
const _kRosso = Color(0xFFE81829);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> _apriImpostazioni() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = context.watch<AppThemeProvider>();
          final tema = provider.tema;
          final testoGrande = provider.testoGrande;
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.white30, borderRadius: BorderRadius.circular(2)),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('TEMA',
                      style: TextStyle(color: Colors.white38, fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 10),
                _buildOpzioneTema(
                  titolo: 'Classico',
                  descrizione: 'Bottoni colorati su sfondo scuro',
                  icona: Icons.palette,
                  selezionato: tema == AppTema.classico,
                  onTap: () => context.read<AppThemeProvider>().setTema(AppTema.classico),
                ),
                const SizedBox(height: 8),
                _buildOpzioneTema(
                  titolo: 'Moderno chiaro',
                  descrizione: 'Sfondo luminoso con bottoni trasparenti',
                  icona: Icons.wb_sunny_outlined,
                  selezionato: tema == AppTema.modernoChiaro,
                  onTap: () => context.read<AppThemeProvider>().setTema(AppTema.modernoChiaro),
                ),
                const SizedBox(height: 8),
                _buildOpzioneTema(
                  titolo: 'Moderno scuro',
                  descrizione: 'Sfondo notturno con bottoni trasparenti',
                  icona: Icons.nights_stay_outlined,
                  selezionato: tema == AppTema.modernoScuro,
                  onTap: () => context.read<AppThemeProvider>().setTema(AppTema.modernoScuro),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('TESTO',
                      style: TextStyle(color: Colors.white38, fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.read<AppThemeProvider>().setTestoGrande(!testoGrande),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: testoGrande
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: testoGrande ? Colors.white54 : Colors.white12, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.text_fields_rounded,
                            color: testoGrande ? Colors.white : Colors.white54, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Testo grande',
                                  style: TextStyle(
                                      color: testoGrande ? Colors.white : Colors.white70,
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              const Text('Aumenta la dimensione del testo nei bottoni',
                                  style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (testoGrande)
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('INFORMAZIONI',
                      style: TextStyle(color: Colors.white38, fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () => _apriChangelog());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.white54, size: 22),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Note di versione',
                                  style: TextStyle(color: Colors.white70, fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              Text('Novità e aggiornamenti',
                                  style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpzioneTema({
    required String titolo,
    required String descrizione,
    required IconData icona,
    required bool selezionato,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selezionato
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selezionato ? Colors.white54 : Colors.white12, width: 1),
        ),
        child: Row(
          children: [
            Icon(icona, color: selezionato ? Colors.white : Colors.white54, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titolo,
                      style: TextStyle(
                          color: selezionato ? Colors.white : Colors.white70,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(descrizione,
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (selezionato)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  Future<void> _apriChangelog() async {
    try {
      final String data = await rootBundle.loadString('assets/changelog.json');
      final List<dynamic> versioni = json.decode(data);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white30, borderRadius: BorderRadius.circular(2)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.white70, size: 22),
                      SizedBox(width: 10),
                      Text('Note di versione',
                          style: TextStyle(color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: versioni.length,
                    itemBuilder: (_, i) {
                      final v = versioni[i];
                      final novita = List<String>.from(v['novita']);
                      final bool isLatest = i == 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isLatest
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isLatest ? Colors.white24 : Colors.white12, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isLatest)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(6)),
                                      child: const Text('ATTUALE',
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  Text('v${v['versione']}',
                                      style: TextStyle(
                                          color: isLatest ? Colors.white : Colors.white70,
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text(v['data'],
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...novita.map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: Colors.white54, fontSize: 14)),
                                    Expanded(child: Text(n,
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 13))),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('ERRORE changelog: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final tema = provider.tema;
    final isModerno = tema != AppTema.classico;
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final sfondo = isDesktop ? provider.sfondoDesktop : provider.sfondoMobile;
    final coloreTesto = provider.coloreTesto;
    final coloreTestoSec = provider.coloreTestoSecondario;
    final fontSize = provider.fontSizeHome;

    final Color kDivisoreColore = tema == AppTema.modernoChiaro
        ? const Color(0x445C3D1E)
        : Colors.white24;
    final Color kSfondoRiga = tema == AppTema.modernoChiaro
        ? Colors.white.withOpacity(0.45)
        : tema == AppTema.modernoScuro
        ? Colors.black.withOpacity(0.25)
        : Colors.transparent;
    final Color kSfondoIcona = tema == AppTema.modernoChiaro
        ? Colors.white.withOpacity(0.45)
        : tema == AppTema.modernoScuro
        ? Colors.black.withOpacity(0.25)
        : provider.bottoneColore;

    // Classico: titoli in maiuscolo come vecchia versione
    final List<_VoceHome> voci = [
      _VoceHome(
        titoloClassico: 'INTRODUZIONE',
        titoloModerno: 'Introduzione',
        icona: Icons.info_outline_rounded,
        coloreClassico: _kVerde,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const PdfViewerScreen(
                nomePdf: 'leggimi.pdf', titolo: 'Introduzione'))),
      ),
      _VoceHome(
        titoloClassico: 'CONVERSIONE DI ELLERO BALZANI\nVIDEO RICORDO',
        titoloModerno: 'Conversione di Ellero Balzani\nVideo ricordo',
        icona: Icons.play_circle_outline_rounded,
        coloreClassico: _kBlu,
        centrato: true,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const VideoScreen())),
      ),
      _VoceHome(
        titoloClassico: 'STUDI',
        titoloModerno: 'Studi',
        icona: Icons.menu_book_rounded,
        coloreClassico: _kBlu,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => StudiScreen())),
      ),
      _VoceHome(
        titoloClassico: 'PODCAST',
        titoloModerno: 'Podcast',
        icona: Icons.headphones_rounded,
        coloreClassico: _kBlu,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PodcastScreen())),
      ),
      _VoceHome(
        titoloClassico: 'DOWNLOAD',
        titoloModerno: 'Download',
        icona: Icons.download_rounded,
        coloreClassico: _kRosso,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const DownloadScreen())),
      ),
      _VoceHome(
        titoloClassico: 'SEGNALAZIONI',
        titoloModerno: 'Segnalazioni',
        icona: Icons.flag_outlined,
        coloreClassico: _kRosso,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const SegnalazioniScreen())),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: tema == AppTema.modernoChiaro
                    ? Colors.black54 : Colors.white70,
                size: 26),
            onPressed: () => _apriImpostazioni(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(sfondo), fit: BoxFit.cover),
        ),
        child: Container(
          constraints: const BoxConstraints.expand(),
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
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      isDesktop ? 48 : 28, 8, isDesktop ? 48 : 28, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Ogni tipo di insegnamento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 30 : 26,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: coloreTesto,
                          shadows: tema == AppTema.modernoChiaro
                              ? [] : [const Shadow(blurRadius: 8, color: Colors.black54)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Studi biblici di Ellero Balzani',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: coloreTestoSec,
                          fontStyle: FontStyle.italic,
                          shadows: tema == AppTema.modernoChiaro
                              ? [] : [const Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                      const SizedBox(height: 36),

                      if (isModerno) ...[
                        ...List.generate(voci.length, (i) {
                          final voce = voci[i];
                          final isUltimo = i == voci.length - 1;
                          return Container(
                            color: kSfondoRiga,
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: voce.onTap,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(voce.icona, size: 22, color: coloreTestoSec),
                                        const SizedBox(width: 16),
                                        Flexible(
                                          child: Text(
                                            voce.titoloModerno,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: coloreTesto,
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!isUltimo)
                                  Divider(height: 1, thickness: 1,
                                      color: kDivisoreColore),
                              ],
                            ),
                          );
                        }),
                      ] else ...[
                        ...voci.map((voce) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: voce.centrato
                              ? _buildBottoneCentrato(context,
                              titolo: voce.titoloClassico,
                              icona: voce.icona,
                              colore: voce.coloreClassico,
                              fontSize: fontSize,
                              isDesktop: isDesktop,
                              onTap: voce.onTap)
                              : _buildBottone(context,
                              titolo: voce.titoloClassico,
                              icona: voce.icona,
                              colore: voce.coloreClassico,
                              fontSize: fontSize,
                              isDesktop: isDesktop,
                              onTap: voce.onTap),
                        )),
                      ],

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIconaLink(
                            icona: Icons.language,
                            etichetta: 'Sito web',
                            url: 'https://www.ognitipodiinsegnamento.it',
                            provider: provider,
                            sfondoIcona: kSfondoIcona,
                            isModerno: isModerno,
                            tema: tema,
                          ),
                          const SizedBox(width: 24),
                          _buildIconaLink(
                            icona: Icons.facebook,
                            etichetta: 'Facebook',
                            url: 'https://www.facebook.com/profile.php?id=61584977437002',
                            provider: provider,
                            sfondoIcona: kSfondoIcona,
                            isModerno: isModerno,
                            tema: tema,
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                  'https://open.spotify.com/show/7fPC8f6ivOjpRcMezYN6Fp?si=N3QOyVT1TI6VqEqx0yYNIg');
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: kSfondoIcona,
                                    borderRadius: BorderRadius.circular(14),
                                    border: isModerno
                                        ? null
                                        : Border.all(color: Colors.white30, width: 1),
                                  ),
                                  child: Center(
                                    child: FaIcon(FontAwesomeIcons.spotify,
                                        color: tema == AppTema.modernoChiaro
                                            ? Colors.black87 : Colors.white,
                                        size: 26),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text('Spotify',
                                    style: TextStyle(
                                        color: coloreTestoSec, fontSize: 11,
                                        letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottone(
      BuildContext context, {
        required String titolo,
        required IconData icona,
        required Color colore,
        required double fontSize,
        required bool isDesktop,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 54 : 58,
      child: ElevatedButton.icon(
        icon: Icon(icona, size: 20, color: Colors.white),
        label: Text(
          titolo,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colore.withOpacity(0.92),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildBottoneCentrato(
      BuildContext context, {
        required String titolo,
        required IconData icona,
        required Color colore,
        required double fontSize,
        required bool isDesktop,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 64 : 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colore.withOpacity(0.92),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icona, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                titolo,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconaLink({
    required IconData icona,
    required String etichetta,
    required String url,
    required AppThemeProvider provider,
    required Color sfondoIcona,
    required bool isModerno,
    required AppTema tema,
  }) {
    final coloreTestoSec = provider.coloreTestoSecondario;
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: sfondoIcona,
              borderRadius: BorderRadius.circular(14),
              border: isModerno
                  ? null
                  : Border.all(color: Colors.white30, width: 1),
            ),
            child: Icon(icona,
                color: tema == AppTema.modernoChiaro
                    ? Colors.black87 : Colors.white,
                size: 28),
          ),
          const SizedBox(height: 5),
          Text(etichetta,
              style: TextStyle(
                  color: coloreTestoSec, fontSize: 11, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _VoceHome {
  final String titoloClassico;
  final String titoloModerno;
  final IconData icona;
  final Color coloreClassico;
  final VoidCallback onTap;
  final bool centrato;
  _VoceHome({
    required this.titoloClassico,
    required this.titoloModerno,
    required this.icona,
    required this.coloreClassico,
    required this.onTap,
    this.centrato = false,
  });
}