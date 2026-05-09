import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chatbot solo se muestra en dashboard', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting();

    final fitnessStore = FitnessStore();
    final authStore = AuthStore();
    await fitnessStore.initialize();
    await authStore.initialize();
    await authStore.register(
      name: 'Danilo',
      email: 'danilo@test.com',
      password: 'Pass1234',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthAppScope(
          notifier: authStore,
          child: FitnessAppScope(
            notifier: fitnessStore,
            child: const HomeShell(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Chatbot'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    Future<void> tapDestination(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tapDestination('Entreno');

    expect(find.byTooltip('Chatbot'), findsNothing);
    expect(find.text('Chat'), findsNothing);

    await tapDestination('Comidas');
    expect(find.byTooltip('Chatbot'), findsNothing);

    await tapDestination('Progreso');
    expect(find.byTooltip('Chatbot'), findsNothing);

    await tapDestination('Inicio');

    expect(find.byTooltip('Chatbot'), findsOneWidget);
  });
}
