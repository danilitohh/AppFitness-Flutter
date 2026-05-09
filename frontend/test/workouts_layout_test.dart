import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WorkoutsScreen no desborda en pantallas compactas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = FitnessStore();
    await store.initialize();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: WorkoutsScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resumen semanal'), findsOneWidget);
    expect(find.text('Plan de hoy'), findsOneWidget);
    expect(find.text('Coach IA de entreno'), findsOneWidget);
    expect(find.text('Rutinas sugeridas para tu objetivo'), findsOneWidget);
    expect(find.text('Fuerza total del cuerpo'), findsOneWidget);
    expect(find.text('Cardio zona 2'), findsOneWidget);
    expect(find.text('Movilidad y recuperacion'), findsOneWidget);
    expect(find.text('Ejercicios recomendados'), findsWidgets);
    expect(find.text('Sentadilla goblet'), findsOneWidget);
    expect(find.text('Press de pecho'), findsOneWidget);
    expect(find.text('Remo con mancuerna'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('WorkoutCatalogScreen muestra plantillas sin desbordes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = FitnessStore();
    await store.initialize();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: WorkoutCatalogScreen(store: store)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Biblioteca de entrenamientos'), findsOneWidget);
    expect(find.text('Fuerza total del cuerpo'), findsOneWidget);
    expect(find.text('Ver detalle'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, -1400),
      2000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Detalle de entrenamiento permite registrar sin cerrar la app', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = FitnessStore();
    await store.initialize();

    const template = WorkoutTemplate(
      id: 'test-strength',
      title: 'Fuerza de prueba',
      category: 'Fuerza',
      description: 'Descripcion',
      purpose: 'Proposito',
      howToSteps: ['Paso 1'],
      exampleExercises: ['Sentadilla'],
      targetZones: ['Piernas'],
      icon: Icons.fitness_center,
      accent: Color(0xFF0F766E),
      defaultDurationMinutes: 45,
      defaultCalories: 280,
      intensity: WorkoutIntensity.medium,
      demoExercise: 'Sentadilla goblet',
      demoFocus: 'Patron principal',
      demoCues: ['Pecho alto'],
      demoPhases: [
        WorkoutDemoPhase(
          label: 'Inicio',
          instruction: 'Base',
          progress: 0,
          icon: Icons.play_arrow_rounded,
        ),
      ],
      videoTitle: 'Video',
      videoSearchQuery: 'sentadilla tecnica',
      videoSummary: 'Resumen',
      youtubeVideoId: 'abc123xyz00',
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutTemplateDetailScreen(store: store, template: template),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final registerButton = find.widgetWithText(
      FilledButton,
      'Registrar este entrenamiento',
    );
    await tester.ensureVisible(registerButton);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(registerButton);
    await tester.pump();
    await tester.pump(
      kThemeAnimationDuration + const Duration(milliseconds: 80),
    );

    expect(find.text('Nuevo entrenamiento'), findsOneWidget);

    await tester.tap(find.text('Guardar entrenamiento'));
    await tester.pump();
    await tester.pump(
      kThemeAnimationDuration + const Duration(milliseconds: 80),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(store.workouts, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
