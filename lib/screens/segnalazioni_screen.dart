import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SegnalazioniScreen extends StatefulWidget {
  const SegnalazioniScreen({super.key});

  @override
  State<SegnalazioniScreen> createState() => _SegnalazioniScreenState();
}

class _SegnalazioniScreenState extends State<SegnalazioniScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messaggioController = TextEditingController();
  bool _invioInCorso = false;

  Future<void> _invia() async {
    final email = _emailController.text.trim();
    final messaggio = _messaggioController.text.trim();

    if (messaggio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scrivi un messaggio prima di inviare')),
      );
      return;
    }

    setState(() => _invioInCorso = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': 'service_ay33ukk',
          'template_id': 'template_vqhuqlj',
          'user_id': 'c8AZw9t_jFrlFmaK-',
          'template_params': {
            'messaggio': messaggio,
            'email_mittente': email.isEmpty ? 'Non fornita' : email,
          },
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _emailController.clear();
        _messaggioController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Messaggio inviato con successo!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore invio: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di rete: $e')),
      );
    } finally {
      if (mounted) setState(() => _invioInCorso = false);
    }
  }

  Future<void> _apriEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'chiesaevangelicamaranello@outlook.it',
    );
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messaggioController.dispose();
    super.dispose();
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1000;
            final maxWidth = isDesktop ? 650.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 32 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Immagine in alto
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/diagnose_repair_android_670x335.png',
                            width: double.infinity,
                            height: isDesktop ? 160 : 115,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: isDesktop ? 160 : 115,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1829E8).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.bug_report,
                                  size: 64, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'AIUTATECI A MIGLIORARE:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFE81829),
                            fontSize: isDesktop ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Inserisci qui le tue osservazioni',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),

                        const SizedBox(height: 16),

                        // Campo EMAIL
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText:
                                  'La tua email (opzionale, per essere ricontattato)',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Campo MESSAGGIO
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _messaggioController,
                            maxLines: isDesktop ? 10 : 7,
                            decoration: const InputDecoration(
                              hintText: 'Scrivi qui il tuo messaggio...',
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bottone INVIA
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: _invioInCorso
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send, color: Colors.white),
                            label: Text(
                              _invioInCorso ? 'INVIO IN CORSO...' : 'INVIA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE81829),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _invioInCorso ? null : _invia,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'oppure invia direttamente una mail a ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: _apriEmail,
                              child: const Text(
                                'ChiesaEvangelicaMaranello@outlook.it',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1829E8),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF1829E8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
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
