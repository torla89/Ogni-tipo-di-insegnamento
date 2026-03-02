import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'download_vecchie_versioni_screen.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  Future<void> _apriUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ogni tipo di insegnamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFF58A1C3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'DOWNLOAD\nUFFICIALI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F0E8),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 40),

              // Google Play
              _buildStoreButton(
                onTap: () => _apriUrl('https://play.google.com/store/apps/details?id=com.ognitipodiinsegnamento&pcampaignid=web_share'),
                colore: const Color(0xFF1C2B2A),
                child: Row(
                  children: [
                    CustomPaint(
                      size: const Size(40, 40),
                      painter: GooglePlayLogoPainter(),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GET IT ON',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w400)),
                        Text('Google Play',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Microsoft Store
              _buildStoreButton(
                onTap: () => _apriUrl('https://apps.microsoft.com/detail/9MZCZNDBLKPG?hl=it-it&gl=IT&ocid=pdpshare'),
                colore: const Color(0xFF0A4E8A),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: EdgeInsets.zero,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(4, (_) =>
                            Container(color: const Color(0xFFF5F0E8))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GET IT FROM',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        Text('Microsoft Store',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // App Store
              _buildStoreButton(
                onTap: () => _apriUrl('https://www.apple.com/it/app-store/'),
                colore: const Color(0xFF1A1A1A),
                child: Row(
                  children: [
                    const Icon(Icons.apple, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Download on the',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        Text('App Store',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Download PDF
              _buildStoreButton(
                onTap: () => _apriUrl('https://1drv.ms/u/s!As5zTqPS8veTh0RbiBMYrCdPjWwW?e=Bcm1zb'),
                colore: const Color(0xFFB33A1A),
                child: Row(
                  children: [
                    const Icon(Icons.download, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Download',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text('PDF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DownloadVecchieVersioniScreen())),
                  child: const Text(
                    'Download versioni per sistemi\noperativi meno recenti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF1A3A5C),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF1A3A5C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStoreButton({
    required VoidCallback onTap,
    required Color colore,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colore,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class GooglePlayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paintGreen  = Paint()..color = const Color(0xFF5BC9A0)..style = PaintingStyle.fill;
    final paintYellow = Paint()..color = const Color(0xFFFFD84D)..style = PaintingStyle.fill;
    final paintRed    = Paint()..color = const Color(0xFFFF4545)..style = PaintingStyle.fill;
    final paintBlue   = Paint()..color = const Color(0xFF4A90D9)..style = PaintingStyle.fill;

    final pathGreen = Path();
    pathGreen.moveTo(0, 0);
    pathGreen.lineTo(w * 0.5, h * 0.35);
    pathGreen.lineTo(0, h * 0.5);
    pathGreen.close();
    canvas.drawPath(pathGreen, paintGreen);

    final pathYellow = Path();
    pathYellow.moveTo(0, 0);
    pathYellow.lineTo(w, h * 0.35);
    pathYellow.lineTo(w * 0.5, h * 0.35);
    pathYellow.close();
    canvas.drawPath(pathYellow, paintYellow);

    final pathRed = Path();
    pathRed.moveTo(0, h * 0.5);
    pathRed.lineTo(w * 0.5, h * 0.35);
    pathRed.lineTo(0, h);
    pathRed.close();
    canvas.drawPath(pathRed, paintRed);

    final pathBlue = Path();
    pathBlue.moveTo(w * 0.5, h * 0.35);
    pathBlue.lineTo(w, h * 0.35);
    pathBlue.lineTo(0, h);
    pathBlue.close();
    canvas.drawPath(pathBlue, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
