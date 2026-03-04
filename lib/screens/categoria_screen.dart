import 'package:flutter/material.dart';
import '../data/categorie.dart';
import 'pdf_viewer_screen.dart';

class CategoriaScreen extends StatelessWidget {
  final Categoria categoria;

  const CategoriaScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.titolo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sfondo3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: categoria.voci.isEmpty
            ? Center(
                child: Text(
                  'Nessun contenuto disponibile',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 700;
                  final numColonne = isDesktop ? 3 : 1;
                  final paddingH = isDesktop ? 48.0 : 16.0;

                  if (numColonne == 1) {
                    // Layout mobile: lista verticale
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 24),
                      itemCount: categoria.voci.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              categoria.titolo,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        final voce = categoria.voci[index - 1];
                        return Padding(
                          padding: EdgeInsets.only(top: index == 1 ? 12 : 4),
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1829E8),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PdfViewerScreen(
                                  nomePdf: voce.nomePdf,
                                  titolo: voce.titolo,
                                ))),
                              child: Text(voce.titolo,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Layout desktop: griglia a 3 colonne
                    return ListView(
                      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 24),
                      children: [
                        Text(
                          categoria.titolo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildGrigliaDesktop(context, numColonne),
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildGrigliaDesktop(BuildContext context, int numColonne) {
    final righe = <Widget>[];
    for (int i = 0; i < categoria.voci.length; i += numColonne) {
      final rigaVoci = categoria.voci.sublist(
          i, (i + numColonne).clamp(0, categoria.voci.length));
      righe.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int j = 0; j < rigaVoci.length; j++) ...[
              if (j > 0) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1829E8),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PdfViewerScreen(
                        nomePdf: rigaVoci[j].nomePdf,
                        titolo: rigaVoci[j].titolo,
                      ))),
                    child: Text(rigaVoci[j].titolo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ],
            for (int k = rigaVoci.length; k < numColonne; k++) ...[
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ));
    }
    return Column(children: righe);
  }
}
