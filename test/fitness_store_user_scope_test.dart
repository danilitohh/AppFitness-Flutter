import 'dart:convert';

import 'package:appfitness/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FitnessStore separa los datos por usuario', () async {
    SharedPreferences.setMockInitialValues({
      'fitness_workouts_user_user1': jsonEncode([
        {
          'id': 'w1',
          'name': 'Full Body',
          'category': 'Fuerza',
          'durationMinutes': 45,
          'caloriesBurned': 320,
          'date': DateTime(2026, 3, 27).toIso8601String(),
          'intensity': 'high',
          'completed': true,
        },
      ]),
      'fitness_onboarding_completed_user_user1': true,
    });

    final store = FitnessStore();
    await store.initialize();

    await store.loadForUser('user1', allowLegacyMigration: false);
    expect(store.workouts, hasLength(1));
    expect(store.needsOnboarding, isFalse);

    await store.loadForUser('user2', allowLegacyMigration: false);
    expect(store.workouts, isEmpty);
    expect(store.meals, isEmpty);
    expect(store.weights, isEmpty);
    expect(store.needsOnboarding, isTrue);
  });
}
