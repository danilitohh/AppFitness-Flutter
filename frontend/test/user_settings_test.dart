import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthStore actualiza datos personales del usuario', () async {
    SharedPreferences.setMockInitialValues({});

    final authStore = AuthStore();
    await authStore.initialize();
    await authStore.register(
      name: 'Danilo',
      email: 'danilo@test.com',
      password: 'Pass1234',
    );

    final result = await authStore.updateCurrentUserProfile(
      name: 'Daniel Gomez',
      age: 31,
      heightCm: 178,
    );

    expect(result.success, isTrue);
    expect(authStore.currentUser?.name, 'Daniel Gomez');
    expect(authStore.currentUser?.age, 31);
    expect(authStore.currentUser?.heightCm, 178);
  });

  testWidgets('Tocar el nombre abre configuracion y permite guardar', (
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

    await tester.tap(find.byTooltip('Configuracion de usuario'));
    await tester.pumpAndSettle();

    expect(find.text('Configuracion de usuario'), findsOneWidget);
    expect(find.text('Datos personales'), findsOneWidget);
    expect(find.text('Cuerpo y objetivo'), findsOneWidget);
    expect(find.text('Estatura (cm)'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Daniel Gomez');
    await tester.enterText(find.byType(TextFormField).at(2), '31');
    await tester.enterText(find.byType(TextFormField).at(3), '178');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Configuracion de usuario'), findsNothing);
    expect(find.text('Daniel'), findsOneWidget);
  });
}
