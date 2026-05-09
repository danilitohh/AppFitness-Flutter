part of '../main.dart';

// -----------------------------------------------------------------------------
// Estado global de negocio.
// FitnessStore concentra persistencia local, calculos diarios y datos del usuario.
// -----------------------------------------------------------------------------
/// Store principal de fitness: concentra estado, calculos y persistencia local.
class FitnessStore extends ChangeNotifier {
  static const String _workoutsKeyBase = 'fitness_workouts';
  static const String _mealsKeyBase = 'fitness_meals';
  static const String _weightsKeyBase = 'fitness_weights';
  static const String _waterKeyBase = 'fitness_water';
  static const String _goalsKeyBase = 'fitness_goals';
  static const String _coachKeyBase = 'fitness_coach_profile';
  static const String _onboardingKeyBase = 'fitness_onboarding_completed';
  static const String _legacySeedKey = 'fitness_seeded';
  static const String _guestNamespace = 'guest';
  static const FitnessGoals _defaultGoals = FitnessGoals(
    calorieGoal: 2200,
    waterGoalMl: 2500,
    workoutGoalMinutes: 45,
    targetWeightKg: 70,
  );

  final List<WorkoutEntry> _workouts = [];
  final List<MealEntry> _meals = [];
  final List<WeightEntry> _weights = [];
  final Map<String, int> _waterByDay = {};
  FitnessGoals _goals = _defaultGoals;
  CoachProfile _coachProfile = const CoachProfile();
  String _storageNamespace = _guestNamespace;
  bool _onboardingCompleted = false;

  List<WorkoutEntry> get workouts {
    final sorted = [..._workouts];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<MealEntry> get meals {
    final sorted = [..._meals];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<WeightEntry> get weights {
    final sorted = [..._weights];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  FitnessGoals get goals => _goals;
  CoachProfile get coachProfile => _coachProfile;
  bool get hasRecordedData =>
      _workouts.isNotEmpty ||
      _meals.isNotEmpty ||
      _weights.isNotEmpty ||
      _waterByDay.values.any((value) => value > 0);
  bool get needsOnboarding =>
      !_onboardingCompleted &&
      !hasRecordedData &&
      _coachProfile.isDefault &&
      _goals.isDefault;

  Future<void> initialize() async {
    await _loadNamespace(_guestNamespace);
  }

  Future<void> loadForUser(
    String userId, {
    bool allowLegacyMigration = true,
  }) async {
    await _loadNamespace(
      'user_$userId',
      allowLegacyMigration: allowLegacyMigration,
    );
  }

  Future<void> _loadNamespace(
    String namespace, {
    bool allowLegacyMigration = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (allowLegacyMigration && namespace != _guestNamespace) {
      await _migrateLegacyDataIfNeeded(prefs, namespace);
    }

    _storageNamespace = namespace;
    _resetState();
    _readFromPrefs(prefs);
    _onboardingCompleted =
        prefs.getBool(_scopedKey(_onboardingKeyBase)) ??
        (hasRecordedData || !_coachProfile.isDefault || !_goals.isDefault);

    notifyListeners();
  }

  void _readFromPrefs(SharedPreferences prefs) {
    final workoutsRaw = prefs.getString(_scopedKey(_workoutsKeyBase));
    if (workoutsRaw != null && workoutsRaw.isNotEmpty) {
      final decoded = jsonDecode(workoutsRaw) as List<dynamic>;
      _workouts
        ..clear()
        ..addAll(
          decoded.map(
            (item) => WorkoutEntry.fromJson(item as Map<String, dynamic>),
          ),
        );
    }

    final mealsRaw = prefs.getString(_scopedKey(_mealsKeyBase));
    if (mealsRaw != null && mealsRaw.isNotEmpty) {
      final decoded = jsonDecode(mealsRaw) as List<dynamic>;
      _meals
        ..clear()
        ..addAll(
          decoded.map(
            (item) => MealEntry.fromJson(item as Map<String, dynamic>),
          ),
        );
    }

    final weightsRaw = prefs.getString(_scopedKey(_weightsKeyBase));
    if (weightsRaw != null && weightsRaw.isNotEmpty) {
      final decoded = jsonDecode(weightsRaw) as List<dynamic>;
      _weights
        ..clear()
        ..addAll(
          decoded.map(
            (item) => WeightEntry.fromJson(item as Map<String, dynamic>),
          ),
        );
    }

    final waterRaw = prefs.getString(_scopedKey(_waterKeyBase));
    if (waterRaw != null && waterRaw.isNotEmpty) {
      final decoded = jsonDecode(waterRaw) as Map<String, dynamic>;
      _waterByDay
        ..clear()
        ..addAll(decoded.map((key, value) => MapEntry(key, _toInt(value))));
    }

    final goalsRaw = prefs.getString(_scopedKey(_goalsKeyBase));
    if (goalsRaw != null && goalsRaw.isNotEmpty) {
      _goals = FitnessGoals.fromJson(
        jsonDecode(goalsRaw) as Map<String, dynamic>,
      );
    }

    final coachRaw = prefs.getString(_scopedKey(_coachKeyBase));
    if (coachRaw != null && coachRaw.isNotEmpty) {
      _coachProfile = CoachProfile.fromJson(
        jsonDecode(coachRaw) as Map<String, dynamic>,
      );
    }
  }

  List<WorkoutEntry> workoutsForDate(DateTime date) {
    return workouts.where((item) => _isSameDay(item.date, date)).toList();
  }

  List<MealEntry> mealsForDate(DateTime date) {
    return meals.where((item) => _isSameDay(item.date, date)).toList();
  }

  List<WeightEntry> recentWeights({int days = 30}) {
    final limit = DateTime.now().subtract(Duration(days: days));
    final filtered = weights.where((item) => item.date.isAfter(limit)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  int waterForDate(DateTime date) {
    return _waterByDay[_dayKey(date)] ?? 0;
  }

  int get caloriesToday {
    return mealsForDate(
      DateTime.now(),
    ).fold(0, (sum, item) => sum + item.calories);
  }

  int get proteinToday {
    return mealsForDate(
      DateTime.now(),
    ).fold(0, (sum, item) => sum + item.protein);
  }

  int get carbsToday {
    return mealsForDate(
      DateTime.now(),
    ).fold(0, (sum, item) => sum + item.carbs);
  }

  int get fatsToday {
    return mealsForDate(DateTime.now()).fold(0, (sum, item) => sum + item.fats);
  }

  int get waterTodayMl {
    return waterForDate(DateTime.now());
  }

  int get workoutMinutesToday {
    return workoutsForDate(DateTime.now())
        .where((item) => item.completed)
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int get workoutsCompletedToday {
    return workoutsForDate(
      DateTime.now(),
    ).where((item) => item.completed).length;
  }

  int get caloriesBurnedToday {
    return workoutsForDate(DateTime.now())
        .where((item) => item.completed)
        .fold(0, (sum, item) => sum + item.caloriesBurned);
  }

  int get workoutStreak {
    // Cuenta dias consecutivos con entrenamientos completados.
    final completedDates = workouts
        .where((item) => item.completed)
        .map((item) => _dayKey(item.date))
        .toSet();

    var streak = 0;
    var current = DateTime.now();
    while (completedDates.contains(_dayKey(current))) {
      streak += 1;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  double? get latestWeight {
    if (_weights.isEmpty) {
      return null;
    }

    final sorted = [..._weights]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.weightKg;
  }

  double get weeklyWeightDelta {
    final sorted = recentWeights(days: 8);
    if (sorted.length < 2) {
      return 0;
    }

    final first = sorted.first.weightKg;
    final last = sorted.last.weightKg;
    return last - first;
  }

  void addWorkout({
    required String name,
    required String category,
    required int durationMinutes,
    required int caloriesBurned,
    required DateTime date,
    required WorkoutIntensity intensity,
  }) {
    _workouts.add(
      WorkoutEntry(
        id: _newId(),
        name: name,
        category: category,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        date: date,
        intensity: intensity,
        completed: true,
      ),
    );
    _persistAndNotify();
  }

  void setWorkoutCompleted(String id, bool completed) {
    final index = _workouts.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }

    _workouts[index] = _workouts[index].copyWith(completed: completed);
    _persistAndNotify();
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void addMeal({
    required MealType type,
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
    required DateTime date,
  }) {
    _meals.add(
      MealEntry(
        id: _newId(),
        type: type,
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        date: date,
      ),
    );
    _persistAndNotify();
  }

  void deleteMeal(String id) {
    _meals.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void addWater(int ml, {DateTime? date}) {
    final key = _dayKey(date ?? DateTime.now());
    final nextValue = (_waterByDay[key] ?? 0) + ml;
    _waterByDay[key] = nextValue.clamp(0, 10000);
    _persistAndNotify();
  }

  void addWeight(double weightKg, {DateTime? date}) {
    _weights.add(
      WeightEntry(
        id: _newId(),
        weightKg: weightKg,
        date: date ?? DateTime.now(),
      ),
    );
    _persistAndNotify();
  }

  void deleteWeight(String id) {
    _weights.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void updateGoals(FitnessGoals goals) {
    _goals = goals;
    _persistAndNotify();
  }

  void updateCoachProfile(CoachProfile profile) {
    _coachProfile = profile;
    _persistAndNotify();
  }

  Future<void> completeOnboarding({
    required CoachProfile profile,
    required FitnessGoals goals,
    double? currentWeightKg,
  }) async {
    _coachProfile = profile;
    _goals = goals;
    if (currentWeightKg != null) {
      _setInitialWeight(currentWeightKg);
    }
    _onboardingCompleted = true;
    notifyListeners();
    await _persist();
  }

  void _persistAndNotify() {
    // Notifica cambios en UI y persiste en background.
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey(_workoutsKeyBase),
      jsonEncode(_workouts.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _scopedKey(_mealsKeyBase),
      jsonEncode(_meals.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _scopedKey(_weightsKeyBase),
      jsonEncode(_weights.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(_scopedKey(_waterKeyBase), jsonEncode(_waterByDay));
    await prefs.setString(
      _scopedKey(_goalsKeyBase),
      jsonEncode(_goals.toJson()),
    );
    await prefs.setString(
      _scopedKey(_coachKeyBase),
      jsonEncode(_coachProfile.toJson()),
    );
    await prefs.setBool(_scopedKey(_onboardingKeyBase), _onboardingCompleted);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _dayKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(normalized);
  }

  void _resetState() {
    _workouts.clear();
    _meals.clear();
    _weights.clear();
    _waterByDay.clear();
    _goals = _defaultGoals;
    _coachProfile = const CoachProfile();
    _onboardingCompleted = false;
  }

  void _setInitialWeight(double value) {
    final now = DateTime.now();
    _weights.removeWhere((item) => _isSameDay(item.date, now));
    _weights.add(WeightEntry(id: _newId(), weightKg: value, date: now));
  }

  Future<void> _migrateLegacyDataIfNeeded(
    SharedPreferences prefs,
    String namespace,
  ) async {
    if (_hasScopedData(prefs, namespace) || !_hasLegacyData(prefs)) {
      return;
    }

    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _workoutsKeyBase,
      targetKey: _scopedKeyForNamespace(_workoutsKeyBase, namespace),
    );
    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _mealsKeyBase,
      targetKey: _scopedKeyForNamespace(_mealsKeyBase, namespace),
    );
    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _weightsKeyBase,
      targetKey: _scopedKeyForNamespace(_weightsKeyBase, namespace),
    );
    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _waterKeyBase,
      targetKey: _scopedKeyForNamespace(_waterKeyBase, namespace),
    );
    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _goalsKeyBase,
      targetKey: _scopedKeyForNamespace(_goalsKeyBase, namespace),
    );
    await _copyLegacyStringIfPresent(
      prefs,
      sourceKey: _coachKeyBase,
      targetKey: _scopedKeyForNamespace(_coachKeyBase, namespace),
    );
    await prefs.setBool(
      _scopedKeyForNamespace(_onboardingKeyBase, namespace),
      _legacyDataSuggestsCompleted(prefs),
    );

    await prefs.remove(_workoutsKeyBase);
    await prefs.remove(_mealsKeyBase);
    await prefs.remove(_weightsKeyBase);
    await prefs.remove(_waterKeyBase);
    await prefs.remove(_goalsKeyBase);
    await prefs.remove(_coachKeyBase);
    await prefs.remove(_legacySeedKey);
  }

  bool _hasScopedData(SharedPreferences prefs, String namespace) {
    return prefs.containsKey(
          _scopedKeyForNamespace(_workoutsKeyBase, namespace),
        ) ||
        prefs.containsKey(_scopedKeyForNamespace(_mealsKeyBase, namespace)) ||
        prefs.containsKey(_scopedKeyForNamespace(_weightsKeyBase, namespace)) ||
        prefs.containsKey(_scopedKeyForNamespace(_waterKeyBase, namespace)) ||
        prefs.containsKey(_scopedKeyForNamespace(_goalsKeyBase, namespace)) ||
        prefs.containsKey(_scopedKeyForNamespace(_coachKeyBase, namespace)) ||
        prefs.containsKey(
          _scopedKeyForNamespace(_onboardingKeyBase, namespace),
        );
  }

  bool _hasLegacyData(SharedPreferences prefs) {
    return prefs.containsKey(_workoutsKeyBase) ||
        prefs.containsKey(_mealsKeyBase) ||
        prefs.containsKey(_weightsKeyBase) ||
        prefs.containsKey(_waterKeyBase) ||
        prefs.containsKey(_goalsKeyBase) ||
        prefs.containsKey(_coachKeyBase) ||
        prefs.getBool(_legacySeedKey) == true;
  }

  bool _legacyDataSuggestsCompleted(SharedPreferences prefs) {
    final hasActivity =
        prefs.containsKey(_workoutsKeyBase) ||
        prefs.containsKey(_mealsKeyBase) ||
        prefs.containsKey(_weightsKeyBase) ||
        prefs.containsKey(_waterKeyBase);
    final hasProfile =
        prefs.containsKey(_goalsKeyBase) || prefs.containsKey(_coachKeyBase);
    return hasActivity || hasProfile || prefs.getBool(_legacySeedKey) == true;
  }

  Future<void> _copyLegacyStringIfPresent(
    SharedPreferences prefs, {
    required String sourceKey,
    required String targetKey,
  }) async {
    final raw = prefs.getString(sourceKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    await prefs.setString(targetKey, raw);
  }

  String _scopedKey(String base) {
    return _scopedKeyForNamespace(base, _storageNamespace);
  }

  String _scopedKeyForNamespace(String base, String namespace) {
    return '${base}_$namespace';
  }
}
