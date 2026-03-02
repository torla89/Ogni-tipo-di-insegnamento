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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                itemCount: categoria.voci.length + 1, // +1 per il titolo
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Titolo della sezione
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
                  final isFirst = index == 1;

                  return Padding(
                    padding: EdgeInsets.only(
                        top: isFirst ? 12 : 4, bottom: 0),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                nomePdf: voce.nomePdf,
                                titolo: voce.titolo,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          voce.titolo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
