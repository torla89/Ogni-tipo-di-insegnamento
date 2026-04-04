import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'studi_screen.dart';
import 'podcast_screen.dart';
import 'segnalazioni_screen.dart';
import 'download_screen.dart';
import 'pdf_viewer_screen.dart';
import 'video_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDesktop
                  ? 'assets/sfondo_home_desktop.jpeg'
                  : 'assets/sfondo_home.jpeg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.black.withOpacity(0.55),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 48 : 28,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ogni tipo di insegnamento',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 30 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(blurRadius: 8, color: Colors.black54)
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Studi biblici di Ellero Balzani',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(blurRadius: 6, color: Colors.black54)
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          _buildBottone(context,
                            titolo: 'INTRODUZIONE',
                            icona: Icons.info_outline_rounded,
                            colore: const Color(0xFF2E7D32),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const PdfViewerScreen(
                                    nomePdf: 'leggimi.pdf', titolo: 'Introduzione'))),
                          ),
                          const SizedBox(height: 14),
                          _buildBottoneCentrato(context,
                            titolo: 'CONVERSIONE DI ELLERO BALZANI\nVIDEO RICORDO',
                            icona: Icons.play_circle_outline_rounded,
                            colore: const Color(0xFF1829E8),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const VideoScreen())),
                          ),
                          const SizedBox(height: 14),
                          _buildBottone(context,
                            titolo: 'STUDI',
                            icona: Icons.menu_book_rounded,
                            colore: const Color(0xFF1829E8),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => StudiScreen())),
                          ),
                          const SizedBox(height: 14),
                          _buildBottone(context,
                            titolo: 'PODCAST',
                            icona: Icons.headphones_rounded,
                            colore: const Color(0xFF1829E8),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PodcastScreen())),
                          ),
                          const SizedBox(height: 14),
                          _buildBottone(context,
                            titolo: 'DOWNLOAD',
                            icona: Icons.download_rounded,
                            colore: const Color(0xFFE81829),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const DownloadScreen())),
                          ),
                          const SizedBox(height: 14),
                          _buildBottone(context,
                            titolo: 'SEGNALAZIONI',
                            icona: Icons.flag_outlined,
                            colore: const Color(0xFFE81829),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const SegnalazioniScreen())),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIconaLink(
                                icona: Icons.language,
                                etichetta: 'Sito web',
                                url: 'https://www.ognitipodiinsegnamento.it',
                              ),
                              const SizedBox(width: 32),
                              _buildIconaLink(
                                icona: Icons.facebook,
                                etichetta: 'Facebook',
                                url: 'https://www.facebook.com/profile.php?id=61584977437002',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottone(BuildContext context, {
    required String titolo,
    required IconData icona,
    required Color colore,
    required VoidCallback onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 54 : 58,
      child: ElevatedButton.icon(
        icon: Icon(icona, size: 20, color: Colors.white),
        label: Text(
          titolo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colore.withOpacity(0.92),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildBottoneCentrato(BuildContext context, {
    required String titolo,
    required IconData icona,
    required Color colore,
    required VoidCallback onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 64 : 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colore.withOpacity(0.92),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              titolo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconaLink({
    required IconData icona,
    required String etichetta,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: Icon(icona, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 5),
          Text(
            etichetta,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}