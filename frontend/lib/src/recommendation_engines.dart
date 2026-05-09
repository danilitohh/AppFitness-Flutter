part of '../main.dart';

// -----------------------------------------------------------------------------
// Motores de recomendacion.
// Generadores puros de planes sugeridos para entreno y alimentacion.
// -----------------------------------------------------------------------------
class _WorkoutPlanSuggestion {
  const _WorkoutPlanSuggestion({
    required this.template,
    required this.frequencyLabel,
    required this.cadenceLabel,
    required this.executionHint,
    required this.exerciseNames,
  });

  final WorkoutTemplate template;
  final String frequencyLabel;
  final String cadenceLabel;
  final String executionHint;
  final List<String> exerciseNames;
}

class _MealPlanSuggestion {
  const _MealPlanSuggestion({
    required this.slotLabel,
    required this.icon,
    required this.title,
    required this.frequencyLabel,
    required this.timingLabel,
    required this.ingredients,
    required this.portionSummary,
  });

  final String slotLabel;
  final IconData icon;
  final String title;
  final String frequencyLabel;
  final String timingLabel;
  final List<_MealIngredientLine> ingredients;
  final String portionSummary;
}

class _MealIngredientLine {
  const _MealIngredientLine({required this.amount, required this.name});

  final String amount;
  final String name;
}

class _MealSlotDefinition {
  const _MealSlotDefinition({
    required this.slotLabel,
    required this.icon,
    required this.timingLabel,
    required this.isMainMeal,
    required this.isSnack,
  });

  final String slotLabel;
  final IconData icon;
  final String timingLabel;
  final bool isMainMeal;
  final bool isSnack;
}

class _NutritionContextFlags {
  const _NutritionContextFlags({
    required this.isLactoseFree,
    required this.isGlutenFree,
    required this.isVegan,
    required this.isVegetarian,
    required this.avoidsNuts,
  });

  final bool isLactoseFree;
  final bool isGlutenFree;
  final bool isVegan;
  final bool isVegetarian;
  final bool avoidsNuts;
}

int _proteinTargetForGoal(FitnessGoalType goal, double weightKg) {
  final factor = switch (goal) {
    FitnessGoalType.gainMuscle => 1.8,
    FitnessGoalType.loseFat => 1.6,
    FitnessGoalType.performance => 1.6,
    FitnessGoalType.maintain => 1.2,
  };
  return (weightKg * factor).round();
}

WorkoutTemplate _workoutTemplateById(String id) {
  return _workoutTemplates.firstWhere(
    (template) => template.id == id,
    orElse: () => _workoutTemplates.first,
  );
}

List<_WorkoutPlanSuggestion> _buildWorkoutPlanSuggestions({
  required CoachProfile profile,
}) {
  final resolvedIds = _weeklyWorkoutPlanIds(
    profile,
  ).map((id) => _normalizeWorkoutTemplateIdForProfile(id, profile)).toList();
  final orderedIds = <String>[];
  final counts = <String, int>{};

  for (final id in resolvedIds) {
    if (!counts.containsKey(id)) {
      orderedIds.add(id);
    }
    counts[id] = (counts[id] ?? 0) + 1;
  }

  return orderedIds.map((id) {
    final template = _workoutTemplateById(id);
    final frequency = counts[id] ?? 1;
    return _WorkoutPlanSuggestion(
      template: template,
      frequencyLabel: _workoutFrequencyLabel(frequency),
      cadenceLabel: _workoutCadenceLabel(frequency),
      executionHint: _workoutExecutionHint(template, profile),
      exerciseNames: template.exampleExercises.take(4).toList(),
    );
  }).toList();
}

List<String> _weeklyWorkoutPlanIds(CoachProfile profile) {
  final days = _clampInt(profile.daysPerWeek, 1, 7);

  switch (profile.goal) {
    case FitnessGoalType.gainMuscle:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['upper-body-strength', 'lower-body-core'];
      }
      if (days == 3) {
        return ['upper-body-strength', 'lower-body-core', 'full-body-strength'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'upper-body-strength',
          'lower-body-core',
        ];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'full-body-strength',
        'upper-body-strength',
        'lower-body-core',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.loseFat:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['full-body-strength', 'zone-2-cardio', 'hiit-conditioning'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'zone-2-cardio',
          'hiit-conditioning',
        ];
      }
      return [
        'full-body-strength',
        'upper-body-strength',
        'lower-body-core',
        'zone-2-cardio',
        'hiit-conditioning',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.performance:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['upper-body-strength', 'lower-body-core', 'zone-2-cardio'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'zone-2-cardio',
          'hiit-conditioning',
        ];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'full-body-strength',
        'zone-2-cardio',
        'hiit-conditioning',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.maintain:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['full-body-strength', 'zone-2-cardio', 'mobility-recovery'];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'zone-2-cardio',
        'mobility-recovery',
        'full-body-strength',
      ].take(days).toList();
  }
}

String _normalizeWorkoutTemplateIdForProfile(
  String templateId,
  CoachProfile profile,
) {
  if (profile.equipment == EquipmentAccess.home &&
      (templateId == 'upper-body-strength' ||
          templateId == 'lower-body-core')) {
    return 'full-body-strength';
  }
  return templateId;
}

String _workoutFrequencyLabel(int timesPerWeek) {
  if (timesPerWeek <= 1) {
    return '1 vez por semana';
  }
  return '$timesPerWeek veces por semana';
}

String _workoutCadenceLabel(int timesPerWeek) {
  if (timesPerWeek <= 1) {
    return 'repite cada 7 dias';
  }
  if (timesPerWeek == 2) {
    return 'repite cada 3-4 dias';
  }
  if (timesPerWeek == 3) {
    return 'trabajalo en dias alternos';
  }
  return 'distribuyelo a lo largo de la semana';
}

String _workoutExecutionHint(WorkoutTemplate template, CoachProfile profile) {
  if (template.category == 'Cardio') {
    final duration =
        template.defaultDurationMinutes +
        (profile.goal == FitnessGoalType.performance ? 5 : 0);
    final cardioMode = template.id == 'hiit-conditioning'
        ? 'Haz 6-10 bloques de 20-40 s con pausas cortas.'
        : 'Mantente a un ritmo continuo donde aun puedas hablar en frases cortas.';
    return '${template.exampleExercises.take(3).join(', ')}. Trabaja $duration min. $cardioMode';
  }

  if (template.category == 'Movilidad') {
    final rounds = profile.experience == TrainingExperience.beginner ? 2 : 3;
    return '${template.exampleExercises.take(3).join(', ')}. Haz $rounds rondas de 30-45 s por lado y usa esta sesion para recuperar.';
  }

  final series = switch (profile.experience) {
    TrainingExperience.beginner => 2,
    TrainingExperience.intermediate => 3,
    TrainingExperience.advanced => 4,
  };
  final repRange = switch (profile.goal) {
    FitnessGoalType.gainMuscle => '8-12 repeticiones',
    FitnessGoalType.loseFat => '10-15 repeticiones',
    FitnessGoalType.performance => '6-10 repeticiones',
    FitnessGoalType.maintain => '8-12 repeticiones',
  };
  return '${template.exampleExercises.take(3).join(', ')}. Haz $series series por ejercicio con $repRange.';
}

List<_MealPlanSuggestion> _buildMealPlanSuggestions({
  required CoachProfile profile,
  required FitnessGoals goals,
  required double referenceWeight,
}) {
  final flags = _nutritionFlagsFromProfile(profile);
  final proteinTarget = _proteinTargetForGoal(profile.goal, referenceWeight);
  final proteinPerMeal = math.max(
    20,
    (proteinTarget / profile.mealsPerDay).round(),
  );
  final cadenceLabel = _mealCadenceLabel(profile.mealsPerDay);

  return _mealSlotsForProfile(profile).map((slot) {
    return _buildMealPlanSuggestionForSlot(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }).toList();
}

_NutritionContextFlags _nutritionFlagsFromProfile(CoachProfile profile) {
  final normalized = '${profile.allergies}; ${profile.notes}'.toLowerCase();
  final isVegan =
      normalized.contains('vegano') || normalized.contains('vegana');
  final isVegetarian = isVegan || normalized.contains('vegetar');

  return _NutritionContextFlags(
    isLactoseFree:
        normalized.contains('sin lactosa') || normalized.contains('lactosa'),
    isGlutenFree:
        normalized.contains('sin gluten') || normalized.contains('celia'),
    isVegan: isVegan,
    isVegetarian: isVegetarian,
    avoidsNuts:
        normalized.contains('frutos secos') ||
        normalized.contains('mani') ||
        normalized.contains('nuez'),
  );
}

List<_MealSlotDefinition> _mealSlotsForProfile(CoachProfile profile) {
  final mainMealTiming = profile.mealWindow.label;

  switch (profile.mealsPerDay) {
    case 2:
      return [
        _MealSlotDefinition(
          slotLabel: 'Comida 1',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Comida principal',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
      ];
    case 3:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '3-4 horas despues de la comida principal',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    case 4:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion',
          icon: Icons.apple,
          timingLabel: 'entre comidas',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '3-4 horas despues del almuerzo',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    case 5:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion AM',
          icon: Icons.apple,
          timingLabel: 'media manana',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion PM',
          icon: Icons.cookie_outlined,
          timingLabel: 'media tarde',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '2-3 horas despues de la colacion',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    default:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion AM',
          icon: Icons.apple,
          timingLabel: 'media manana',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion PM',
          icon: Icons.cookie_outlined,
          timingLabel: 'media tarde',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: 'noche',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Snack ligero',
          icon: Icons.local_drink_outlined,
          timingLabel: 'si aun te faltan calorias',
          isMainMeal: false,
          isSnack: true,
        ),
      ];
  }
}

String _mealCadenceLabel(int mealsPerDay) {
  if (mealsPerDay <= 2) {
    return 'cada 5-6 horas';
  }
  if (mealsPerDay == 3) {
    return 'cada 4-5 horas';
  }
  if (mealsPerDay == 4) {
    return 'cada 3-4 horas';
  }
  return 'cada 2-3 horas';
}

String _mealPortionSummary({
  required _MealSlotDefinition slot,
  required int proteinPerMeal,
}) {
  if (slot.isSnack) {
    return 'Usa esta colacion para completar energia y acercarte a ~$proteinPerMeal g de proteina diarios por toma.';
  }
  if (slot.isMainMeal) {
    return 'Haz de esta tu comida mas completa del dia y apunta a ~$proteinPerMeal g de proteina.';
  }
  return 'Porcion sugerida para acercarte a ~$proteinPerMeal g de proteina en esta comida.';
}

_MealPlanSuggestion _buildMealPlanSuggestionForSlot({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  if (slot.isSnack) {
    return _buildSnackMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  if (slot.isMainMeal) {
    return _buildMainMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  if (slot.slotLabel.toLowerCase().contains('cena')) {
    return _buildDinnerMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  return _buildBreakfastMealSuggestion(
    profile: profile,
    slot: slot,
    cadenceLabel: cadenceLabel,
    proteinPerMeal: proteinPerMeal,
    flags: flags,
  );
}

_MealPlanSuggestion _buildBreakfastMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu revuelto con avena y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Huevos con avena y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('2 unidades', 'huevos'),
            _ingredient('200 g', 'claras'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido con bebida vegetal y avena',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina en polvo'),
            _ingredient('300 ml', 'bebida vegetal'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Omelette proteico con avena',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('2 unidades', 'huevos'),
          _ingredient('200 g', 'claras'),
          _ingredient('50 g', 'avena'),
          _ingredient('1 porcion', 'fruta'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con aguacate y verduras'
            : 'Huevos con aguacate y vegetales',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'tofu'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('1-2 tazas', 'verduras salteadas'),
              ]
            : [
                _ingredient('2-3 unidades', 'huevos'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('1-2 tazas', 'vegetales'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Avena con chia y bebida vegetal'
            : flags.isLactoseFree
            ? 'Huevos con fruta y avena'
            : 'Yogur con avena y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('60 g', 'avena'),
                _ingredient('250 ml', 'bebida vegetal'),
                _ingredient('15 g', 'chia'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : flags.isLactoseFree
            ? [
                _ingredient('2 unidades', 'huevos'),
                _ingredient('50 g', 'avena'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : [
                _ingredient('200 g', 'yogur'),
                _ingredient('50 g', 'avena'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Avena con bebida vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('60 g', 'avena'),
            _ingredient('250 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('10 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Avena con bebida vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('60 g', 'avena'),
            _ingredient('250 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('15 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Avena con yogur y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.avoidsNuts
            ? [
                _ingredient('60 g', 'avena'),
                _ingredient('200 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
                _ingredient('15 g', 'semillas'),
              ]
            : [
                _ingredient('60 g', 'avena'),
                _ingredient('200 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
                _ingredient('15 g', 'frutos secos'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildMainMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tempeh con arroz y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180-220 g', 'tempeh'),
            _ingredient('130 g', 'arroz cocido'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Huevos o tofu con arroz y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('3 unidades o 180 g', 'huevos o tofu'),
            _ingredient('130 g', 'arroz cocido'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pollo con arroz y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('170-200 g', 'pollo'),
          _ingredient('130 g', 'arroz cocido'),
          _ingredient('1-2 tazas', 'verduras'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con ensalada grande y aguacate'
            : 'Ensalada grande con pollo y aguacate',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180-220 g', 'tofu'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('2 tazas', 'verduras libres'),
              ]
            : [
                _ingredient('160-180 g', 'pollo o atun'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('2 tazas', 'verduras libres'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Lentejas con quinoa y verduras'
            : 'Lentejas o tofu con quinoa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 taza', 'lentejas'),
                _ingredient('120 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ]
            : [
                _ingredient('1 taza o 180 g', 'lentejas o tofu'),
                _ingredient('120 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu con arroz y ensalada',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('140 g', 'arroz cocido'),
            _ingredient('1 plato', 'ensalada'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Lentejas con arroz y ensalada',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 taza', 'lentejas'),
            _ingredient('120-140 g', 'arroz cocido'),
            _ingredient('1 plato', 'ensalada'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pollo con arroz y ensalada',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('160-180 g', 'pollo'),
          _ingredient('140 g', 'arroz cocido'),
          _ingredient('1 plato', 'ensalada'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildDinnerMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu con papa y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('180 g', 'papa cocida'),
            _ingredient('1-2 tazas', 'verduras al vapor'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pavo o atun con papa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('160-180 g', 'pavo o atun'),
          _ingredient('180 g', 'papa'),
          _ingredient('1-2 tazas', 'verduras cocidas'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con verduras salteadas'
            : 'Pescado o huevos con verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'tofu'),
                _ingredient('2 tazas', 'verduras'),
                _ingredient('1 cda', 'aceite de oliva'),
              ]
            : [
                _ingredient('160 g o 3 unidades', 'pescado o huevos'),
                _ingredient('2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Garbanzos con quinoa y verduras'
            : 'Tortilla o tofu con verduras y quinoa',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 taza', 'garbanzos'),
                _ingredient('100 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ]
            : [
                _ingredient('2 huevos + 150 g claras o 180 g', 'tofu'),
                _ingredient('100 g', 'quinoa'),
                _ingredient('1-2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Garbanzos con verduras y quinoa',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 taza', 'garbanzos'),
            _ingredient('100 g', 'quinoa cocida'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Huevos o pescado con papa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('2-3 huevos o 160 g', 'pescado'),
          _ingredient('160 g', 'papa'),
          _ingredient('1-2 tazas', 'verduras'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildSnackMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('10 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido sin lactosa y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina en polvo'),
            _ingredient('300 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Yogur alto en proteina y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('200 g', 'yogur alto en proteina'),
          _ingredient('1 porcion', 'fruta'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Hummus con pepino'
            : 'Rollitos de pavo con pepino',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('80 g', 'hummus'),
                _ingredient('1 porcion', 'pepino o zanahoria'),
              ]
            : [
                _ingredient('80-100 g', 'pavo'),
                _ingredient('1 porcion', 'pepino o zanahoria'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Yogur vegetal con semillas'
            : 'Yogur o queso cottage con fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'yogur vegetal'),
                _ingredient('10-15 g', 'semillas'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : [
                _ingredient('180 g', 'yogur o queso cottage'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Fruta con bebida vegetal'
            : flags.isLactoseFree
            ? 'Fruta con bebida vegetal y semillas'
            : 'Yogur con fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 porcion', 'fruta'),
                _ingredient('250 ml', 'bebida vegetal'),
              ]
            : flags.isLactoseFree
            ? [
                _ingredient('1 porcion', 'fruta'),
                _ingredient('250 ml', 'bebida vegetal'),
                _ingredient('10 g', 'semillas'),
              ]
            : [
                _ingredient('180 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

String _joinNaturalList(Iterable<String> items) {
  final values = items.where((item) => item.trim().isNotEmpty).toList();
  if (values.isEmpty) {
    return '';
  }
  if (values.length == 1) {
    return values.first;
  }
  if (values.length == 2) {
    return '${values.first} y ${values.last}';
  }
  return '${values.sublist(0, values.length - 1).join(', ')} y ${values.last}';
}

_MealIngredientLine _ingredient(String amount, String name) {
  return _MealIngredientLine(amount: amount, name: name);
}

String _workoutExercisePreview(WorkoutTemplate template, {int limit = 3}) {
  return _joinNaturalList(template.exampleExercises.take(limit));
}

bool get _showLegacyOnboardingRecommendations => false;

List<String> _buildOnboardingRecommendations({
  required CoachProfile profile,
  required FitnessGoals goals,
  double? currentWeightKg,
  double? targetWeightKg,
}) {
  final referenceWeight =
      currentWeightKg ?? targetWeightKg ?? goals.targetWeightKg;
  final workoutPlan = _buildWorkoutPlanSuggestions(profile: profile);
  final mealPlan = _buildMealPlanSuggestions(
    profile: profile,
    goals: goals,
    referenceWeight: referenceWeight,
  );
  final focus = switch (profile.goal) {
    FitnessGoalType.loseFat => 'deficit moderado y constancia',
    FitnessGoalType.gainMuscle => 'progresion de fuerza y proteina alta',
    FitnessGoalType.performance => 'cardio progresivo y recuperacion',
    FitnessGoalType.maintain => 'equilibrio y habitos sostenibles',
  };

  final trainingPlace = switch (profile.equipment) {
    EquipmentAccess.home => 'casa',
    EquipmentAccess.gym => 'gimnasio',
    EquipmentAccess.mixed => 'casa y gimnasio',
  };
  final workoutHistory = switch (profile.trainingHistory) {
    TrainingHistory.none => 'sin historial reciente de entrenamiento',
    TrainingHistory.onceWeekly => 'con una base ligera de entrenamiento',
    TrainingHistory.twoToThreeWeekly => 'con una base intermedia reciente',
    TrainingHistory.fourPlusWeekly =>
      'con una base consistente de entrenamiento',
  };
  final contextNotes = [
    profile.allergies.trim(),
    profile.notes.trim(),
  ].where((item) => item.isNotEmpty).join('; ');

  final weightLine = currentWeightKg != null && targetWeightKg != null
      ? 'Tu referencia inicial va de ${currentWeightKg.toStringAsFixed(1)} kg a ${targetWeightKg.toStringAsFixed(1)} kg.'
      : currentWeightKg != null
      ? 'Tu peso base sera ${currentWeightKg.toStringAsFixed(1)} kg y lo iremos afinando con tus registros.'
      : 'Registra tu primer peso esta semana para que las recomendaciones sean cada vez mas precisas.';

  final workoutLine =
      'Rutinas sugeridas: ${workoutPlan.take(2).map((item) => '${item.template.title} (${item.frequencyLabel})').join(' y ')}. Empieza con ${_workoutExercisePreview(workoutPlan.first.template)} y manten el foco en $focus.';

  final mealLine = mealPlan.isEmpty
      ? 'Empezaremos con ${profile.mealsPerDay} comidas al dia, estilo ${profile.dietStyle.label.toLowerCase()}, comida principal ${profile.mealWindow.label.toLowerCase()} y una meta de ${goals.calorieGoal} kcal.'
      : 'Comidas sugeridas: ${mealPlan.take(2).map((item) => '${item.slotLabel}: ${item.title}').join(' | ')}. Repite ${mealPlan.first.frequencyLabel} y sigue las porciones indicadas.';

  return [
    workoutLine,
    'El punto de partida quedara ajustado $workoutHistory, con preferencia horaria ${profile.workoutWindow.label.toLowerCase()}.',
    mealLine,
    'Tus sugerencias se adaptaran para entrenar en $trainingPlace y con una meta de hidratacion de ${goals.waterGoalMl} ml.',
    if (contextNotes.isNotEmpty)
      'Tendremos en cuenta estas consideraciones desde el inicio: ${_summarizeCoachNote(contextNotes)}.',
    weightLine,
    if (_showLegacyOnboardingRecommendations) ...[
      'Te recomendaré ${profile.daysPerWeek} días de entreno por semana, sesiones de ${goals.workoutGoalMinutes} minutos y foco en $focus.',
      'El punto de partida quedará ajustado $workoutHistory, con preferencia horaria ${profile.workoutWindow.label.toLowerCase()}.',
      'Empezaremos con ${profile.mealsPerDay} comidas al día, estilo ${profile.dietStyle.label.toLowerCase()}, comida principal ${profile.mealWindow.label.toLowerCase()} y una meta de ${goals.calorieGoal} kcal.',
      'Tus sugerencias se adaptarán para entrenar en $trainingPlace y con una meta de hidratación de ${goals.waterGoalMl} ml.',
      if (contextNotes.isNotEmpty)
        'Tendremos en cuenta estas consideraciones desde el inicio: ${_summarizeCoachNote(contextNotes)}.',
      weightLine,
    ],
  ];
}
