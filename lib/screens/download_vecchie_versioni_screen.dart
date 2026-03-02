import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DownloadVecchieVersioniScreen extends StatelessWidget {
  const DownloadVecchieVersioniScreen({super.key});

  Future<void> _apriUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  void _condividi(String testo) {
    Share.share(testo);
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── SEZIONE WINDOWS ──────────────────────────────
              _buildSezione(
                titolo: 'Tutte le versioni Windows',
                logoWidget: _logoWindows(),
                link: 'https://1drv.ms/u/s!As5zTqPS8veTalg68yDGaNJSSr0',
                testoCondivisione: 'Ciao.. scarica l\'app Ogni tipo di insegnamento per pc windows al link: https://1drv.ms/u/s!As5zTqPS8veTalg68yDGaNJSSr0',
                onApriLink: () => _apriUrl('https://1drv.ms/u/s!As5zTqPS8veTalg68yDGaNJSSr0'),
                onCondividi: () => _condividi('Ciao.. scarica l\'app Ogni tipo di insegnamento per pc windows al link: https://1drv.ms/u/s!As5zTqPS8veTalg68yDGaNJSSr0'),
              ),

              const SizedBox(height: 40),

              // ── SEZIONE ANDROID ───────────────────────────────
              _buildSezione(
                titolo: 'Tutte le versioni Android',
                logoWidget: _logoAndroid(),
                link: 'https://1drv.ms/u/s!As5zTqPS8veTh0bR69FyuZDMzAGV?e=oru0wa',
                testoCondivisione: 'Ciao.. scarica l\'app Ogni tipo di insegnamento per android ed android tv al link: https://1drv.ms/u/s!As5zTqPS8veTh0bR69FyuZDMzAGV?e=oru0wa',
                onApriLink: () => _apriUrl('https://1drv.ms/u/s!As5zTqPS8veTh0bR69FyuZDMzAGV?e=oru0wa'),
                onCondividi: () => _condividi('Ciao.. scarica l\'app Ogni tipo di insegnamento per android ed android tv al link: https://1drv.ms/u/s!As5zTqPS8veTh0bR69FyuZDMzAGV?e=oru0wa'),
              ),

              const SizedBox(height: 40),

              // ── SEZIONE PDF ───────────────────────────────────
              _buildSezione(
                titolo: 'Download diretto PDF',
                logoWidget: _logoPdfApple(),
                link: 'https://1drv.ms/u/s!As5zTqPS8veTh0RbiBMYrCdPjWwW?e=Bcm1zb',
                testoCondivisione: 'Ciao.. scarica i pdf dell\'app Ogni tipo di insegnamento (compatibile con ios): https://1drv.ms/u/s!As5zTqPS8veTh0RbiBMYrCdPjWwW?e=Bcm1zb',
                onApriLink: () => _apriUrl('https://1drv.ms/u/s!As5zTqPS8veTh0RbiBMYrCdPjWwW?e=Bcm1zb'),
                onCondividi: () => _condividi('Ciao.. scarica i pdf dell\'app Ogni tipo di insegnamento (compatibile con ios): https://1drv.ms/u/s!As5zTqPS8veTh0RbiBMYrCdPjWwW?e=Bcm1zb'),
              ),

              const SizedBox(height: 32),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSezione({
    required String titolo,
    required Widget logoWidget,
    required String link,
    required String testoCondivisione,
    required VoidCallback onApriLink,
    required VoidCallback onCondividi,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        Text(
          titolo,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Logo
        logoWidget,
        const SizedBox(height: 8),

        // Link cliccabile
        GestureDetector(
          onTap: onApriLink,
          child: Text(
            'Download: $link',
            style: const TextStyle(
              color: Color(0xFF1829E8),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF1829E8),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Riga Condividi
        Row(
          children: [
            const Text('Condividi link: ', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            InkWell(
              onTap: onCondividi,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.black87, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Logo Windows fatto con widget
  Widget _logoWindows() {
    return SizedBox(
      width: 50,
      height: 50,
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.zero,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(color: const Color(0xFF00A4EF)),
          Container(color: const Color(0xFF7FBA00)),
          Container(color: const Color(0xFFFFB900)),
          Container(color: const Color(0xFFF25022)),
        ],
      ),
    );
  }

  // Logo Android
  Widget _logoAndroid() {
    return const Icon(Icons.android, size: 50, color: Color(0xFF3DDC84));
  }

  // Logo PDF + Apple
  Widget _logoPdfApple() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE81829),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('PDF',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.apple, size: 50, color: Colors.black87),
      ],
    );
  }
}
