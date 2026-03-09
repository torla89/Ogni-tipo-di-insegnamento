import 'package:flutter/material.dart';

// Stub per piattaforme non-web
class PdfWebViewer extends StatelessWidget {
  final String nomePdf;
  const PdfWebViewer({super.key, required this.nomePdf});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
