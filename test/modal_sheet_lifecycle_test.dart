import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cerrar sheet de entrenamiento no reutiliza controladores', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = FitnessStore();
    await store.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showWorkoutSheet(context, store),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Test');
    await tester.enterText(find.byType(TextFormField).at(1), 'Cardio');
    await tester.enterText(find.byType(TextFormField).at(2), '20');
    await tester.enterText(find.byType(TextFormField).at(3), '150');

    await tester.tap(find.text('Guardar entrenamiento'));
    await tester.pump();
    await tester.pump(kThemeAnimationDuration + const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
