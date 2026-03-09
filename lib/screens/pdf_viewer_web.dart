// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class PdfWebViewer extends StatefulWidget {
  final String nomePdf;
  const PdfWebViewer({super.key, required this.nomePdf});

  @override
  State<PdfWebViewer> createState() => _PdfWebViewerState();
}

class _PdfWebViewerState extends State<PdfWebViewer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'pdf-iframe-${widget.nomePdf.hashCode}';

    final pdfUrl =
        'https://raw.githubusercontent.com/torla89/Ogni-tipo-di-insegnamento/main/assets/${widget.nomePdf}';
    final pdfJsUrl =
        'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(pdfUrl)}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = pdfJsUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
