import 'package:flutter/material.dart';
import '../theme_provider.dart';

/// Bottone standard che rispetta il tema personalizzato
Widget buildBottoneTema({
  required BuildContext context,
  required AppThemeProvider provider,
  required String titolo,
  required IconData icona,
  required Color coloreClassico,
  required double fontSize,
  required bool isDesktop,
  required VoidCallback onTap,
  bool centrato = false,
}) {
  final Color colore = provider.isPersonalizzato
      ? provider.coloreBottoneAttivo : coloreClassico;
  final double opacita = provider.isPersonalizzato
      ? provider.opacitaBottoneAttiva : 0.92;
  final StileBottone stile = provider.isPersonalizzato
      ? provider.stileBottone : StileBottone.classico;
  final double radius = provider.radiusBottone;
  final bool isOutline = provider.isStileOutline;
  final bool isBianco = colore == const Color(0xFFFFFFFF);

  if (stile == StileBottone.lista) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, size: 22, color: provider.coloreTestoSecondario),
            const SizedBox(width: 14),
            Flexible(child: Text(titolo,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: provider.coloreTesto,
                ))),
          ],
        ),
      ),
    );
  }

  final Color testoColore = isOutline
      ? colore : isBianco ? Colors.black : Colors.white;

  if (centrato) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 64 : 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline
              ? Colors.transparent : colore.withOpacity(opacita),
          foregroundColor: testoColore,
          elevation: isOutline ? 0 : 6,
          shadowColor: Colors.black54,
          side: isOutline ? BorderSide(color: colore, width: 1.5) : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icona, size: 20, color: testoColore),
            const SizedBox(width: 8),
            Flexible(child: Text(titolo,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: testoColore, letterSpacing: 0.3))),
          ],
        ),
      ),
    );
  }

  return SizedBox(
    width: double.infinity,
    height: isDesktop ? 54 : 58,
    child: ElevatedButton.icon(
      icon: Icon(icona, size: 20, color: testoColore),
      label: Text(titolo, style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: testoColore,
          letterSpacing: 0.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutline
            ? Colors.transparent : colore.withOpacity(opacita),
        foregroundColor: testoColore,
        elevation: isOutline ? 0 : 6,
        shadowColor: Colors.black54,
        side: isOutline ? BorderSide(color: colore, width: 1.5) : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius)),
      ),
      onPressed: onTap,
    ),
  );
}