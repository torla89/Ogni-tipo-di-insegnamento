import 'package:flutter/material.dart';
import '../data/categorie.dart';
import 'pdf_viewer_screen.dart';

class CercaScreen extends StatefulWidget {
  const CercaScreen({super.key});

  @override
  State<CercaScreen> createState() => _CercaScreenState();
}

class _CercaScreenState extends State<CercaScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_RisultatoCerca> _risultati = [];

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
                // Campo ricerca
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

                // Risultati
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
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: SizedBox(
                                    height: isDesktop ? 52 : 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1829E8),
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        alignment: Alignment.centerLeft,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerScreen(
                                            nomePdf: r.voce.nomePdf,
                                            titolo: r.voce.titolo,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(r.voce.titolo.toUpperCase(),
                                              style: TextStyle(
                                                  fontSize:
                                                      isDesktop ? 14 : 14,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          Text(r.categoria.toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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
