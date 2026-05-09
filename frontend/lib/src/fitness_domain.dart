part of '../main.dart';

// -----------------------------------------------------------------------------
// Dominio fitness principal.
// Enumeraciones, perfiles, registros y metas usados por la logica de negocio.
// -----------------------------------------------------------------------------
/// Nivel de intensidad para un entrenamiento.
enum WorkoutIntensity { low, medium, high }

extension WorkoutIntensityX on WorkoutIntensity {
  String get label {
    switch (this) {
      case WorkoutIntensity.low:
        return 'Ligera';
      case WorkoutIntensity.medium:
        return 'Moderada';
      case WorkoutIntensity.high:
        return 'Alta exigencia';
    }
  }

  static WorkoutIntensity fromName(String value) {
    return WorkoutIntensity.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WorkoutIntensity.medium,
    );
  }
}

/// Tipo de comida registrada por el usuario.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Colación';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.restaurant;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  static MealType fromName(String value) {
    return MealType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MealType.lunch,
    );
  }
}

/// Objetivo principal del usuario para recomendaciones inteligentes.
enum FitnessGoalType { loseFat, gainMuscle, maintain, performance }

extension FitnessGoalTypeX on FitnessGoalType {
  String get label {
    switch (this) {
      case FitnessGoalType.loseFat:
        return 'Reducción de grasa';
      case FitnessGoalType.gainMuscle:
        return 'Hipertrofia muscular';
      case FitnessGoalType.maintain:
        return 'Mantenimiento';
      case FitnessGoalType.performance:
        return 'Rendimiento deportivo';
    }
  }

  static FitnessGoalType fromName(String value) {
    return FitnessGoalType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => FitnessGoalType.maintain,
    );
  }
}

/// Nivel de experiencia declarado para ajustar volumen.
enum TrainingExperience { beginner, intermediate, advanced }

extension TrainingExperienceX on TrainingExperience {
  String get label {
    switch (this) {
      case TrainingExperience.beginner:
        return 'Inicial';
      case TrainingExperience.intermediate:
        return 'Intermedio';
      case TrainingExperience.advanced:
        return 'Avanzado';
    }
  }

  static TrainingExperience fromName(String value) {
    return TrainingExperience.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TrainingExperience.beginner,
    );
  }
}

/// Acceso a equipo para definir ejercicios sugeridos.
enum EquipmentAccess { gym, home, mixed }

extension EquipmentAccessX on EquipmentAccess {
  String get label {
    switch (this) {
      case EquipmentAccess.gym:
        return 'Gimnasio';
      case EquipmentAccess.home:
        return 'Casa con equipo básico';
      case EquipmentAccess.mixed:
        return 'Mixto';
    }
  }

  static EquipmentAccess fromName(String value) {
    return EquipmentAccess.values.firstWhere(
      (item) => item.name == value,
      orElse: () => EquipmentAccess.mixed,
    );
  }
}

/// Estilo de alimentacion preferido.
enum DietStyle { balanced, highProtein, lowCarb, vegetarian }

extension DietStyleX on DietStyle {
  String get label {
    switch (this) {
      case DietStyle.balanced:
        return 'Plan equilibrado';
      case DietStyle.highProtein:
        return 'Alta proteína';
      case DietStyle.lowCarb:
        return 'Control de carbohidratos';
      case DietStyle.vegetarian:
        return 'Vegetariano';
    }
  }

  static DietStyle fromName(String value) {
    return DietStyle.values.firstWhere(
      (item) => item.name == value,
      orElse: () => DietStyle.balanced,
    );
  }
}

/// Historial reciente de entrenamiento para ajustar carga y punto de partida.
enum TrainingHistory { none, onceWeekly, twoToThreeWeekly, fourPlusWeekly }

extension TrainingHistoryX on TrainingHistory {
  String get label {
    switch (this) {
      case TrainingHistory.none:
        return 'No entrené';
      case TrainingHistory.onceWeekly:
        return 'Entrené 1 vez por semana';
      case TrainingHistory.twoToThreeWeekly:
        return 'Entrené de 2 a 3 veces por semana';
      case TrainingHistory.fourPlusWeekly:
        return 'Entrené 4 o más veces por semana';
    }
  }

  static TrainingHistory fromName(String value) {
    return TrainingHistory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TrainingHistory.none,
    );
  }
}

/// Franja horaria usada para planificar entrenos y comidas.
enum RoutineTimeWindow {
  before8,
  between8And11,
  between11And14,
  between14And17,
  between17And19,
  between19And21,
  after21,
}

extension RoutineTimeWindowX on RoutineTimeWindow {
  String get label {
    switch (this) {
      case RoutineTimeWindow.before8:
        return 'Antes de las 8:00';
      case RoutineTimeWindow.between8And11:
        return 'Entre 8:00 y 11:00';
      case RoutineTimeWindow.between11And14:
        return 'Entre 11:00 y 14:00';
      case RoutineTimeWindow.between14And17:
        return 'Entre 14:00 y 17:00';
      case RoutineTimeWindow.between17And19:
        return 'Entre 17:00 y 19:00';
      case RoutineTimeWindow.between19And21:
        return 'Entre 19:00 y 21:00';
      case RoutineTimeWindow.after21:
        return 'Después de las 21:00';
    }
  }

  static RoutineTimeWindow fromName(String value) {
    return RoutineTimeWindow.values.firstWhere(
      (item) => item.name == value,
      orElse: () => RoutineTimeWindow.between17And19,
    );
  }
}

/// Preferencias del usuario para personalizar sugerencias IA.
class CoachProfile {
  const CoachProfile({
    this.goal = FitnessGoalType.maintain,
    this.experience = TrainingExperience.beginner,
    this.trainingHistory = TrainingHistory.none,
    this.daysPerWeek = 3,
    this.equipment = EquipmentAccess.mixed,
    this.workoutWindow = RoutineTimeWindow.between17And19,
    this.dietStyle = DietStyle.balanced,
    this.mealsPerDay = 3,
    this.mealWindow = RoutineTimeWindow.between11And14,
    this.allergies = '',
    this.notes = '',
  });

  final FitnessGoalType goal;
  final TrainingExperience experience;
  final TrainingHistory trainingHistory;
  final int daysPerWeek;
  final EquipmentAccess equipment;
  final RoutineTimeWindow workoutWindow;
  final DietStyle dietStyle;
  final int mealsPerDay;
  final RoutineTimeWindow mealWindow;
  final String allergies;
  final String notes;

  bool get isDefault {
    return goal == FitnessGoalType.maintain &&
        experience == TrainingExperience.beginner &&
        trainingHistory == TrainingHistory.none &&
        daysPerWeek == 3 &&
        equipment == EquipmentAccess.mixed &&
        workoutWindow == RoutineTimeWindow.between17And19 &&
        dietStyle == DietStyle.balanced &&
        mealsPerDay == 3 &&
        mealWindow == RoutineTimeWindow.between11And14 &&
        allergies.trim().isEmpty &&
        notes.trim().isEmpty;
  }

  CoachProfile copyWith({
    FitnessGoalType? goal,
    TrainingExperience? experience,
    TrainingHistory? trainingHistory,
    int? daysPerWeek,
    EquipmentAccess? equipment,
    RoutineTimeWindow? workoutWindow,
    DietStyle? dietStyle,
    int? mealsPerDay,
    RoutineTimeWindow? mealWindow,
    String? allergies,
    String? notes,
  }) {
    return CoachProfile(
      goal: goal ?? this.goal,
      experience: experience ?? this.experience,
      trainingHistory: trainingHistory ?? this.trainingHistory,
      daysPerWeek: _clampInt(daysPerWeek ?? this.daysPerWeek, 1, 7),
      equipment: equipment ?? this.equipment,
      workoutWindow: workoutWindow ?? this.workoutWindow,
      dietStyle: dietStyle ?? this.dietStyle,
      mealsPerDay: _clampInt(mealsPerDay ?? this.mealsPerDay, 2, 6),
      mealWindow: mealWindow ?? this.mealWindow,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal.name,
      'experience': experience.name,
      'trainingHistory': trainingHistory.name,
      'daysPerWeek': daysPerWeek,
      'equipment': equipment.name,
      'workoutWindow': workoutWindow.name,
      'dietStyle': dietStyle.name,
      'mealsPerDay': mealsPerDay,
      'mealWindow': mealWindow.name,
      'allergies': allergies,
      'notes': notes,
    };
  }

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      goal: FitnessGoalTypeX.fromName(json['goal']?.toString() ?? ''),
      experience: TrainingExperienceX.fromName(
        json['experience']?.toString() ?? '',
      ),
      trainingHistory: TrainingHistoryX.fromName(
        json['trainingHistory']?.toString() ?? '',
      ),
      daysPerWeek: _clampInt(_toInt(json['daysPerWeek'], fallback: 3), 1, 7),
      equipment: EquipmentAccessX.fromName(json['equipment']?.toString() ?? ''),
      workoutWindow: RoutineTimeWindowX.fromName(
        json['workoutWindow']?.toString() ?? '',
      ),
      dietStyle: DietStyleX.fromName(json['dietStyle']?.toString() ?? ''),
      mealsPerDay: _clampInt(_toInt(json['mealsPerDay'], fallback: 3), 2, 6),
      mealWindow: RoutineTimeWindowX.fromName(
        json['mealWindow']?.toString() ?? '',
      ),
      allergies: json['allergies']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}

/// Registro de una sesion de entrenamiento.
class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
    required this.intensity,
    required this.completed,
  });

  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;
  final WorkoutIntensity intensity;
  final bool completed;

  WorkoutEntry copyWith({bool? completed}) {
    return WorkoutEntry(
      id: id,
      name: name,
      category: category,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      date: date,
      intensity: intensity,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'intensity': intensity.name,
      'completed': completed,
    };
  }

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      id: json['id']?.toString() ?? _newId(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      durationMinutes: _toInt(json['durationMinutes']),
      caloriesBurned: _toInt(json['caloriesBurned']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      intensity: WorkoutIntensityX.fromName(
        json['intensity']?.toString() ?? '',
      ),
      completed: json['completed'] == true,
    );
  }
}

/// Registro de una comida con macros y calorias.
class MealEntry {
  const MealEntry({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  final String id;
  final MealType type;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'date': date.toIso8601String(),
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id']?.toString() ?? _newId(),
      type: MealTypeX.fromName(json['type']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      calories: _toInt(json['calories']),
      protein: _toInt(json['protein']),
      carbs: _toInt(json['carbs']),
      fats: _toInt(json['fats']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Registro historico de peso corporal.
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
  });

  final String id;
  final double weightKg;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {'id': id, 'weightKg': weightKg, 'date': date.toIso8601String()};
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id']?.toString() ?? _newId(),
      weightKg: _toDouble(json['weightKg']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Objetivos diarios y meta de peso del usuario.
class FitnessGoals {
  const FitnessGoals({
    required this.calorieGoal,
    required this.waterGoalMl,
    required this.workoutGoalMinutes,
    required this.targetWeightKg,
  });

  final int calorieGoal;
  final int waterGoalMl;
  final int workoutGoalMinutes;
  final double targetWeightKg;

  bool get isDefault {
    return calorieGoal == 2200 &&
        waterGoalMl == 2500 &&
        workoutGoalMinutes == 45 &&
        (targetWeightKg - 70).abs() < 0.05;
  }

  Map<String, dynamic> toJson() {
    return {
      'calorieGoal': calorieGoal,
      'waterGoalMl': waterGoalMl,
      'workoutGoalMinutes': workoutGoalMinutes,
      'targetWeightKg': targetWeightKg,
    };
  }

  factory FitnessGoals.fromJson(Map<String, dynamic> json) {
    return FitnessGoals(
      calorieGoal: _toInt(json['calorieGoal'], fallback: 2200),
      waterGoalMl: _toInt(json['waterGoalMl'], fallback: 2500),
      workoutGoalMinutes: _toInt(json['workoutGoalMinutes'], fallback: 45),
      targetWeightKg: _toDouble(json['targetWeightKg'], fallback: 70),
    );
  }

  FitnessGoals copyWith({
    int? calorieGoal,
    int? waterGoalMl,
    int? workoutGoalMinutes,
    double? targetWeightKg,
  }) {
    return FitnessGoals(
      calorieGoal: calorieGoal ?? this.calorieGoal,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      workoutGoalMinutes: workoutGoalMinutes ?? this.workoutGoalMinutes,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
}
