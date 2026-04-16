import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chatbot muestra opciones guiadas con subniveles', (
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

    await tester.tap(find.byTooltip('Chatbot'));
    await tester.pumpAndSettle();

    expect(
      find.text('Selecciona una categoria para continuar.'),
      findsOneWidget,
    );
    expect(find.text('Progreso diario >'), findsOneWidget);
    expect(find.text('Preguntas guiadas'), findsNothing);
    expect(find.byType(TextField), findsNothing);

    final progressChip = find.widgetWithText(ActionChip, 'Progreso diario >');
    tester.widget<ActionChip>(progressChip).onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.text('Elige una opcion de Progreso diario.'), findsOneWidget);
    expect(find.text('Resumen general >'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);

    final summaryChip = find.widgetWithText(ActionChip, 'Resumen general >');
    tester.widget<ActionChip>(summaryChip).onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      find.text('Elige una opcion de Progreso diario / Resumen general.'),
      findsOneWidget,
    );
    expect(find.text('Resumen de hoy'), findsOneWidget);

    final todaySummaryChip = find.widgetWithText(ActionChip, 'Resumen de hoy');
    tester.widget<ActionChip>(todaySummaryChip).onPressed!.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Resumen de hoy:'), findsOneWidget);
    expect(
      find.text('Elige una opcion de Progreso diario / Resumen general.'),
      findsOneWidget,
    );
  });
}
