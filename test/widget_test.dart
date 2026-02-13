import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pruebas de smoke/integracion basica para validar el flujo principal de UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Verifica que el shell de autenticacion renderiza sus elementos base.
  testWidgets('Fitness app renders authentication shell', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    expect(find.text('AppFitness'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Olvide mi contraseña'), findsOneWidget);
  });

  // Verifica el flujo de registro + apertura de chatbot + respuesta util del bot.
  testWidgets('Chatbot responde preguntas fitness en Home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    final switchToRegisterButton = find.widgetWithText(TextButton, 'Crear cuenta');
    await tester.ensureVisible(switchToRegisterButton);
    await tester.tap(switchToRegisterButton);
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Danilo');
    await tester.enterText(find.byType(TextFormField).at(1), 'danilo@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'Pass1234');
    await tester.enterText(find.byType(TextFormField).at(3), 'Pass1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Asistente fitness'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'como voy de agua');
    await tester.tap(find.text('Enviar'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.textContaining('ml de agua'), findsWidgets);
    expect(
      find.textContaining('No tengo una respuesta exacta para eso aun'),
      findsNothing,
    );
  });
}
