import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categorie.dart';
import 'categoria_screen.dart';
import 'cerca_screen.dart';
import 'segnalazioni_screen.dart';
import 'download_screen.dart';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorieOrdinate = List<Categoria>.from(categorie)
      ..sort((a, b) => a.titolo.compareTo(b.titolo));

    final colonnaSinistra = categorieOrdinate.sublist(0, 22);
    final colonnaDestra = categorieOrdinate.sublist(22);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ogni tipo di insegnamento'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sfondo3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1000;
            final paddingH = isDesktop ? 24.0 : 8.0;
            final altezzaBottone = isDesktop ? 48.0 : 44.0;
            final fontSize = isDesktop ? 13.0 : 14.0;

            if (isDesktop) {
              final tutteLeVoci = <_VoceGriglia>[
                ...categorieOrdinate.map((c) => _VoceGriglia(
                  titolo: c.titolo,
                  colore: const Color(0xFF1829E8),
                  onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => CategoriaScreen(categoria: c))),
                )),
                _VoceGriglia(
                  titolo: 'SEGNALAZIONI',
                  colore: const Color(0xFFE81829),
                  onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => const SegnalazioniScreen())),
                ),
                _VoceGriglia(
                  titolo: 'DOWNLOAD',
                  colore: const Color(0xFFE81829),
                  onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => const DownloadScreen())),
                ),
              ];

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 10),
                children: [
                  const Text('Menù principale',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _buildBottonePieno(context,
                      titolo: 'CERCA PER PAROLE CHIAVE',
                      colore: const Color(0xFF2E7D32),
                      icona: Icons.search,
                      altezza: altezzaBottone,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CercaScreen())),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBottonePieno(context,
                      titolo: 'INTRODUZIONE',
                      colore: const Color(0xFF9EF1E1),
                      altezza: altezzaBottone,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfViewerScreen(
                          nomePdf: 'leggimi.pdf', titolo: 'Introduzione'))),
                    )),
                  ]),
                  const SizedBox(height: 6),
                  _buildGriglia(context: context, voci: tutteLeVoci, numColonne: 4,
                      altezzaBottone: altezzaBottone, fontSize: fontSize),
                  const SizedBox(height: 12),
                  Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: _buildCardSito(context),
                  )),
                  const SizedBox(height: 20),
                ],
              );
            }

            final int numRighe = colonnaSinistra.length;

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 10),
              children: [
                const Text('Menù principale',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                _buildBottonePieno(context,
                  titolo: 'CERCA PER PAROLE CHIAVE',
                  colore: const Color(0xFF2E7D32),
                  icona: Icons.search,
                  altezza: altezzaBottone,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CercaScreen())),
                ),
                _buildBottonePieno(context,
                  titolo: 'INTRODUZIONE',
                  colore: const Color(0xFF9EF1E1),
                  altezza: altezzaBottone,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfViewerScreen(
                      nomePdf: 'leggimi.pdf', titolo: 'Introduzione'))),
                ),
                const SizedBox(height: 4),

                ...List.generate(numRighe, (i) {
                  final catSx = colonnaSinistra[i];

                  Widget destro;
                  if (i < colonnaDestra.length) {
                    final catDx = colonnaDestra[i];
                    destro = _buildBottoneGriglia(context,
                      titolo: catDx.titolo.toUpperCase(), fontSize: fontSize,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CategoriaScreen(categoria: catDx))),
                    );
                  } else if (i == colonnaDestra.length) {
                    destro = _buildBottoneGriglia(context,
                      titolo: 'SEGNALAZIONI',
                      colore: const Color(0xFFE81829), fontSize: fontSize,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const SegnalazioniScreen())),
                    );
                  } else if (i == colonnaDestra.length + 1) {
                    destro = _buildBottoneGriglia(context,
                      titolo: 'DOWNLOAD',
                      colore: const Color(0xFFE81829), fontSize: fontSize,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const DownloadScreen())),
                    );
                  } else {
                    destro = const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildBottoneGriglia(context,
                            titolo: catSx.titolo.toUpperCase(), fontSize: fontSize,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => CategoriaScreen(categoria: catSx))),
                          )),
                          const SizedBox(width: 4),
                          Expanded(child: destro),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),
                _buildCardSito(context),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildGriglia({
    required BuildContext context,
    required List<_VoceGriglia> voci,
    required int numColonne,
    required double altezzaBottone,
    required double fontSize,
  }) {
    final righe = <Widget>[];
    for (int i = 0; i < voci.length; i += numColonne) {
      final rigaVoci = voci.sublist(i, (i + numColonne).clamp(0, voci.length));
      righe.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < rigaVoci.length; j++) ...[
                if (j > 0) const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: altezzaBottone,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rigaVoci[j].colore,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => rigaVoci[j].onTap(context),
                      child: Text(rigaVoci[j].titolo.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: fontSize, letterSpacing: 0.2)),
                    ),
                  ),
                ),
              ],
              for (int k = rigaVoci.length; k < numColonne; k++) ...[
                const SizedBox(width: 4),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ),
      ));
    }
    return Column(children: righe);
  }

  Widget _buildBottonePieno(BuildContext context, {
    required String titolo,
    required Color colore,
    required VoidCallback onTap,
    required double altezza,
    IconData? icona,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: altezza,
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: icona != null
              ? Icon(icona, color: Colors.white, size: 16)
              : const SizedBox.shrink(),
          label: Text(titolo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.2)),
          style: ElevatedButton.styleFrom(
            backgroundColor: colore,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildBottoneGriglia(BuildContext context, {
    required String titolo,
    required VoidCallback onTap,
    required double fontSize,
    Color colore = const Color(0xFF1829E8),
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colore,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(titolo.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: fontSize, letterSpacing: 0.2)),
    );
  }

  Widget _buildCardSito(BuildContext context) {
    return Card(
      color: const Color(0xCC000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.parse('https://www.ognitipodiinsegnamento.it');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: const Column(
            children: [
              Text(
                'Visita il nostro sito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'www.ognitipodiinsegnamento.it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFADD8E6),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFADD8E6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoceGriglia {
  final String titolo;
  final Color colore;
  final void Function(BuildContext) onTap;
  _VoceGriglia({required this.titolo, required this.colore, required this.onTap});
}
