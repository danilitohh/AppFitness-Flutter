import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pruebas de smoke/integracion basica para validar el flujo principal de UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fitness app renders authentication shell', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    expect(find.text('AppFitness'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsNothing);
    expect(find.text('Iniciar sesi\u00f3n'), findsOneWidget);
    expect(find.text('\u00bfOlvidaste tu contrase\u00f1a?'), findsOneWidget);
  });

  testWidgets('Auth shell cambia entre login, registro y recuperacion', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    final switchToRegisterButton = find.widgetWithText(
      TextButton,
      'Reg\u00edstrate',
    );
    await tester.ensureVisible(switchToRegisterButton);
    await tester.tap(switchToRegisterButton);
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Danilo');
    await tester.enterText(find.byType(TextFormField).at(1), 'danilo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'Pass1234');
    await tester.enterText(find.byType(TextFormField).at(3), 'Pass1234');

    final backToLogin = find.widgetWithText(TextButton, 'Inicia sesi\u00f3n');
    await tester.ensureVisible(backToLogin);
    await tester.tap(backToLogin);
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesi\u00f3n'), findsOneWidget);

    final forgotPassword = find.widgetWithText(
      TextButton,
      '\u00bfOlvidaste tu contrase\u00f1a?',
    );
    await tester.ensureVisible(forgotPassword);
    await tester.tap(forgotPassword);
    await tester.pumpAndSettle();

    expect(find.text('Recuperar contrase\u00f1a'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Solicitar codigo'),
      findsOneWidget,
    );
  });

  testWidgets('Registro nuevo muestra onboarding y no hereda datos demo', (
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

    expect(
      find.text('Comencemos tu evaluaci\u00f3n inicial, Danilo.'),
      findsOneWidget,
    );
    expect(find.text('Empezar evaluaci\u00f3n'), findsOneWidget);
    expect(find.text('Cardio HIIT'), findsNothing);
    expect(find.text('Avena con fruta'), findsNothing);
  });
}
