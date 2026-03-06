
import 'package:flutter_test/flutter_test.dart';
import 'package:ogni_tipo_di_insegnamento/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Se MyApp ha un costruttore const, puoi rimettere const qui.
    await tester.pumpWidget(MyApp());

    // Se la tua app ha async init / first frame / animazioni, meglio settle:
    await tester.pumpAndSettle();

    // Verifica che almeno un widget di tipo MyApp sia stato montato.
    expect(find.byType(MyApp), findsOneWidget);
  });
}