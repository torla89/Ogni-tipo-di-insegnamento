import 'package:flutter/material.dart';
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

    // Colonna sinistra: fino a Gioventù (indice 0-21, 22 voci)
    final colonnaSinistra = categorieOrdinate.sublist(0, 22);
    // Colonna destra: da Grazia in poi (indice 22-40, 19 voci)
    final colonnaDestra = categorieOrdinate.sublist(22);

    final int numRighe = colonnaSinistra.length; // 22 righe

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          children: [
            const Text(
              'Menù principale',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // CERCA
            _buildBottonePieno(context,
              titolo: 'CERCA PER PAROLE CHIAVE',
              colore: const Color(0xFF2E7D32),
              icona: Icons.search,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CercaScreen())),
            ),

            // INTRODUZIONE
            _buildBottonePieno(context,
              titolo: 'INTRODUZIONE',
              colore: const Color(0xFF9EF1E1),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PdfViewerScreen(
                      nomePdf: 'leggimi.pdf', titolo: 'Introduzione'))),
            ),

            const SizedBox(height: 4),

            // Griglia 2 colonne
            // Righe 0-18: entrambe le colonne hanno un bottone categoria
            // Righe 19-20: colonna sinistra ha categoria, colonna destra ha SEGNALAZIONI/DOWNLOAD
            // Riga 21: solo colonna sinistra (Gioventù)
            ...List.generate(numRighe, (i) {
              final catSx = colonnaSinistra[i];

              Widget destro;
              if (i < colonnaDestra.length) {
                // Categoria normale nella colonna destra
                final catDx = colonnaDestra[i];
                destro = _buildBottoneGriglia(context,
                  titolo: catDx.titolo,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CategoriaScreen(categoria: catDx))),
                );
              } else if (i == colonnaDestra.length) {
                // SEGNALAZIONI
                destro = _buildBottoneGriglia(context,
                  titolo: 'SEGNALAZIONI',
                  colore: const Color(0xFFE81829),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SegnalazioniScreen())),
                );
              } else if (i == colonnaDestra.length + 1) {
                // DOWNLOAD
                destro = _buildBottoneGriglia(context,
                  titolo: 'DOWNLOAD',
                  colore: const Color(0xFFE81829),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DownloadScreen())),
                );
              } else {
                // Spazio vuoto
                destro = const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildBottoneGriglia(context,
                        titolo: catSx.titolo,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CategoriaScreen(categoria: catSx))),
                      )),
                      const SizedBox(width: 4),
                      Expanded(child: destro),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Card ATTENZIONE
            Card(
              color: const Color(0xCC000000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Image.asset('assets/icona_di_attenzione_11924386.png',
                    width: 56, height: 56,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.warning, color: Colors.orange, size: 44)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text(
                    'ATTENZIONE: nella sezione download troverete gratuitamente i link per scaricare l\'app per tutti i principali sistemi operativi',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                  )),
                ]),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottonePieno(BuildContext context, {
    required String titolo,
    required Color colore,
    required VoidCallback onTap,
    IconData? icona,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 44,
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: icona != null
              ? Icon(icona, color: Colors.white, size: 16)
              : const SizedBox.shrink(),
          label: Text(titolo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white, fontSize: 14, letterSpacing: 0.2)),
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
      child: Text(titolo,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white, fontSize: 14, letterSpacing: 0.2)),
    );
  }
}
