import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/categorie.dart';
import '../theme_provider.dart';
import 'categoria_screen.dart';
import 'cerca_screen.dart';

String _titoloVisualizzato(String titolo) {
  const Map<String, String> override = {
    'chiedere perdono o confessare il peccato': 'chiedere perdono o confessare il peccato?',
    'cosa vorresti che fosse scritto sulla tua epigrafe': 'cosa vorresti che fosse scritto sulla tua epigrafe?',
    'credenti o discepoli': 'credenti o discepoli?',
    'Perché la legge': 'Perché la legge?',
    'sono io chiamato a predicare': 'sono io chiamato a predicare?',
    'Chi può rimettere i peccati': 'Chi può rimettere i peccati?',
    'Chi sono i pagani': 'Chi sono i pagani?',
    'Di che cosa hai paura': 'Di che cosa hai paura?',
    'dove era il codice stradale': 'dove era il codice stradale?',
    'perché predicare il vangelo se gli uomini sono salvati senza': 'perché predicare il vangelo se gli uomini sono salvati senza?',
    'Fede sì, ma in che cosa': 'Fede sì, ma in che cosa?',
    'Dio mio, Dio mio, perchè mi hai abbandonato': 'Dio mio, Dio mio, perchè mi hai abbandonato?',
    'e se Gesù non fosse risorto': 'e se Gesù non fosse risorto?',
    'gesù si idenfica con JHWH oppure lo è': 'gesù si idenfica con JHWH oppure lo è?',
    'Perché servire Dio': 'Perché servire Dio?',
    'l\'unione degli omosessuali è naturale': 'l\'unione degli omosessuali è naturale?',
    'L\'unione dei gay è un matrimonio': 'L\'unione dei gay è un matrimonio?',
    'Ma perché quell\'uno lo fece': 'Ma perché quell\'uno lo fece?',
    'Non ti basta il Signore': 'Non ti basta il Signore?',
    'nudo integrale si o no': 'nudo integrale si o no?',
    'Sposi vinti o convinti': 'Sposi vinti o convinti?',
    'Spirito Santo o spirito maligno': 'Spirito Santo o spirito maligno?',
  };
  return override[titolo] ?? titolo;
}

const _kBottoneClassico = Color(0xFF1829E8);
const _kCercaClassico = Color(0xFF2E7D32);
const _kAppBarClassico = Color(0xFF1829E8);
const _kAppBarScuro = Color(0xCC0A0A1A);
const _kAppBarChiaro = Color(0xCCFFFFFF);

class StudiScreen extends StatefulWidget {
  const StudiScreen({super.key});

  @override
  State<StudiScreen> createState() => _StudiScreenState();
}

class _StudiScreenState extends State<StudiScreen> {
  late List<Categoria> _tutteLeCategorie;

  @override
  void initState() {
    super.initState();
    _tutteLeCategorie = List<Categoria>.from(categorie)
      ..sort((a, b) => a.titolo.compareTo(b.titolo));
  }

  int get _totaleStudi =>
      _tutteLeCategorie.fold(0, (sum, c) => sum + c.voci.length);

  // Bottone classico mobile (flex height, 2 colonne)
  Widget _buildBottoneClassicoMobile(
      BuildContext context, {
        required Categoria cat,
        required double fontSize,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBottoneClassico,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CategoriaScreen(categoria: cat))),
      child: Text(
        _titoloVisualizzato(cat.titolo).toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // Bottone classico desktop (altezza fissa 54, stile vecchio)
  Widget _buildBottoneClassicoDesktop(
      BuildContext context, {
        required Categoria cat,
        required double fontSize,
      }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _kBottoneClassico,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CategoriaScreen(categoria: cat))),
        child: Text(
          _titoloVisualizzato(cat.titolo).toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppThemeProvider>();
    final tema = provider.tema;
    final isModerno = tema != AppTema.classico;
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final sfondo = isDesktop ? provider.sfondoDesktop : provider.sfondoMobile;
    final fontSize = provider.fontSizeBottone;

    final Color kAppBarColore;
    final Color kTestoColore;
    final Color kTestoSecColore;
    final Color kIconaColore;
    final Color kCercaColore;
    final Color kDivisoreColore;
    final Color kSfondoRiga;

    switch (tema) {
      case AppTema.classico:
        kAppBarColore = _kAppBarClassico;
        kTestoColore = Colors.white;
        kTestoSecColore = Colors.white70;
        kIconaColore = Colors.white70;
        kCercaColore = _kCercaClassico;
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.transparent;
        break;
      case AppTema.modernoScuro:
        kAppBarColore = _kAppBarScuro;
        kTestoColore = Colors.white;
        kTestoSecColore = Colors.white60;
        kIconaColore = Colors.white60;
        kCercaColore = Colors.white.withOpacity(0.1);
        kDivisoreColore = Colors.white24;
        kSfondoRiga = Colors.black.withOpacity(0.25);
        break;
      case AppTema.modernoChiaro:
        kAppBarColore = _kAppBarChiaro;
        kTestoColore = const Color(0xFF1A0A00);
        kTestoSecColore = const Color(0xFF5C3D1E);
        kIconaColore = const Color(0xFF5C3D1E);
        kCercaColore = Colors.white.withOpacity(0.45);
        kDivisoreColore = const Color(0x445C3D1E);
        kSfondoRiga = Colors.white.withOpacity(0.45);
        break;
    }

    final meta = (_tutteLeCategorie.length / 2).ceil();
    final colonnaSinistra = _tutteLeCategorie.sublist(0, meta);
    final colonnaDestra = _tutteLeCategorie.sublist(meta);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kAppBarColore,
        foregroundColor: kTestoColore,
        elevation: 0,
        title: Text('Studi',
            style: TextStyle(color: kTestoColore,
                fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kTestoColore),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(sfondo), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(provider.gradienteTop),
                Colors.black.withOpacity(provider.gradienteBottom),
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isModerno
                  ? _buildModerno(context,
                provider: provider,
                tema: tema,
                isDesktop: isDesktop,
                fontSize: fontSize,
                kTestoColore: kTestoColore,
                kTestoSecColore: kTestoSecColore,
                kIconaColore: kIconaColore,
                kCercaColore: kCercaColore,
                kDivisoreColore: kDivisoreColore,
                kSfondoRiga: kSfondoRiga,
              )
                  : _buildClassico(context,
                isDesktop: isDesktop,
                fontSize: fontSize,
                colonnaSinistra: colonnaSinistra,
                colonnaDestra: colonnaDestra,
                kCercaColore: kCercaColore,
                provider: provider,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layout CLASSICO ──────────────────────────────────────────────
  Widget _buildClassico(
      BuildContext context, {
        required bool isDesktop,
        required double fontSize,
        required List<Categoria> colonnaSinistra,
        required List<Categoria> colonnaDestra,
        required Color kCercaColore,
        required AppThemeProvider provider,
      }) {
    if (isDesktop) {
      // Desktop classico: 4 colonne, bottoni stile vecchio altezza 54
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Colors.white70, size: 36),
                  const SizedBox(height: 8),
                  const Text('Studi biblici di Ellero Balzani',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic, color: Colors.white,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
                  const SizedBox(height: 4),
                  Text('${_tutteLeCategorie.length} categorie · $_totaleStudi studi',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.manage_search_rounded,
                          color: Colors.white, size: 18),
                      label: Text('Cerca per parole chiave',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: provider.fontSizeBottone,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCercaColore,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CercaScreen())),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 4.5,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBottoneClassicoDesktop(context,
                    cat: _tutteLeCategorie[index], fontSize: fontSize),
                childCount: _tutteLeCategorie.length,
              ),
            ),
          ),
        ],
      );
    }

    // Mobile classico: 2 colonne
    final numRighe = colonnaSinistra.length;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 36),
        const SizedBox(height: 8),
        const Text('Studi biblici di Ellero Balzani',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic, color: Colors.white,
                shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
        const SizedBox(height: 4),
        Text('${_tutteLeCategorie.length} categorie · $_totaleStudi studi',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.manage_search_rounded,
                color: Colors.white, size: 18),
            label: Text('Cerca per parole chiave',
                style: TextStyle(color: Colors.white,
                    fontSize: provider.fontSizeBottone)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kCercaColore,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CercaScreen())),
          ),
        ),
        const SizedBox(height: 6),
        ...List.generate(numRighe, (i) {
          final catSx = colonnaSinistra[i];
          Widget destro = i < colonnaDestra.length
              ? _buildBottoneClassicoMobile(context,
              cat: colonnaDestra[i], fontSize: fontSize)
              : const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildBottoneClassicoMobile(context,
                      cat: catSx, fontSize: fontSize)),
                  const SizedBox(width: 4),
                  Expanded(child: destro),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Layout MODERNI (lista singola colonna su mobile E desktop) ───
  Widget _buildModerno(
      BuildContext context, {
        required AppThemeProvider provider,
        required AppTema tema,
        required bool isDesktop,
        required double fontSize,
        required Color kTestoColore,
        required Color kTestoSecColore,
        required Color kIconaColore,
        required Color kCercaColore,
        required Color kDivisoreColore,
        required Color kSfondoRiga,
      }) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16, 20, isDesktop ? 24 : 16, 8),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, color: kIconaColore, size: 36),
                const SizedBox(height: 8),
                Text('Studi biblici di Ellero Balzani',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic, color: kTestoColore,
                      shadows: tema == AppTema.modernoChiaro
                          ? [] : const [Shadow(blurRadius: 6, color: Colors.black54)],
                    )),
                const SizedBox(height: 4),
                Text('${_tutteLeCategorie.length} categorie · $_totaleStudi studi',
                    style: TextStyle(fontSize: 13, color: kTestoSecColore)),
                const SizedBox(height: 12),
                // Bottone cerca stile lista
                InkWell(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CercaScreen())),
                  child: Container(
                    color: kSfondoRiga,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded,
                            size: 22, color: kTestoSecColore),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text('Cerca per parole chiave',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kTestoColore,
                                fontSize: provider.fontSizeBottone,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: kDivisoreColore),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        // Lista singola colonna su mobile E desktop
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
              isDesktop ? 24 : 16, 0, isDesktop ? 24 : 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final cat = _tutteLeCategorie[index];
                final isUltimo = index == _tutteLeCategorie.length - 1;
                return Container(
                  color: kSfondoRiga,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) =>
                                CategoriaScreen(categoria: cat))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: kTestoSecColore,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_titoloVisualizzato(cat.titolo),
                                        style: TextStyle(
                                          color: kTestoColore,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    Text('${cat.voci.length} studi',
                                        style: TextStyle(
                                            color: kTestoSecColore,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  size: 20, color: kTestoSecColore),
                            ],
                          ),
                        ),
                      ),
                      if (!isUltimo)
                        Divider(height: 1, thickness: 1, color: kDivisoreColore),
                    ],
                  ),
                );
              },
              childCount: _tutteLeCategorie.length,
            ),
          ),
        ),
      ],
    );
  }
}