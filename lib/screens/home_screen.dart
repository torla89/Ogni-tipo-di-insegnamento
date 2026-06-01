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
import 'predicazioni_screen.dart';
import 'tema_personalizzato_screen.dart' show TemaPersonalizzatoScreen;

const _kVerde = Color(0xFF2E7D32);
const _kBlu   = Color(0xFF1829E8);
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
      builder: (_) => _ImpostazioniSheet(),
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
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(children: [
                    Icon(Icons.info_outline_rounded, color: Colors.white70, size: 22),
                    SizedBox(width: 10),
                    Text('Note di versione', style: TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.bold)),
                  ]),
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
                              color: isLatest ? Colors.white24 : Colors.white12,
                              width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
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
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                Text('v${v['versione']}',
                                    style: TextStyle(
                                        color: isLatest ? Colors.white : Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(v['data'], style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                              ]),
                              const SizedBox(height: 10),
                              ...novita.map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(
                                        color: Colors.white54, fontSize: 14)),
                                    Expanded(child: Text(n, style: const TextStyle(
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
    final isModerno = provider.isModerno;
    final isPersonalizzato = provider.isPersonalizzato;
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final sfondo = isDesktop ? provider.sfondoDesktop : provider.sfondoMobile;
    final fontSize = provider.fontSizeHome;
    final coloreBottone = provider.coloreBottoneAttivo;
    final opacitaBottone = provider.opacitaBottoneAttiva;

    // Colore testo: per personalizzato usa coloreTestoBottone,
    // per moderno usa coloreTesto del provider, per classico bianco
    final Color coloreTesto;
    final Color coloreTestoSec;
    if (isPersonalizzato) {
      coloreTesto    = provider.coloreTestoBottone;
      coloreTestoSec = provider.coloreTestoBottone.withOpacity(0.7);
    } else {
      coloreTesto    = provider.coloreTesto;
      coloreTestoSec = provider.coloreTestoSecondario;
    }

    final Color kDivisoreColore = provider.isChiaro
        ? const Color(0x445C3D1E) : Colors.white24;
    final Color kSfondoRiga = provider.isChiaro
        ? Colors.white.withOpacity(0.45)
        : provider.isScuro
        ? Colors.black.withOpacity(0.25)
        : Colors.transparent;
    final Color kSfondoIcona = provider.isChiaro
        ? Colors.white.withOpacity(0.45)
        : provider.isScuro
        ? Colors.black.withOpacity(0.25)
        : isPersonalizzato
        ? coloreBottone.withOpacity(opacitaBottone)
        : provider.bottoneColore;

    // Colore icone social per personalizzato
    final Color coloreIconaSocial = isPersonalizzato
        ? provider.coloreTestoBottone
        : provider.isChiaro ? Colors.black87 : Colors.white;

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
        titoloClassico: 'PREDICAZIONI',
        titoloModerno: 'Predicazioni',
        icona: Icons.record_voice_over_rounded,
        coloreClassico: _kBlu,
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const PredicazioniScreen())),
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
                color: provider.isChiaro ? Colors.black54 : Colors.white70,
                size: 26),
            onPressed: _apriImpostazioni,
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
                      Text('Ogni tipo di insegnamento',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 30 : 26,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: coloreTesto,
                            shadows: provider.isChiaro ? [] : [
                              const Shadow(blurRadius: 8, color: Colors.black54)
                            ],
                          )),
                      const SizedBox(height: 6),
                      Text('Studi biblici di Ellero Balzani',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: coloreTestoSec,
                            fontStyle: FontStyle.italic,
                            shadows: provider.isChiaro ? [] : [
                              const Shadow(blurRadius: 6, color: Colors.black54)
                            ],
                          )),
                      const SizedBox(height: 36),

                      if (isModerno) ...[
                        ...List.generate(voci.length, (i) {
                          final voce = voci[i];
                          final isUltimo = i == voci.length - 1;
                          return Container(
                            color: kSfondoRiga,
                            child: Column(children: [
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
                                      Flexible(child: Text(voce.titoloModerno,
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                              color: coloreTesto,
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.w500))),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isUltimo)
                                Divider(height: 1, thickness: 1, color: kDivisoreColore),
                            ]),
                          );
                        }),
                      ] else if (isPersonalizzato) ...[
                        Builder(builder: (context) {
                          final stile  = provider.stileBottone;
                          final radius = stile == StileBottone.pill  ? 30.0
                              : stile == StileBottone.sharp ?  2.0 : 14.0;
                          final testoC = provider.coloreTestoBottone;
                          final isOutline = provider.isStileOutline;
                          return Column(children: [
                            ...voci.map((voce) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: stile == StileBottone.lista ? 0 : 10),
                              child: voce.centrato
                                  ? _buildBottoneCentrato(context,
                                  titolo: voce.titoloClassico,
                                  icona: voce.icona,
                                  colore: coloreBottone,
                                  testoC: isOutline ? coloreBottone : testoC,
                                  fontSize: fontSize,
                                  isDesktop: isDesktop,
                                  opacita: opacitaBottone,
                                  stile: stile, radius: radius,
                                  onTap: voce.onTap)
                                  : _buildBottone(context,
                                  titolo: voce.titoloClassico,
                                  icona: voce.icona,
                                  colore: coloreBottone,
                                  testoC: isOutline ? coloreBottone : testoC,
                                  fontSize: fontSize,
                                  isDesktop: isDesktop,
                                  opacita: opacitaBottone,
                                  stile: stile, radius: radius,
                                  onTap: voce.onTap),
                            )),
                          ]);
                        }),
                      ] else ...[
                        // Classico — colori fissi originali, testo bianco
                        ...voci.map((voce) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: voce.centrato
                              ? _buildBottoneCentrato(context,
                              titolo: voce.titoloClassico,
                              icona: voce.icona,
                              colore: voce.coloreClassico,
                              testoC: Colors.white,
                              fontSize: fontSize,
                              isDesktop: isDesktop,
                              opacita: 0.92,
                              onTap: voce.onTap)
                              : _buildBottone(context,
                              titolo: voce.titoloClassico,
                              icona: voce.icona,
                              colore: voce.coloreClassico,
                              testoC: Colors.white,
                              fontSize: fontSize,
                              isDesktop: isDesktop,
                              opacita: 0.92,
                              onTap: voce.onTap),
                        )),
                      ],

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIconaLink(
                            icona: Icons.language, etichetta: 'Sito web',
                            url: 'https://www.ognitipodiinsegnamento.it',
                            provider: provider,
                            sfondoIcona: kSfondoIcona,
                            coloreIcona: coloreIconaSocial,
                            coloreEtichetta: coloreTestoSec,
                            isModerno: isModerno,
                            isPersonalizzato: isPersonalizzato,
                            stile: provider.stileBottone,
                            radius: provider.radiusBottone,
                            opacita: opacitaBottone,
                          ),
                          const SizedBox(width: 24),
                          _buildIconaLink(
                            icona: Icons.facebook, etichetta: 'Facebook',
                            url: 'https://www.facebook.com/profile.php?id=61584977437002',
                            provider: provider,
                            sfondoIcona: kSfondoIcona,
                            coloreIcona: coloreIconaSocial,
                            coloreEtichetta: coloreTestoSec,
                            isModerno: isModerno,
                            isPersonalizzato: isPersonalizzato,
                            stile: provider.stileBottone,
                            radius: provider.radiusBottone,
                            opacita: opacitaBottone,
                          ),
                          const SizedBox(width: 24),
                          _buildSpotifyLink(
                            provider: provider,
                            sfondoIcona: kSfondoIcona,
                            coloreIcona: coloreIconaSocial,
                            coloreEtichetta: coloreTestoSec,
                            isModerno: isModerno,
                            isPersonalizzato: isPersonalizzato,
                            stile: provider.stileBottone,
                            radius: provider.radiusBottone,
                            opacita: opacitaBottone,
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

  Widget _buildBottone(BuildContext context, {
    required String titolo,
    required IconData icona,
    required Color colore,
    required Color testoC,
    required double fontSize,
    required bool isDesktop,
    required VoidCallback onTap,
    required double opacita,
    StileBottone stile = StileBottone.classico,
    double radius = 14,
  }) {
    if (stile == StileBottone.lista) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icona, size: 22, color: testoC.withOpacity(0.7)),
              const SizedBox(width: 14),
              Text(titolo, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize,
                      fontWeight: FontWeight.w500, color: testoC)),
            ],
          ),
        ),
      );
    }
    final isOutline = stile == StileBottone.outline;
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 54 : 58,
      child: ElevatedButton.icon(
        icon: Icon(icona, size: 20, color: testoC),
        label: Text(titolo, style: TextStyle(fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: testoC,
            letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : colore.withOpacity(opacita),
          foregroundColor: testoC,
          elevation: isOutline ? 0 : 6,
          shadowColor: Colors.black54,
          side: isOutline ? BorderSide(color: colore, width: 1.5) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildBottoneCentrato(BuildContext context, {
    required String titolo,
    required IconData icona,
    required Color colore,
    required Color testoC,
    required double fontSize,
    required bool isDesktop,
    required VoidCallback onTap,
    required double opacita,
    StileBottone stile = StileBottone.classico,
    double radius = 14,
  }) {
    if (stile == StileBottone.lista) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icona, size: 22, color: testoC.withOpacity(0.7)),
              const SizedBox(width: 14),
              Flexible(child: Text(titolo, textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: fontSize,
                      fontWeight: FontWeight.w500, color: testoC))),
            ],
          ),
        ),
      );
    }
    final isOutline = stile == StileBottone.outline;
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 64 : 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : colore.withOpacity(opacita),
          foregroundColor: testoC,
          elevation: isOutline ? 0 : 6,
          shadowColor: Colors.black54,
          side: isOutline ? BorderSide(color: colore, width: 1.5) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icona, size: 20, color: testoC),
            const SizedBox(width: 8),
            Flexible(child: Text(titolo,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: testoC,
                    letterSpacing: 0.3))),
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
    required Color coloreIcona,
    required Color coloreEtichetta,
    required bool isModerno,
    required bool isPersonalizzato,
    StileBottone stile = StileBottone.classico,
    double radius = 14,
    double opacita = 0.92,
  }) {
    // Per personalizzato outline: sfondo trasparente con bordo
    final bool isOutline = isPersonalizzato && stile == StileBottone.outline;
    final Color sfondo = isOutline ? Colors.transparent : sfondoIcona;
    final double iconRadius = isPersonalizzato
        ? (stile == StileBottone.pill ? 26.0 : stile == StileBottone.sharp ? 2.0 : 14.0)
        : 14.0;

    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: sfondo,
            borderRadius: BorderRadius.circular(iconRadius),
            border: isOutline
                ? Border.all(color: provider.coloreBottoneAttivo, width: 1.5)
                : isModerno ? null : Border.all(color: Colors.white30, width: 1),
          ),
          child: Icon(icona, color: coloreIcona, size: 28),
        ),
        const SizedBox(height: 5),
        Text(etichetta, style: TextStyle(
            color: coloreEtichetta, fontSize: 11, letterSpacing: 0.3)),
      ]),
    );
  }

  Widget _buildSpotifyLink({
    required AppThemeProvider provider,
    required Color sfondoIcona,
    required Color coloreIcona,
    required Color coloreEtichetta,
    required bool isModerno,
    required bool isPersonalizzato,
    StileBottone stile = StileBottone.classico,
    double radius = 14,
    double opacita = 0.92,
  }) {
    final bool isOutline = isPersonalizzato && stile == StileBottone.outline;
    final Color sfondo = isOutline ? Colors.transparent : sfondoIcona;
    final double iconRadius = isPersonalizzato
        ? (stile == StileBottone.pill ? 26.0 : stile == StileBottone.sharp ? 2.0 : 14.0)
        : 14.0;

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse('https://open.spotify.com/show/7fPC8f6ivOjpRcMezYN6Fp');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: sfondo,
            borderRadius: BorderRadius.circular(iconRadius),
            border: isOutline
                ? Border.all(color: provider.coloreBottoneAttivo, width: 1.5)
                : isModerno ? null : Border.all(color: Colors.white30, width: 1),
          ),
          child: Center(child: FaIcon(FontAwesomeIcons.spotify,
              color: coloreIcona, size: 26)),
        ),
        const SizedBox(height: 5),
        Text('Spotify', style: TextStyle(
            color: coloreEtichetta, fontSize: 11, letterSpacing: 0.3)),
      ]),
    );
  }
}

// ── Bottom sheet impostazioni ────────────────────────────────
class _ImpostazioniSheet extends StatefulWidget {
  @override
  State<_ImpostazioniSheet> createState() => _ImpostazioniSheetState();
}

class _ImpostazioniSheetState extends State<_ImpostazioniSheet> {
  bool _predefinitaEspansa = false;
  bool _modernoEspanso = false;
  bool _personalizzatoEspanso = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final fontSize = provider.fontSize;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2)),
            ),

            const Align(alignment: Alignment.centerLeft,
                child: Text('TEMA', style: TextStyle(
                    color: Colors.white38, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.2))),
            const SizedBox(height: 10),

            // ── Temi predefiniti (collassabile) ──────────────
            GestureDetector(
              onTap: () => setState(() => _predefinitaEspansa = !_predefinitaEspansa),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: (provider.isClassico || provider.isModerno)
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: (provider.isClassico || provider.isModerno)
                          ? Colors.white54 : Colors.white12, width: 1),
                ),
                child: Row(children: [
                  Icon(Icons.style_outlined,
                      color: (provider.isClassico || provider.isModerno)
                          ? Colors.white : Colors.white54, size: 24),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temi predefiniti', style: TextStyle(
                          color: (provider.isClassico || provider.isModerno)
                              ? Colors.white : Colors.white70,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        provider.isClassico ? 'Classico'
                            : provider.isModerno ? 'Moderno · ${_descModerno(provider)}'
                            : 'Classico · Moderno',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  )),
                  if (provider.isClassico || provider.isModerno)
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _predefinitaEspansa ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38, size: 20),
                  ),
                ]),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _predefinitaEspansa
                  ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(children: [
                  _buildSottoOpzioneModerno(
                    titolo: 'Classico',
                    descrizione: 'Bottoni colorati su sfondo originale',
                    icona: Icons.palette_outlined,
                    selezionato: provider.isClassico,
                    onTap: () => context.read<AppThemeProvider>().setTemaClassico(),
                  ),
                  const SizedBox(height: 6),
                  _buildSottoOpzioneModerno(
                    titolo: 'Moderno chiaro',
                    descrizione: 'Sfondo luminoso con bottoni trasparenti',
                    icona: Icons.wb_sunny_outlined,
                    selezionato: provider.isModerno && provider.temaModerno == AppTemaModerno.chiaro,
                    onTap: () => context.read<AppThemeProvider>().setTemaModerno(AppTemaModerno.chiaro),
                  ),
                  const SizedBox(height: 6),
                  _buildSottoOpzioneModerno(
                    titolo: 'Moderno scuro',
                    descrizione: 'Sfondo notturno con bottoni trasparenti',
                    icona: Icons.nights_stay_outlined,
                    selezionato: provider.isModerno && provider.temaModerno == AppTemaModerno.scuro,
                    onTap: () => context.read<AppThemeProvider>().setTemaModerno(AppTemaModerno.scuro),
                  ),
                  const SizedBox(height: 6),
                  _buildSottoOpzioneModerno(
                    titolo: 'Moderno automatico',
                    descrizione: 'Chiaro di giorno · scuro di notte',
                    icona: Icons.brightness_auto_outlined,
                    selezionato: provider.isModerno && provider.temaModerno == AppTemaModerno.automatico,
                    onTap: () => context.read<AppThemeProvider>().setTemaModerno(AppTemaModerno.automatico),
                  ),
                ]),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => setState(
                      () => _personalizzatoEspanso = !_personalizzatoEspanso),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: provider.isPersonalizzato
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: provider.isPersonalizzato
                          ? Colors.white54 : Colors.white12,
                      width: 1),
                ),
                child: Row(children: [
                  Icon(Icons.tune_rounded,
                      color: provider.isPersonalizzato
                          ? Colors.white : Colors.white54,
                      size: 24),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personalizzato', style: TextStyle(
                          color: provider.isPersonalizzato
                              ? Colors.white : Colors.white70,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        provider.temiSalvati.isEmpty
                            ? 'Nessun tema salvato'
                            : provider.isPersonalizzato &&
                            provider.temaPersonalizzatoAttivoId != null
                            ? provider.temiSalvati
                            .firstWhere(
                              (t) => t.id == provider.temaPersonalizzatoAttivoId,
                          orElse: () => provider.temiSalvati.first,
                        ).nome
                            : '${provider.temiSalvati.length} tema/i salvati',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  )),
                  if (provider.isPersonalizzato)
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _personalizzatoEspanso ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38, size: 20),
                  ),
                ]),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _personalizzatoEspanso
                  ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(children: [
                  ...provider.temiSalvati.map((tema) =>
                      _buildRigaTema(context, tema, provider)),
                  if (provider.temiSalvati.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: const Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.white38, size: 18),
                        SizedBox(width: 10),
                        Expanded(child: Text(
                          'Nessun tema salvato. Creane uno nuovo!',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )),
                      ]),
                    ),
                  if (provider.puoAggiungereNuovoTema)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TemaPersonalizzatoScreen(),
                          ));
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text('Crea nuovo tema', style: TextStyle(
                                color: Colors.white70, fontSize: 14,
                                fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: const Row(children: [
                        Icon(Icons.block_rounded, color: Colors.white38, size: 16),
                        SizedBox(width: 8),
                        Text('Massimo 5 temi raggiunto',
                            style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ]),
                    ),
                ]),
              )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            const Align(alignment: Alignment.centerLeft,
                child: Text('TESTO', style: TextStyle(
                    color: Colors.white38, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.2))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.text_fields_rounded,
                        color: Colors.white54, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Dimensione testo',
                        style: TextStyle(color: Colors.white70,
                            fontSize: 15, fontWeight: FontWeight.w600))),
                    Text('${fontSize.toStringAsFixed(0)}pt',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13)),
                  ]),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: fontSize, min: 12.0, max: 22.0, divisions: 10,
                      onChanged: (val) =>
                          context.read<AppThemeProvider>().setFontSize(val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Piccolo', style: TextStyle(
                          color: Colors.white38, fontSize: 11)),
                      Text('Grande', style: TextStyle(
                          color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(alignment: Alignment.centerLeft,
                child: Text('INFORMAZIONI', style: TextStyle(
                    color: Colors.white38, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.2))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  final state = context.findAncestorStateOfType<_HomeScreenState>();
                  state?._apriChangelog();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.white54, size: 22),
                  SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Note di versione', style: TextStyle(
                          color: Colors.white70, fontSize: 15,
                          fontWeight: FontWeight.w600)),
                      Text('Novità e aggiornamenti', style: TextStyle(
                          color: Colors.white38, fontSize: 12)),
                    ],
                  )),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white30, size: 22),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRigaTema(BuildContext context,
      TemaPersonalizzatoSalvato tema, AppThemeProvider provider) {
    final attivo = provider.temaPersonalizzatoAttivoId == tema.id &&
        provider.isPersonalizzato;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: attivo
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: attivo ? Colors.white54 : Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          // Riga principale: selezione + check
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => context.read<AppThemeProvider>()
                .selezionaTemaPersonalizzato(tema.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(Icons.palette_outlined,
                    color: attivo ? Colors.white : Colors.white54, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(tema.nome, style: TextStyle(
                    color: attivo ? Colors.white : Colors.white70,
                    fontSize: 14, fontWeight: FontWeight.w600))),
                if (attivo)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
              ]),
            ),
          ),
          // Riga azioni
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(
                  color: attivo ? Colors.white24 : Colors.white12, width: 1)),
            ),
            child: Row(children: [
              // Modifica
              Expanded(child: InkWell(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12)),
                onTap: () => _modificaTema(context, tema),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.tune_rounded, color: Colors.white54, size: 15),
                    SizedBox(width: 4),
                    Text('Modifica', style: TextStyle(
                        color: Colors.white54, fontSize: 11)),
                  ]),
                ),
              )),
              Container(width: 1, height: 36,
                  color: attivo ? Colors.white24 : Colors.white12),
              // Clona
              Expanded(child: InkWell(
                onTap: () async {
                  final ok = await context.read<AppThemeProvider>()
                      .clonaTema(tema.id);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Massimo 5 temi raggiunto'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2)));
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.copy_rounded, color: Colors.white54, size: 15),
                    SizedBox(width: 4),
                    Text('Clona', style: TextStyle(
                        color: Colors.white54, fontSize: 11)),
                  ]),
                ),
              )),
              Container(width: 1, height: 36,
                  color: attivo ? Colors.white24 : Colors.white12),
              // Rinomina
              Expanded(child: InkWell(
                onTap: () => _rinominaTema(context, tema),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.edit_outlined, color: Colors.white54, size: 15),
                    SizedBox(width: 4),
                    Text('Rinomina', style: TextStyle(
                        color: Colors.white54, fontSize: 11)),
                  ]),
                ),
              )),
              Container(width: 1, height: 36,
                  color: attivo ? Colors.white24 : Colors.white12),
              // Elimina
              Expanded(child: InkWell(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12)),
                onTap: () => _eliminaTema(context, tema),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 15),
                    SizedBox(width: 4),
                    Text('Elimina', style: TextStyle(
                        color: Colors.redAccent, fontSize: 11)),
                  ]),
                ),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _modificaTema(
      BuildContext context, TemaPersonalizzatoSalvato tema) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemaPersonalizzatoScreen(temaEsistente: tema),
      ),
    );
  }
  Future<void> _rinominaTema(
      BuildContext context, TemaPersonalizzatoSalvato tema) async {
    final controller = TextEditingController(text: tema.nome);
    final nuovoNome = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Rinomina tema',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nome tema',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annulla',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Salva',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (nuovoNome != null && nuovoNome.isNotEmpty && context.mounted) {
      context.read<AppThemeProvider>().aggiornaTema(tema.id, nuovoNome);
    }
  }

  Future<void> _eliminaTema(
      BuildContext context, TemaPersonalizzatoSalvato tema) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Elimina tema',
            style: TextStyle(color: Colors.white)),
        content: Text('Eliminare "${tema.nome}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla',
                  style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (conferma == true && context.mounted) {
      context.read<AppThemeProvider>().eliminaTema(tema.id);
    }
  }

  Widget _buildOpzioneTema({
    required String titolo, required String descrizione,
    required IconData icona, required bool selezionato,
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
        child: Row(children: [
          Icon(icona, color: selezionato ? Colors.white : Colors.white54, size: 24),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titolo, style: TextStyle(
                  color: selezionato ? Colors.white : Colors.white70,
                  fontSize: 16, fontWeight: FontWeight.w600)),
              Text(descrizione, style: const TextStyle(
                  color: Colors.white54, fontSize: 12)),
            ],
          )),
          if (selezionato)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
        ]),
      ),
    );
  }

  Widget _buildSottoOpzioneModerno({
    required String titolo, required String descrizione,
    required IconData icona, required bool selezionato,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selezionato
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selezionato ? Colors.white38 : Colors.white12, width: 1),
        ),
        child: Row(children: [
          Icon(icona, color: selezionato ? Colors.white : Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titolo, style: TextStyle(
                  color: selezionato ? Colors.white : Colors.white70,
                  fontSize: 14, fontWeight: FontWeight.w600)),
              Text(descrizione, style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
            ],
          )),
          if (selezionato)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
        ]),
      ),
    );
  }

  String _descModerno(AppThemeProvider p) {
    if (!p.isModerno) return 'Sfondo con bottoni trasparenti';
    switch (p.temaModerno) {
      case AppTemaModerno.chiaro:     return 'Sfondo luminoso';
      case AppTemaModerno.scuro:      return 'Sfondo notturno';
      case AppTemaModerno.automatico: return 'Chiaro di giorno · scuro di notte';
    }
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
    required this.titoloClassico, required this.titoloModerno,
    required this.icona, required this.coloreClassico,
    required this.onTap, this.centrato = false,
  });
}