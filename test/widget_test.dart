import 'package:flutter_test/flutter_test.dart';

import 'package:pray_iafcj/main.dart';

void main() {
  testWidgets('La pantalla de bienvenida se renderiza correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PrayIAFCJ());

    expect(find.text('Pray IAFCJ'), findsOneWidget);
    expect(
      find.text('Registro de oración y\nlectura bíblica personal'),
      findsOneWidget,
    );
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('Al pulsar continuar se navega a inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PrayIAFCJ());

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de Sesión'), findsOneWidget);
  });
}
