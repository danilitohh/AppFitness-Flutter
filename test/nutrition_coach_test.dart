import 'package:appfitness/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder richTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(text),
    );
  }

  Future<FitnessStore> buildStore() async {
    SharedPreferences.setMockInitialValues({});
    final store = FitnessStore();
    await store.initialize();
    store.addMeal(
      type: MealType.breakfast,
      name: 'Avena con fruta',
      calories: 420,
      protein: 18,
      carbs: 62,
      fats: 11,
      date: DateTime.now(),
    );
    store.addMeal(
      type: MealType.lunch,
      name: 'Pollo con arroz',
      calories: 650,
      protein: 44,
      carbs: 68,
      fats: 19,
      date: DateTime.now(),
    );
    store.addWeight(73.7, date: DateTime.now());
    return store;
  }

  testWidgets('Coach de nutricion muestra recomendaciones con datos reales', (
    WidgetTester tester,
  ) async {
    final store = await buildStore();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NutritionScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coach IA de nutricion'), findsOneWidget);
    expect(
      find.text('Te faltan ~1130 kcal para tu meta diaria.'),
      findsOneWidget,
    );
    expect(find.text('Comidas sugeridas para tu objetivo'), findsOneWidget);
    expect(find.text('Desayuno'), findsOneWidget);
    expect(find.text('Avena con yogur y fruta'), findsOneWidget);
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Pollo con arroz y ensalada'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('Huevos o pescado con papa y verduras'), findsOneWidget);
    expect(find.text('Ingredientes y cantidades'), findsWidgets);
    expect(richTextContaining('60 g avena'), findsOneWidget);
    expect(richTextContaining('200 g yogur'), findsOneWidget);
    expect(richTextContaining('160-180 g pollo'), findsOneWidget);
    expect(
      find.text('Completa con una comida ligera rica en proteina.'),
      findsOneWidget,
    );
    expect(find.text('Aumenta ~26 g de proteina hoy.'), findsOneWidget);
    expect(find.text('Meta: ~29 g de proteina por comida.'), findsOneWidget);
  });

  testWidgets('Coach de nutricion aplica perfil y restricciones guardadas', (
    WidgetTester tester,
  ) async {
    final store = await buildStore();
    store.updateCoachProfile(
      const CoachProfile(
        goal: FitnessGoalType.gainMuscle,
        dietStyle: DietStyle.highProtein,
        mealsPerDay: 4,
        notes: 'sin lactosa',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NutritionScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hipertrofia muscular'), findsOneWidget);
    expect(find.text('Alta proteína'), findsOneWidget);
    expect(find.text('4 comidas/dia'), findsOneWidget);
    expect(
      find.text('Ajuste activo: usa opciones sin lactosa o bebidas vegetales.'),
      findsOneWidget,
    );
    expect(find.text('Comidas sugeridas para tu objetivo'), findsOneWidget);
    expect(find.text('Batido con bebida vegetal y avena'), findsOneWidget);
    expect(find.text('Pollo con arroz y verduras'), findsOneWidget);
    expect(find.text('Batido sin lactosa y fruta'), findsOneWidget);
    expect(richTextContaining('1 scoop proteina en polvo'), findsNWidgets(2));
    expect(richTextContaining('300 ml bebida vegetal'), findsNWidgets(2));
    expect(find.text('Aumenta ~71 g de proteina hoy.'), findsOneWidget);
    expect(find.text('Meta: ~33 g de proteina por comida.'), findsOneWidget);
  });
}
