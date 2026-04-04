import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categorie.dart';
import 'categoria_screen.dart';
import 'cerca_screen.dart';
import 'segnalazioni_screen.dart';
import 'download_screen.dart';
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

class StudiScreen extends StatelessWidget {
  const StudiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorieOrdinate = List<Categoria>.from(categorie)
      ..sort((a, b) => a.titolo.compareTo(b.titolo));

    final colonnaSinistra = categorieOrdinate.sublist(0, 22);
    final colonnaDestra = categorieOrdinate.sublist(22);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Studi'),
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
                      titolo: _titoloVisualizzato(c.titolo),
                      colore: const Color(0xFF1829E8),
                      onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => CategoriaScreen(categoria: c))),
                    )),
                  ];

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 10),
                    children: [
                      const SizedBox(height: 8),
                      _buildBottonePieno(context,
                        titolo: 'CERCA PER PAROLE CHIAVE',
                        colore: const Color(0xFF2E7D32),
                        icona: Icons.search,
                        altezza: altezzaBottone,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CercaScreen())),
                      ),
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
                    const SizedBox(height: 8),
                    _buildBottonePieno(context,
                      titolo: 'CERCA PER PAROLE CHIAVE',
                      colore: const Color(0xFF2E7D32),
                      icona: Icons.search,
                      altezza: altezzaBottone,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CercaScreen())),
                    ),
                    const SizedBox(height: 4),

                    ...List.generate(numRighe, (i) {
                      final catSx = colonnaSinistra[i];

                      Widget destro;
                      if (i < colonnaDestra.length) {
                        final catDx = colonnaDestra[i];
                        destro = _buildBottoneGriglia(context,
                          titolo: _titoloVisualizzato(catDx.titolo).toUpperCase(), fontSize: fontSize,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CategoriaScreen(categoria: catDx))),
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
                                titolo: _titoloVisualizzato(catSx.titolo).toUpperCase(), fontSize: fontSize,
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