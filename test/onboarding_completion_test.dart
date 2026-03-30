import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Registro completa onboarding guiado y entra al home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    final registerButton = find.widgetWithText(TextButton, 'Reg\u00edstrate');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Danilo');
    await tester.enterText(find.byType(TextFormField).at(1), 'danilo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'Pass1234');
    await tester.enterText(find.byType(TextFormField).at(3), 'Pass1234');

    final createAccountButton = find.text('Crear cuenta');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();
    await tester.pumpAndSettle();

    Future<void> tapPrimary(String label) async {
      final button = find.widgetWithText(FilledButton, label);
      expect(
        button,
        findsOneWidget,
        reason: 'No aparece el botón "$label" en el flujo de onboarding.',
      );
      final filledButton = tester.widget<FilledButton>(button);
      expect(
        filledButton.onPressed,
        isNotNull,
        reason: 'El botón "$label" aparece deshabilitado cuando no debería.',
      );
      filledButton.onPressed!.call();
      await tester.pump();
      await tester.pumpAndSettle();
    }

    await tapPrimary('Empezar evaluaci\u00f3n');
    await tapPrimary('Siguiente');
    await tapPrimary('Siguiente');
    await tapPrimary('Siguiente');
    await tapPrimary('Siguiente');
    await tapPrimary('Siguiente');
    await tapPrimary('Siguiente');
    await tapPrimary('Confirmar y crear mi plan');

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Entreno'), findsWidgets);
    expect(find.text('Comidas'), findsWidgets);
    expect(find.text('Progreso'), findsWidgets);
  });
}
