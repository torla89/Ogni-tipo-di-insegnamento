import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  final String nomePdf;
  final String titolo;

  const PdfViewerScreen({
    super.key,
    required this.nomePdf,
    required this.titolo,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String? _errore;

  String _sanitizzaNome(String nome) {
    return nome
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('À', 'A')
        .replaceAll('È', 'E')
        .replaceAll('É', 'E')
        .replaceAll('Ì', 'I')
        .replaceAll('Ò', 'O')
        .replaceAll('Ù', 'U')
        .replaceAll("'", '_')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\.]'), '_');
  }

  @override
  void initState() {
    super.initState();
    _apriPdf();
  }

  Future<void> _apriPdf() async {
    if (kIsWeb) {
      final url = Uri.parse(
        'https://raw.githubusercontent.com/torla89/Ogni-tipo-di-insegnamento/main/assets/${widget.nomePdf}',
      );
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() {
          _errore = 'Impossibile aprire il PDF: $e';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final byteData = await rootBundle.load('assets/${widget.nomePdf}');

      final docsDir = await getApplicationDocumentsDirectory();

      final nomeOriginale = widget.nomePdf.split('/').last;
      final nomeFile = _sanitizzaNome(nomeOriginale);

      final file = File('${docsDir.path}/$nomeFile');

      if (await file.exists()) await file.delete();

      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );

      final result = await OpenFilex.open(file.path, type: 'application/pdf');

      if (result.type != ResultType.done) {
        setState(() {
          _errore = 'Nessuna app PDF trovata sul dispositivo.\nInstalla Adobe Acrobat o Google PDF Viewer.';
          _isLoading = false;
        });
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errore = 'Errore: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titolo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Apertura PDF...'),
          ],
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errore ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errore = null;
                  });
                  _apriPdf();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}