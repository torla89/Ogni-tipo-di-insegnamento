import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class TemaPersonalizzatoScreen extends StatefulWidget {
  final TemaPersonalizzatoSalvato? temaEsistente;
  const TemaPersonalizzatoScreen({super.key, this.temaEsistente});

  @override
  State<TemaPersonalizzatoScreen> createState() =>
      _TemaPersonalizzatoScreenState();
}

class _TemaPersonalizzatoScreenState extends State<TemaPersonalizzatoScreen> {

  // ── Stato locale (non tocca il provider finché non si salva) ──
  late AlternanzaSfondo _alternanza;
  late String _sfondoFissoId;
  late String _sfondoGiornoId;
  late String _sfondoNotteId;
  late StileBottone _stileBottone;
  late Color _coloreBottone;
  late double _opacitaBottone;
  late Color _coloreBottoneGiorno;
  late double _opacitaBottoneGiorno;
  late Color _coloreBottoneNotte;
  late double _opacitaBottoneNotte;
  Color? _coloreTesto;
  Color? _coloreTestoGiorno;
  Color? _coloreTestoNotte;

  bool _inizializzato = false;

  final Set<String> _espanse = {};
  bool _editaGiorno = true;
  int  _sfondoAnteprima = 0;
  final TextEditingController _nomeController = TextEditingController();
  bool _salvando = false;

  static const List<Map<String, dynamic>> _palette = [
    {'colore': Color(0xFFFFFFFF), 'nome': 'Bianco'},
    {'colore': Color(0xFF1829E8), 'nome': 'Blu app'},
    {'colore': Color(0xFF1565C0), 'nome': 'Blu scuro'},
    {'colore': Color(0xFF0D47A1), 'nome': 'Navy'},
    {'colore': Color(0xFF01579B), 'nome': 'Azzurro'},
    {'colore': Color(0xFF006064), 'nome': 'Petrolio'},
    {'colore': Color(0xFF00838F), 'nome': 'Ciano'},
    {'colore': Color(0xFF1B5E20), 'nome': 'Verde scuro'},
    {'colore': Color(0xFF2E7D32), 'nome': 'Verde'},
    {'colore': Color(0xFF388E3C), 'nome': 'Verde chiaro'},
    {'colore': Color(0xFF558B2F), 'nome': 'Verde oliva'},
    {'colore': Color(0xFF33691E), 'nome': 'Verde bosco'},
    {'colore': Color(0xFF004D40), 'nome': 'Verde teal'},
    {'colore': Color(0xFF4A148C), 'nome': 'Viola scuro'},
    {'colore': Color(0xFF6A1B9A), 'nome': 'Viola'},
    {'colore': Color(0xFF7B1FA2), 'nome': 'Viola chiaro'},
    {'colore': Color(0xFF880E4F), 'nome': 'Bordeaux'},
    {'colore': Color(0xFFAD1457), 'nome': 'Fucsia'},
    {'colore': Color(0xFFC2185B), 'nome': 'Rosa scuro'},
    {'colore': Color(0xFFB71C1C), 'nome': 'Rosso scuro'},
    {'colore': Color(0xFFC62828), 'nome': 'Rosso'},
    {'colore': Color(0xFFD32F2F), 'nome': 'Rosso chiaro'},
    {'colore': Color(0xFFBF360C), 'nome': 'Arancio scuro'},
    {'colore': Color(0xFFE65100), 'nome': 'Arancio'},
    {'colore': Color(0xFFF57F17), 'nome': 'Ambra'},
    {'colore': Color(0xFF37474F), 'nome': 'Ardesia'},
    {'colore': Color(0xFF455A64), 'nome': 'Grigio blu'},
    {'colore': Color(0xFF546E7A), 'nome': 'Grigio'},
    {'colore': Color(0xFF4E342E), 'nome': 'Marrone'},
    {'colore': Color(0xFF5D4037), 'nome': 'Marrone chiaro'},
    {'colore': Color(0xFF212121), 'nome': 'Quasi nero'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inizializzato) {
      final t = widget.temaEsistente;
      if (t != null) {
        _alternanza          = t.alternanza;
        _sfondoFissoId       = t.sfondoFissoId;
        _sfondoGiornoId      = t.sfondoGiornoId;
        _sfondoNotteId       = t.sfondoNotteId;
        _stileBottone        = t.stileBottone;
        _coloreBottone       = Color(t.coloreBottone);
        _opacitaBottone      = t.opacitaBottone;
        _coloreBottoneGiorno = Color(t.coloreBottoneGiorno);
        _opacitaBottoneGiorno= t.opacitaBottoneGiorno;
        _coloreBottoneNotte  = Color(t.coloreBottoneNotte);
        _opacitaBottoneNotte = t.opacitaBottoneNotte;
        _coloreTesto         = t.coloreTesto      != null ? Color(t.coloreTesto!)      : null;
        _coloreTestoGiorno   = t.coloreTestoGiorno != null ? Color(t.coloreTestoGiorno!) : null;
        _coloreTestoNotte    = t.coloreTestoNotte  != null ? Color(t.coloreTestoNotte!)  : null;
        _nomeController.text = t.nome;
        _sfondoAnteprima = _indiceSfondoFisso(t.sfondoFissoId);
      } else {
        _alternanza          = AlternanzaSfondo.fisso;
        _sfondoFissoId       = 'chiaro_primavera';
        _sfondoAnteprima     = _indiceSfondoFisso('chiaro_primavera');
        _sfondoGiornoId      = 'chiaro_primavera';
        _sfondoNotteId       = 'scuro_lago';
        _stileBottone        = StileBottone.classico;
        _coloreBottone       = const Color(0xFF1829E8);
        _opacitaBottone      = 0.92;
        _coloreBottoneGiorno = const Color(0xFF1829E8);
        _opacitaBottoneGiorno= 0.92;
        _coloreBottoneNotte  = const Color(0xFF1829E8);
        _opacitaBottoneNotte = 0.92;
        _coloreTesto         = null;
        _coloreTestoGiorno   = null;
        _coloreTestoNotte    = null;
      }
      _inizializzato = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  int _indiceSfondoFisso(String id) {
    final idx = sfondiDisponibili.indexWhere((s) => s.id == id);
    return idx >= 0 ? idx : 0;
  }

  void _toggleSezione(String id) => setState(() {
    if (_espanse.contains(id)) _espanse.remove(id);
    else _espanse.add(id);
  });

  bool _isEspansa(String id) => _espanse.contains(id);

  // ── Getter locali per l'anteprima ────────────────────────────
  bool get _isGiornoNotte =>
      _alternanza == AlternanzaSfondo.giornoNotte ||
          _alternanza == AlternanzaSfondo.giornoNotteRandom;

  Color get _coloreBottoneAttivo {
    if (_isGiornoNotte) {
      final min = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
      final isGiorno = min >= 7 * 60 && min < 21 * 60;
      return isGiorno ? _coloreBottoneGiorno : _coloreBottoneNotte;
    }
    return _coloreBottone;
  }

  double get _opacitaBottoneAttiva {
    if (_isGiornoNotte) {
      final min = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
      final isGiorno = min >= 7 * 60 && min < 21 * 60;
      return isGiorno ? _opacitaBottoneGiorno : _opacitaBottoneNotte;
    }
    return _opacitaBottone;
  }

  bool get _isTestoAutomatico => _coloreTesto == null;

  Color _testoAutoPerColore(Color c) {
    final lum = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return lum > 0.5 ? Colors.black : Colors.white;
  }

  Color get _coloreTestoBottone {
    if (_isGiornoNotte) {
      final min = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
      final isGiorno = min >= 7 * 60 && min < 21 * 60;
      final testoGN = isGiorno ? _coloreTestoGiorno : _coloreTestoNotte;
      if (testoGN != null) return testoGN;
    }
    if (_coloreTesto != null) return _coloreTesto!;
    return _testoAutoPerColore(_coloreBottoneAttivo);
  }

  Color _coloreTestoPerMomento(bool isGiorno) {
    if (_isGiornoNotte) {
      final t = isGiorno ? _coloreTestoGiorno : _coloreTestoNotte;
      if (t != null) return t;
      return _testoAutoPerColore(isGiorno ? _coloreBottoneGiorno : _coloreBottoneNotte);
    }
    if (_coloreTesto != null) return _coloreTesto!;
    return _testoAutoPerColore(_coloreBottone);
  }

  @override
  Widget build(BuildContext context) {
    // Leggiamo il provider SOLO per puoAggiungereNuovoTema e salvaTema
    final provider = context.watch<AppThemeProvider>();

    final radius = _stileBottone == StileBottone.pill ? 30.0
        : _stileBottone == StileBottone.sharp ? 2.0 : 14.0;

    final tuttiSfondi = sfondiDisponibili;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.temaEsistente != null ? 'Modifica tema' : 'Tema personalizzato',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            children: [

              // ── ALTERNANZA ───────────────────────────────────────
              _intestazioneSezione(id: 'alternanza',
                  titolo: 'MODALITÀ ALTERNANZA SFONDO',
                  icona: Icons.image_outlined,
                  sottotitolo: _descAlternanza(_alternanza)),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isEspansa('alternanza')
                    ? Padding(padding: const EdgeInsets.only(bottom: 4),
                    child: _card(child: Column(children: _opzioniAlternanza())))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),

              // ── SFONDO ───────────────────────────────────────────
              _intestazioneSezione(id: 'sfondo',
                  titolo: 'SCELTA SFONDO',
                  icona: Icons.wallpaper_rounded,
                  sottotitolo: _descSfondo()),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isEspansa('sfondo')
                    ? Padding(padding: const EdgeInsets.only(bottom: 4),
                    child: _sfondoSelector())
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),

              // ── STILE ────────────────────────────────────────────
              _intestazioneSezione(id: 'stile',
                  titolo: 'STILE BOTTONI',
                  icona: Icons.smart_button_rounded,
                  sottotitolo: _descStile(_stileBottone)),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isEspansa('stile')
                    ? Padding(padding: const EdgeInsets.only(bottom: 4),
                    child: _card(child: Column(children: _opzioniStile())))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),

              // ── COLORE TESTO ──────────────────────────────────────
              _intestazioneSezione(
                id: 'colore_testo',
                titolo: 'COLORE TESTO BOTTONI',
                icona: Icons.format_color_text_rounded,
                sottotitolo: _isTestoAutomatico
                    ? 'Automatico (basato sul colore bottone)'
                    : _nomePalette(_coloreTestoBottone),
                puntoColore: _isTestoAutomatico ? null : _coloreTestoBottone,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isEspansa('colore_testo')
                    ? Padding(padding: const EdgeInsets.only(bottom: 4),
                    child: _card(child: _sezioneColoreTesto()))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),

              // ── COLORE + TRASPARENZA (solo se NON giornoNotte) ──────
              if (!_isGiornoNotte) ...[
                _intestazioneSezione(id: 'colore',
                    titolo: 'COLORE E TRASPARENZA BOTTONI',
                    icona: Icons.tune_rounded,
                    sottotitolo: '${_nomePalette(_coloreBottone)} · ${(_opacitaBottone * 100).toStringAsFixed(0)}%',
                    puntoColore: _coloreBottone),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isEspansa('colore')
                      ? Padding(padding: const EdgeInsets.only(bottom: 4),
                      child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Colore bottone', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        _gridPalette(selezionato: _coloreBottone, onTap: (c) => setState(() => _coloreBottone = c)),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Expanded(child: Text('Opacità bottone', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600))),
                          Text('${(_opacitaBottone * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        ]),
                        _sliderOpacita(valore: _opacitaBottone, colore: _coloreBottone, coloreSlider: Colors.white, onChanged: (v) => setState(() => _opacitaBottone = v)),
                      ])))
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
              ],

              // ── COLORE BOTTONI (solo se GN) ───────────────────────
              if (_isGiornoNotte) ...[
                _intestazioneSezione(id: 'testo',
                    titolo: 'COLORE BOTTONI',
                    icona: Icons.tune_rounded,
                    sottotitolo: 'Colore e opacità diversi per giorno/notte'),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isEspansa('testo')
                      ? Padding(padding: const EdgeInsets.only(bottom: 4),
                      child: _card(child: _sezioneTestoGiornoNotte()))
                      : const SizedBox.shrink(),
                ),
              ],
              const SizedBox(height: 20),

              // ── ANTEPRIMA ─────────────────────────────────────────
              _sezione('ANTEPRIMA'),
              const SizedBox(height: 10),

              if (_isGiornoNotte) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text('Giorno', style: TextStyle(
                              color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _anteprimaConSfondo(
                        sfondoId: _sfondoGiornoId,
                        colore: _coloreBottoneGiorno,
                        opacita: _opacitaBottoneGiorno,
                        stile: _stileBottone, radius: radius,
                        coloreTesto: _coloreTestoPerMomento(true),
                      ),
                    ])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nights_stay_outlined, color: Colors.lightBlueAccent, size: 14),
                          SizedBox(width: 4),
                          Text('Notte', style: TextStyle(
                              color: Colors.lightBlueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _anteprimaConSfondo(
                        sfondoId: _sfondoNotteId,
                        colore: _coloreBottoneNotte,
                        opacita: _opacitaBottoneNotte,
                        stile: _stileBottone, radius: radius,
                        coloreTesto: _coloreTestoPerMomento(false),
                      ),
                    ])),
                  ],
                ),
              ] else ...[
                _card(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sfondo anteprima',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tuttiSfondi.length,
                        itemBuilder: (_, i) {
                          final sel = _sfondoAnteprima == i;
                          return GestureDetector(
                            onTap: () => setState(() => _sfondoAnteprima = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: sel
                                    ? Border.all(color: Colors.white, width: 2)
                                    : Border.all(color: Colors.white12, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(tuttiSfondi[i].pathMobile, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                _anteprimaConSfondo(
                  sfondoId: _sfondoAnteprima < tuttiSfondi.length
                      ? tuttiSfondi[_sfondoAnteprima].id
                      : tuttiSfondi.first.id,
                  colore: _coloreBottone, opacita: _opacitaBottone,
                  stile: _stileBottone, radius: radius,
                  coloreTesto: _coloreTestoBottone,
                ),
              ],

              const SizedBox(height: 32),

              // ── SALVA TEMA ────────────────────────────────────────
              _sezione('SALVA TEMA'),
              const SizedBox(height: 10),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dai un nome a questo tema per salvarlo e ritrovarlo nel menu impostazioni.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nomeController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      maxLength: 30,
                      decoration: InputDecoration(
                        hintText: 'Es. Primavera, Notturno...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        counterStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white38),
                        ),
                        prefixIcon: const Icon(Icons.label_outline_rounded,
                            color: Colors.white38, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Builder(builder: (context) {
                      final puoSalvare = provider.puoAggiungereNuovoTema;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!puoSalvare)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                SizedBox(width: 6),
                                Text('Hai raggiunto il massimo di 5 temi',
                                    style: TextStyle(color: Colors.orange, fontSize: 12)),
                              ]),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: _salvando
                                  ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.save_rounded, size: 20, color: Colors.white),
                              label: Text(
                                _salvando ? 'Salvataggio...' : (widget.temaEsistente != null ? 'Salva modifiche' : 'Salva tema'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: puoSalvare ? const Color(0xFF1829E8) : Colors.white12,
                                foregroundColor: Colors.white,
                                elevation: puoSalvare ? 4 : 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: puoSalvare && !_salvando
                                  ? () => _salvaTema(context, provider)
                                  : null,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Salva tema — scrive sul provider solo qui ─────────────────
  Future<void> _salvaTema(BuildContext context, AppThemeProvider provider) async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inserisci un nome per il tema'),
        backgroundColor: Color(0xFF1A1A2E),
      ));
      return;
    }
    setState(() => _salvando = true);

    // Scrivi le impostazioni locali sul provider prima di salvare
    await provider.setAlternanza(_alternanza);
    await provider.setSfondoFisso(_sfondoFissoId);
    await provider.setSfondoGiorno(_sfondoGiornoId);
    await provider.setSfondoNotte(_sfondoNotteId);
    await provider.setStileBottone(_stileBottone);
    await provider.setColoreBottone(_coloreBottone);
    await provider.setOpacitaBottone(_opacitaBottone);
    await provider.setColoreBottoneGiorno(_coloreBottoneGiorno);
    await provider.setOpacitaBottoneGiorno(_opacitaBottoneGiorno);
    await provider.setColoreBottoneNotte(_coloreBottoneNotte);
    await provider.setOpacitaBottoneNotte(_opacitaBottoneNotte);
    await provider.setColoreTesto(_coloreTesto);
    await provider.setColoreTestoGiorno(_coloreTestoGiorno);
    await provider.setColoreTestoNotte(_coloreTestoNotte);

    final bool ok;
    if (widget.temaEsistente != null) {
      ok = await provider.sovrascriviTema(widget.temaEsistente!.id, nome);
    } else {
      ok = await provider.salvaTema(nome);
    }
    if (!mounted) return;
    setState(() => _salvando = false);
    if (ok) {
      _nomeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text('Tema "$nome" salvato!'),
        ]),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 2),
      ));
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Errore nel salvataggio'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Sezione testo giorno/notte ───────────────────────────────
  Widget _sezioneTestoGiornoNotte() {
    final coloreAttuale = _editaGiorno ? _coloreBottoneGiorno : _coloreBottoneNotte;
    final opacitaAttuale = _editaGiorno ? _opacitaBottoneGiorno : _opacitaBottoneNotte;
    final coloreSlider = _editaGiorno ? Colors.amber : Colors.lightBlueAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imposta colore e opacità separati per il tema giorno e notte.',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _editaGiorno = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _editaGiorno ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _editaGiorno ? Colors.amber : Colors.white12, width: 1),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.wb_sunny_outlined, color: _editaGiorno ? Colors.amber : Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text('Di giorno', style: TextStyle(
                    color: _editaGiorno ? Colors.amber : Colors.white38,
                    fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _editaGiorno = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_editaGiorno ? Colors.lightBlueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white12, width: 1),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.nights_stay_outlined, color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text('Di notte', style: TextStyle(
                    color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white38,
                    fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          )),
        ]),
        const SizedBox(height: 16),
        const Text('Colore bottone', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _gridPalette(
          selezionato: coloreAttuale,
          onTap: (c) => setState(() {
            if (_editaGiorno) _coloreBottoneGiorno = c;
            else _coloreBottoneNotte = c;
          }),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Text('Opacità bottone',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600))),
          Text('${(opacitaAttuale * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ]),
        _sliderOpacita(
          valore: opacitaAttuale,
          colore: coloreAttuale,
          coloreSlider: coloreSlider,
          onChanged: (v) => setState(() {
            if (_editaGiorno) _opacitaBottoneGiorno = v;
            else _opacitaBottoneNotte = v;
          }),
        ),
        const SizedBox(height: 16),
        _cardInfoTema(
          icona: _editaGiorno ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
          coloreIcona: _editaGiorno ? Colors.amber : Colors.lightBlueAccent,
          titolo: _editaGiorno ? 'Di giorno' : 'Di notte',
          sfondoId: _editaGiorno ? _sfondoGiornoId : _sfondoNotteId,
        ),
      ],
    );
  }

  // ── Sezione testo semplice ───────────────────────────────────
  Widget _sezioneTestoSemplice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Il colore del testo si adatta automaticamente in base allo sfondo — testo scuro su sfondi chiari, testo chiaro su sfondi scuri.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (_alternanza == AlternanzaSfondo.fisso)
          _cardInfoTema(
            icona: Icons.image_outlined,
            coloreIcona: Colors.white54,
            titolo: 'Sfondo attivo',
            sfondoId: _sfondoFissoId,
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12, width: 1),
            ),
            child: const Row(children: [
              Icon(Icons.shuffle_outlined, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Con sfondi random il testo si adatta automaticamente ad ogni sfondo estratto',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              )),
            ]),
          ),
      ],
    );
  }

  // ── Colore testo bottoni ─────────────────────────────────────
  Widget _sezioneColoreTesto() {
    if (_isGiornoNotte) return _sezioneColoreTestoGiornoNotte();
    final isAuto = _coloreTesto == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scegli il colore del testo nei bottoni, oppure lascia automatico.',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 14),
        _bottoneAuto(attivo: isAuto, onTap: () => setState(() => _coloreTesto = null)),
        const SizedBox(height: 12),
        _gridPalette(
          selezionato: _coloreTesto ?? _coloreTestoBottone,
          onTap: (c) => setState(() => _coloreTesto = c),
        ),
        const SizedBox(height: 14),
        _anteprimaTesto(_coloreBottoneAttivo, _opacitaBottoneAttiva, _coloreTestoBottone),
      ],
    );
  }

  Widget _sezioneColoreTestoGiornoNotte() {
    final coloreTestoCorrente = _editaGiorno ? _coloreTestoGiorno : _coloreTestoNotte;
    final coloreBottoneCorrente = _editaGiorno ? _coloreBottoneGiorno : _coloreBottoneNotte;
    final opacitaCorrente = _editaGiorno ? _opacitaBottoneGiorno : _opacitaBottoneNotte;
    final isAuto = coloreTestoCorrente == null;
    final coloreTestoEffettivo = coloreTestoCorrente ?? _testoAutoPerColore(coloreBottoneCorrente);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Imposta il colore del testo separatamente per giorno e notte.',
          style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _editaGiorno = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _editaGiorno ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _editaGiorno ? Colors.amber : Colors.white12, width: 1),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.wb_sunny_outlined, color: _editaGiorno ? Colors.amber : Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text('Di giorno', style: TextStyle(color: _editaGiorno ? Colors.amber : Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        )),
        const SizedBox(width: 8),
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _editaGiorno = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: !_editaGiorno ? Colors.lightBlueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white12, width: 1),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.nights_stay_outlined, color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text('Di notte', style: TextStyle(color: !_editaGiorno ? Colors.lightBlueAccent : Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        )),
      ]),
      const SizedBox(height: 12),
      _bottoneAuto(attivo: isAuto, onTap: () => setState(() {
        if (_editaGiorno) _coloreTestoGiorno = null; else _coloreTestoNotte = null;
      })),
      const SizedBox(height: 12),
      _gridPalette(
        selezionato: coloreTestoEffettivo,
        onTap: (c) => setState(() {
          if (_editaGiorno) _coloreTestoGiorno = c; else _coloreTestoNotte = c;
        }),
      ),
      const SizedBox(height: 14),
      _anteprimaTesto(coloreBottoneCorrente, opacitaCorrente, coloreTestoEffettivo),
    ]);
  }

  Widget _bottoneAuto({required bool attivo, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: attivo ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: attivo ? Colors.white54 : Colors.white12, width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.auto_awesome_rounded, size: 15, color: attivo ? Colors.white : Colors.white38),
          const SizedBox(width: 6),
          Text('Automatico', style: TextStyle(color: attivo ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
          if (attivo) ...[const SizedBox(width: 4), const Icon(Icons.check_circle_rounded, color: Colors.white, size: 13)],
        ]),
      ),
    );
  }

  Widget _anteprimaTesto(Color coloreBottone, double opacita, Color coloreTesto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: coloreBottone.withOpacity(opacita),
        borderRadius: BorderRadius.circular(10),
        border: _stileBottone == StileBottone.outline ? Border.all(color: coloreBottone, width: 1.5) : null,
      ),
      child: Center(child: Text('Anteprima testo bottone',
          style: TextStyle(color: coloreTesto, fontSize: 14, fontWeight: FontWeight.w600))),
    );
  }

  // ── Grid palette colori ──────────────────────────────────────
  Widget _gridPalette({required Color selezionato, required void Function(Color) onTap}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
      ),
      itemCount: _palette.length,
      itemBuilder: (_, i) {
        final c = _palette[i]['colore'] as Color;
        final sel = selezionato == c;
        final isBianco = c == const Color(0xFFFFFFFF);
        return GestureDetector(
          onTap: () => onTap(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(8),
              border: sel ? Border.all(color: Colors.white, width: 3)
                  : isBianco ? Border.all(color: Colors.white38, width: 1)
                  : Border.all(color: Colors.white12, width: 1),
              boxShadow: sel ? [BoxShadow(color: isBianco ? Colors.white38 : c.withOpacity(0.6), blurRadius: 8)] : null,
            ),
            child: sel ? Icon(Icons.check_rounded, color: isBianco ? Colors.black : Colors.white, size: 18) : null,
          ),
        );
      },
    );
  }

  // ── Slider opacità ───────────────────────────────────────────
  Widget _sliderOpacita({
    required double valore, required Color colore,
    required Color coloreSlider, required void Function(double) onChanged,
  }) {
    return Column(children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: coloreSlider, inactiveTrackColor: Colors.white24,
          thumbColor: coloreSlider, overlayColor: Colors.white24,
          trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        child: Slider(value: valore, min: 0.1, max: 1.0, divisions: 18, onChanged: onChanged),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text('Trasparente', style: TextStyle(color: Colors.white38, fontSize: 11)),
        Text('Pieno', style: TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [0.3, 0.6, 0.8, 1.0].map((op) {
          final attivo = (valore - op).abs() < 0.08;
          return GestureDetector(
            onTap: () => onChanged(op),
            child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52, height: 28,
                decoration: BoxDecoration(
                  color: colore.withOpacity(op),
                  borderRadius: BorderRadius.circular(6),
                  border: attivo ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.white24, width: 1),
                ),
                child: Center(child: Text('Aa', style: TextStyle(
                    color: Colors.white.withOpacity(op > 0.4 ? 1 : 0.6),
                    fontSize: 11, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 4),
              Text('${(op * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: attivo ? Colors.white : Colors.white38, fontSize: 10)),
            ]),
          );
        }).toList(),
      ),
    ]);
  }

  // ── Anteprima con sfondo reale ───────────────────────────────
  Widget _anteprimaConSfondo({
    required String sfondoId, required Color colore, required double opacita,
    required StileBottone stile, required double radius, Color? coloreTesto,
  }) {
    final sfondo = sfondiDisponibili.firstWhere((s) => s.id == sfondoId, orElse: () => sfondiDisponibili.first);
    final isChiaro = sfondo.isChiaro;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 260,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(sfondo.pathMobile), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.45)],
          )),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ogni tipo di insegnamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,
                      color: isChiaro ? const Color(0xFF2C1A0E) : Colors.white,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black38)])),
              const SizedBox(height: 12),
              if (stile == StileBottone.lista) ...[
                _rigaListaAnteprima('Studi', Icons.menu_book_rounded, isChiaro),
                Divider(height: 1, color: isChiaro ? Colors.black26 : Colors.white24),
                _rigaListaAnteprima('Podcast', Icons.headphones_rounded, isChiaro),
                Divider(height: 1, color: isChiaro ? Colors.black26 : Colors.white24),
                _rigaListaAnteprima('Predicazioni', Icons.record_voice_over_rounded, isChiaro),
              ] else ...[
                _bottoneAnteprimaReale('STUDI', Icons.menu_book_rounded, colore, opacita, radius, stile, coloreTesto: coloreTesto),
                const SizedBox(height: 6),
                _bottoneAnteprimaReale('PODCAST', Icons.headphones_rounded, colore, opacita, radius, stile, coloreTesto: coloreTesto),
                const SizedBox(height: 6),
                _bottoneAnteprimaReale('PREDICAZIONI', Icons.record_voice_over_rounded, colore, opacita, radius, stile, coloreTesto: coloreTesto),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Opzioni alternanza ───────────────────────────────────────
  List<Widget> _opzioniAlternanza() {
    final opzioni = [
      (AlternanzaSfondo.fisso, 'Sfondo fisso', Icons.image_outlined, 'Usa sempre lo stesso sfondo'),
      (AlternanzaSfondo.giornoNotte, 'Giorno / Notte', Icons.brightness_auto_outlined, 'Sfondo chiaro di giorno, scuro di notte'),
      (AlternanzaSfondo.giornoNotteRandom, 'Giorno / Notte random', Icons.shuffle_outlined, 'Sceglie a caso tra chiari/scuri in base all\'ora'),
      (AlternanzaSfondo.randomStagionale, 'Giorno / Notte stagionale', Icons.wb_cloudy_outlined, 'Cambia sfondo con le stagioni'),
      (AlternanzaSfondo.randomApertura, 'Random all\'apertura', Icons.casino_outlined, 'Cambia sfondo ogni volta che apri l\'app'),
      (AlternanzaSfondo.randomGiornaliero, 'Random giornaliero', Icons.today_outlined, 'Cambia sfondo una volta al giorno'),
    ];
    return opzioni.map((o) {
      final sel = _alternanza == o.$1;
      return GestureDetector(
        onTap: () => setState(() => _alternanza = o.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: sel ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? Colors.white54 : Colors.white12, width: 1),
          ),
          child: Row(children: [
            Icon(o.$3, color: sel ? Colors.white : Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.$2, style: TextStyle(color: sel ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(o.$4, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            if (sel) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          ]),
        ),
      );
    }).toList();
  }

  // ── Selector sfondo ──────────────────────────────────────────
  Widget _sfondoSelector() {
    switch (_alternanza) {
      case AlternanzaSfondo.fisso:
        return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sfondo', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _grigliaSfondi(sfondi: sfondiDisponibili, idSelezionato: _sfondoFissoId,
              onTap: (id) => setState(() { _sfondoFissoId = id; _sfondoAnteprima = _indiceSfondoFisso(id); })),
        ]));
      case AlternanzaSfondo.giornoNotte:
        return Column(children: [
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 18), SizedBox(width: 8),
              Text('Sfondo di giorno', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 4),
            const Text('Solo sfondi chiari', style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 12),
            _grigliaSfondi(sfondi: sfondiChiari, idSelezionato: _sfondoGiornoId,
                onTap: (id) => setState(() => _sfondoGiornoId = id)),
          ])),
          const SizedBox(height: 12),
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.nights_stay_outlined, color: Colors.lightBlueAccent, size: 18), SizedBox(width: 8),
              Text('Sfondo di notte', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 4),
            const Text('Solo sfondi scuri', style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 12),
            _grigliaSfondi(sfondi: sfondiScuri, idSelezionato: _sfondoNotteId,
                onTap: (id) => setState(() => _sfondoNotteId = id)),
          ])),
        ]);
      case AlternanzaSfondo.giornoNotteRandom:
        return _card(child: const Row(children: [
          Icon(Icons.shuffle_outlined, color: Colors.white38, size: 20), SizedBox(width: 12),
          Expanded(child: Text('L\'app sceglie automaticamente tra sfondi chiari di giorno e scuri di notte',
              style: TextStyle(color: Colors.white54, fontSize: 13))),
        ]));
      default:
        return _card(child: const Row(children: [
          Icon(Icons.casino_outlined, color: Colors.white38, size: 20), SizedBox(width: 12),
          Expanded(child: Text('L\'app sceglie automaticamente tra tutti gli sfondi disponibili',
              style: TextStyle(color: Colors.white54, fontSize: 13))),
        ]));
    }
  }

  // ── Griglia sfondi ───────────────────────────────────────────
  Widget _grigliaSfondi({required List<SfondoApp> sfondi, required String idSelezionato, required void Function(String) onTap}) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
      itemCount: sfondi.length,
      itemBuilder: (_, i) {
        final sfondo = sfondi[i];
        final sel = sfondo.id == idSelezionato;
        return GestureDetector(
          onTap: () => onTap(sfondo.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: sel ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.white12, width: 1),
              boxShadow: sel ? [const BoxShadow(color: Colors.white24, blurRadius: 8)] : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(sel ? 7 : 9),
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(sfondo.pathMobile, fit: BoxFit.cover),
                if (sel) Container(color: Colors.black26,
                    child: const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28))),
              ]),
            ),
          ),
        );
      },
    );
  }

  // ── Opzioni stile ────────────────────────────────────────────
  List<Widget> _opzioniStile() {
    final opzioni = [
      (StileBottone.classico, 'Classico', 'Bottoni colorati pieni'),
      (StileBottone.outline,  'Outline',  'Solo bordo, sfondo trasparente'),
      (StileBottone.pill,     'Pill',     'Bottoni a capsula arrotondata'),
      (StileBottone.sharp,    'Sharp',    'Bottoni squadrati'),
      (StileBottone.lista,    'Lista',    'Voci con divisori, senza bottone'),
    ];
    return opzioni.map((o) {
      final sel = _stileBottone == o.$1;
      return GestureDetector(
        onTap: () => setState(() => _stileBottone = o.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: sel ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? Colors.white54 : Colors.white12, width: 1),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.$2, style: TextStyle(color: sel ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(o.$3, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            _miniBottone(o.$1, _coloreBottone, _opacitaBottone, sel),
            if (sel) ...[const SizedBox(width: 8), const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18)],
          ]),
        ),
      );
    }).toList();
  }

  // ── Mini anteprima bottone ───────────────────────────────────
  Widget _miniBottone(StileBottone stile, Color colore, double opacita, bool sel) {
    final radius = stile == StileBottone.pill ? 20.0 : stile == StileBottone.sharp ? 2.0 : 8.0;
    if (stile == StileBottone.lista) {
      return Container(width: 60, height: 28,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sel ? Colors.white54 : Colors.white24, width: 1))),
          child: Center(child: Text('Lista', style: TextStyle(color: sel ? Colors.white : Colors.white38, fontSize: 11))));
    }
    final isBianco = colore == const Color(0xFFFFFFFF);
    return Container(
      width: 60, height: 28,
      decoration: BoxDecoration(
        color: stile == StileBottone.outline ? Colors.transparent : colore.withOpacity(opacita),
        borderRadius: BorderRadius.circular(radius),
        border: stile == StileBottone.outline ? Border.all(color: colore, width: 1.5)
            : isBianco ? Border.all(color: Colors.white38, width: 1) : null,
      ),
      child: Center(child: Text('Aa', style: TextStyle(
          color: stile == StileBottone.outline ? colore : isBianco ? Colors.black : Colors.white,
          fontSize: 11, fontWeight: FontWeight.bold))),
    );
  }

  // ── Bottone anteprima ────────────────────────────────────────
  Widget _bottoneAnteprimaReale(String testo, IconData icona, Color colore, double opacita, double radius, StileBottone stile, {Color? coloreTesto}) {
    final isOutline = stile == StileBottone.outline;
    final isBianco  = colore == const Color(0xFFFFFFFF);
    final Color testoC = coloreTesto ?? (isOutline ? colore : isBianco ? Colors.black : Colors.white);
    return Container(
      width: double.infinity, height: 42,
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : colore.withOpacity(opacita),
        borderRadius: BorderRadius.circular(radius),
        border: isOutline ? Border.all(color: colore, width: 1.5) : isBianco ? Border.all(color: Colors.white54, width: 1) : null,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icona, size: 16, color: testoC),
        const SizedBox(width: 6),
        Text(testo, style: TextStyle(color: testoC, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ]),
    );
  }

  // ── Riga lista anteprima ─────────────────────────────────────
  Widget _rigaListaAnteprima(String testo, IconData icona, bool sfondoChiaro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icona, size: 18, color: sfondoChiaro ? const Color(0xFF5C3D1E) : Colors.white54),
        const SizedBox(width: 12),
        Text(testo, style: TextStyle(color: sfondoChiaro ? const Color(0xFF2C1A0E) : Colors.white70, fontSize: 14)),
      ]),
    );
  }

  // ── Card info tema ───────────────────────────────────────────
  Widget _cardInfoTema({required IconData icona, required Color coloreIcona, required String titolo, required String sfondoId}) {
    final isChiaro   = _isChiaroSfondo(sfondoId);
    final nomeSfondo = _nomeSfondo(sfondoId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icona, color: coloreIcona, size: 16), const SizedBox(width: 6),
          Text(titolo, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Text(nomeSfondo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Row(children: [
          Icon(isChiaro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isChiaro ? Colors.amber : Colors.lightBlueAccent, size: 12),
          const SizedBox(width: 4),
          Text(isChiaro ? 'Testo scuro' : 'Testo chiaro',
              style: TextStyle(color: isChiaro ? Colors.amber : Colors.lightBlueAccent, fontSize: 11)),
        ]),
      ]),
    );
  }

  // ── Intestazione collassabile ────────────────────────────────
  Widget _intestazioneSezione({required String id, required String titolo, required IconData icona, required String sottotitolo, Color? puntoColore}) {
    final aperta = _isEspansa(id);
    return GestureDetector(
      onTap: () => _toggleSezione(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: aperta ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: aperta ? Colors.white38 : Colors.white12, width: 1),
        ),
        child: Row(children: [
          Icon(icona, color: aperta ? Colors.white : Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titolo, style: TextStyle(color: aperta ? Colors.white : Colors.white70,
                fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            const SizedBox(height: 2),
            Row(children: [
              if (puntoColore != null) ...[
                Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: puntoColore, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1))),
              ],
              Flexible(child: Text(sottotitolo, style: const TextStyle(color: Colors.white38, fontSize: 11))),
            ]),
          ])),
          AnimatedRotation(turns: aperta ? 0.5 : 0, duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 20)),
        ]),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  bool _isChiaroSfondo(String id) {
    final s = sfondiDisponibili.firstWhere((s) => s.id == id, orElse: () => sfondiDisponibili.first);
    return s.isChiaro;
  }

  String _nomeSfondo(String id) {
    final s = sfondiDisponibili.firstWhere((s) => s.id == id, orElse: () => sfondiDisponibili.first);
    return s.pathMobile.split('/').last.replaceAll('.png', '');
  }

  String _descAlternanza(AlternanzaSfondo a) {
    switch (a) {
      case AlternanzaSfondo.fisso:             return 'Sfondo fisso';
      case AlternanzaSfondo.giornoNotte:       return 'Giorno / Notte';
      case AlternanzaSfondo.giornoNotteRandom: return 'Giorno / Notte random';
      case AlternanzaSfondo.randomApertura:    return 'Random all\'apertura';
      case AlternanzaSfondo.randomGiornaliero: return 'Random giornaliero';
      case AlternanzaSfondo.randomStagionale:  return 'Random stagionale';
    }
  }

  String _descSfondo() {
    switch (_alternanza) {
      case AlternanzaSfondo.fisso:        return _nomeSfondo(_sfondoFissoId);
      case AlternanzaSfondo.giornoNotte:  return '☀ ${_nomeSfondo(_sfondoGiornoId)}  🌙 ${_nomeSfondo(_sfondoNotteId)}';
      case AlternanzaSfondo.giornoNotteRandom: return 'Chiari di giorno · scuri di notte';
      default: return 'Automatico';
    }
  }

  String _descStile(StileBottone s) {
    switch (s) {
      case StileBottone.classico: return 'Bottoni colorati pieni';
      case StileBottone.outline:  return 'Solo bordo trasparente';
      case StileBottone.pill:     return 'Capsula arrotondata';
      case StileBottone.sharp:    return 'Squadrati';
      case StileBottone.lista:    return 'Lista con divisori';
    }
  }

  String _nomePalette(Color c) {
    for (final p in _palette) { if ((p['colore'] as Color) == c) return p['nome'] as String; }
    return 'Personalizzato';
  }

  Widget _sezione(String titolo) => Text(titolo,
      style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2));

  Widget _card({required Widget child}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12, width: 1)),
    child: child,
  );
}