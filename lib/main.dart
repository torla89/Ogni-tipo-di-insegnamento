import 'package:flutter_test/flutter_test.dart';
import 'package:ogni_tipo_di_insegnamento/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Qui puoi usare const, perché il tuo costruttore è const.
    await tester.pumpWidget(const OgniTipoDiInsegnamentoApp());

    // Attendi che eventuali microtask/animazioni iniziali si stabilizzino.
    await tester.pumpAndSettle();

    // Verifica che la root widget sia stata montata.
    expect(find.byType(OgniTipoDiInsegnamentoApp), findsOneWidget);
  });
}