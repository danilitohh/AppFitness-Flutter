part of '../main.dart';

// -----------------------------------------------------------------------------
// Pantallas principales del home.
// Dashboard, entrenamientos, nutricion y progreso del usuario.
// -----------------------------------------------------------------------------
/// Pantalla de inicio con resumen de metricas del dia.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final goals = store.goals;
    final authUser = AuthAppScope.of(context).currentUser;
    final todayLabel = DateFormat(
      'EEEE, d MMMM',
      'es_ES',
    ).format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: _appHeroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _appPrimary.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (authUser != null)
                    Text(
                      'Hola, ${authUser.firstName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (authUser != null) const SizedBox(height: 4),
                  const Text(
                    'Tu resumen de hoy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _capitalize(todayLabel),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Racha activa: ${store.workoutStreak} dias',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: _appFormSectionGap),
        MetricCard(
          title: 'Hidratacion',
          value: '${store.waterTodayMl} ml',
          subtitle: 'Meta ${goals.waterGoalMl} ml',
          icon: Icons.water_drop,
          color: const Color(0xFF0284C7),
          progress: _safeProgress(store.waterTodayMl, goals.waterGoalMl),
        ),
        MetricCard(
          title: 'Calorias',
          value: '${store.caloriesToday} kcal',
          subtitle: 'Meta ${goals.calorieGoal} kcal',
          icon: Icons.local_fire_department,
          color: const Color(0xFFEA580C),
          progress: _safeProgress(store.caloriesToday, goals.calorieGoal),
        ),
        MetricCard(
          title: 'Entreno',
          value: '${store.workoutMinutesToday} min',
          subtitle: 'Meta ${goals.workoutGoalMinutes} min',
          icon: Icons.bolt,
          color: const Color(0xFF7C3AED),
          progress: _safeProgress(
            store.workoutMinutesToday,
            goals.workoutGoalMinutes,
          ),
        ),
        MetricCard(
          title: 'Peso actual',
          value: store.latestWeight != null
              ? '${store.latestWeight!.toStringAsFixed(1)} kg'
              : 'Sin registro',
          subtitle: 'Objetivo ${goals.targetWeightKg.toStringAsFixed(1)} kg',
          icon: Icons.monitor_weight,
          color: const Color(0xFF0891B2),
          progress: store.latestWeight == null
              ? 0
              : _weightProgress(store.latestWeight!, goals.targetWeightKg),
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acciones rapidas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickActionButton(
                      icon: Icons.water_drop,
                      label: '+250 ml',
                      color: const Color(0xFF0284C7),
                      onTap: () => store.addWater(250),
                    ),
                    _quickActionButton(
                      icon: Icons.fitness_center,
                      label: 'Nuevo entreno',
                      color: const Color(0xFF7C3AED),
                      onTap: () => openWorkoutCatalog(context, store),
                    ),
                    _quickActionButton(
                      icon: Icons.restaurant,
                      label: 'Nueva comida',
                      color: const Color(0xFFEA580C),
                      onTap: () => showMealSheet(context, store),
                    ),
                    _quickActionButton(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Registrar peso',
                      color: const Color(0xFF0891B2),
                      onTap: () => showWeightSheet(context, store),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ultimos entrenamientos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (store.workouts.isEmpty)
                  const Text('Todavia no tienes entrenamientos registrados.')
                else
                  ...store.workouts
                      .take(3)
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name),
                          subtitle: Text(
                            '${_formatEntryDateTime(item.date, includeYear: false)} - ${item.category} - ${item.durationMinutes} min',
                          ),
                          trailing: Icon(
                            item.completed
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: item.completed
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla para listar, filtrar y gestionar entrenamientos.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  bool _showOnlyToday = false;

  @override
  Widget build(BuildContext context) {
    final entries = _showOnlyToday
        ? widget.store.workoutsForDate(DateTime.now())
        : widget.store.workouts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildWeeklySummaryCard(),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildTodayPlanCard(),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildWorkoutCoachCard(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text('Todos')),
              ButtonSegment<bool>(value: true, label: Text('Hoy')),
            ],
            selected: {_showOnlyToday},
            onSelectionChanged: (selection) {
              setState(() {
                _showOnlyToday = selection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 4),
        if (entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin entrenamientos para mostrar.'),
            ),
          )
        else
          ...entries.map(_buildWorkoutEntryCard),
      ],
    );
  }

  Widget _buildWorkoutEntryCard(WorkoutEntry item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _intensityColor(
            item.intensity,
          ).withValues(alpha: 0.15),
          child: Icon(
            Icons.fitness_center,
            color: _intensityColor(item.intensity),
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.category} • ${_formatEntryDateTime(item.date)}'),
            const SizedBox(height: 6),
            _buildWorkoutBadges(item),
          ],
        ),
        trailing: SizedBox(
          width: 112,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                value: item.completed,
                onChanged: (value) =>
                    widget.store.setWorkoutCompleted(item.id, value ?? false),
              ),
              IconButton(
                onPressed: () => widget.store.deleteWorkout(item.id),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    final stats = _weeklyWorkoutStats(days: 7);
    final streak = widget.store.workoutStreak;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_outlined, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Resumen semanal',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  'Ultimos 7 dias',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statPill(label: 'Sesiones', value: '${stats.sessions}'),
                _statPill(label: 'Minutos', value: '${stats.totalMinutes}'),
                _statPill(label: 'Kcal', value: '${stats.totalCalories}'),
                _statPill(label: 'Dias', value: '${stats.daysTrained}/7'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              stats.sessions == 0
                  ? 'Aun no hay entrenos completados esta semana.'
                  : 'Promedio ${stats.averageMinutes} min por sesion. Racha actual: $streak dias.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayPlanCard() {
    final goals = widget.store.goals;
    final minutesToday = widget.store.workoutMinutesToday;
    final goal = goals.workoutGoalMinutes;
    final missing = math.max(goal - minutesToday, 0);
    final progress = goal <= 0
        ? 0.0
        : (minutesToday / goal).clamp(0.0, 1.0).toDouble();
    final completed = goal > 0 && missing == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today_outlined, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Plan de hoy',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                _badge(
                  label: completed ? 'Meta cumplida' : 'Pendiente',
                  color: completed
                      ? const Color(0xFF047857)
                      : const Color(0xFFB45309),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hoy: $minutesToday/$goal min • ${widget.store.workoutsCompletedToday} sesiones • ${widget.store.caloriesBurnedToday} kcal',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: _appPrimary,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    completed
                        ? 'Buen trabajo. Si quieres, agrega un entreno extra.'
                        : 'Te faltan $missing min para tu meta. Un entreno rapido te ayuda.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => openWorkoutCatalog(context, widget.store),
                  child: Text(completed ? 'Elegir otro' : 'Ver opciones'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCoachCard() {
    final store = widget.store;
    final profile = store.coachProfile;
    final weeklyStats = _weeklyWorkoutStats(days: 7);
    final recentCompleted = _recentCompletedWorkouts(days: 7);
    final categoryCounts = _categoryCounts(recentCompleted);
    final targetDays = profile.daysPerWeek;
    final remainingDays = targetDays - weeklyStats.daysTrained;
    final summary = _workoutCoachSummary(
      weeklyStats,
      targetDays,
      remainingDays,
    );
    final planSuggestions = _buildWorkoutPlanSuggestions(profile: profile);
    final suggestions = _workoutSuggestions(
      profile: profile,
      weeklyStats: weeklyStats,
      categoryCounts: categoryCounts,
      remainingDays: remainingDays,
      highIntensityCount: recentCompleted
          .where((item) => item.intensity == WorkoutIntensity.high)
          .length,
    );
    final nextFocus = _nextWorkoutFocus(profile, categoryCounts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Coach IA de entreno',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showCoachSheet(context, store),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Personalizar plan'),
            ),
            if (profile.isDefault) ...[
              Text(
                'Responde unas preguntas para afinar el plan a tu objetivo.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(summary, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CoachChip(
                  icon: Icons.flag_outlined,
                  label: profile.goal.label,
                ),
                _CoachChip(
                  icon: Icons.bolt_outlined,
                  label: profile.experience.label,
                ),
                _CoachChip(
                  icon: Icons.calendar_today_outlined,
                  label: '${profile.daysPerWeek} dias/sem',
                ),
                _CoachChip(
                  icon: Icons.fitness_center_outlined,
                  label: profile.equipment.label,
                ),
              ],
            ),
            if (planSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Rutinas sugeridas para tu objetivo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...planSuggestions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WorkoutPlanSuggestionCard(
                    suggestion: item,
                    onOpen: () => openWorkoutTemplateDetails(
                      context,
                      store,
                      item.template,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Ajustes para esta semana',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (item) => _CoachSuggestionLine(
                icon: Icons.check_circle_outline,
                text: item,
              ),
            ),
            if (nextFocus.isNotEmpty) ...[
              const SizedBox(height: 6),
              _CoachSuggestionLine(
                icon: Icons.trending_up,
                text: 'Siguiente enfoque sugerido: $nextFocus.',
                color: _appPrimaryDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _workoutCoachSummary(
    _WeeklyWorkoutStats weeklyStats,
    int targetDays,
    int remainingDays,
  ) {
    if (weeklyStats.daysTrained == 0) {
      return 'Aun no entrenas esta semana. Tu objetivo son $targetDays dias.';
    }
    if (remainingDays > 0) {
      return 'Llevas ${weeklyStats.daysTrained} dias. Te faltan $remainingDays para tu objetivo.';
    }
    if (remainingDays == 0) {
      return 'Perfecto, ya alcanzaste $targetDays dias de entreno esta semana.';
    }
    return 'Vas por encima del objetivo semanal. Prioriza recuperacion.';
  }

  List<String> _workoutSuggestions({
    required CoachProfile profile,
    required _WeeklyWorkoutStats weeklyStats,
    required Map<String, int> categoryCounts,
    required int remainingDays,
    required int highIntensityCount,
  }) {
    final suggestions = <String>[];

    if (remainingDays > 0) {
      suggestions.add(
        'Agenda $remainingDays sesiones cortas (20-40 min) para cerrar tu semana.',
      );
    } else if (remainingDays < 0) {
      suggestions.add(
        'Incluye un dia de descanso activo o movilidad para recuperarte.',
      );
    } else {
      suggestions.add(
        'Mantente consistente y alterna intensidades para seguir progresando.',
      );
    }

    if (categoryCounts['Movilidad'] == 0) {
      suggestions.add('Agrega 10-15 min de movilidad al final de 2 sesiones.');
    }

    switch (profile.goal) {
      case FitnessGoalType.gainMuscle:
        if ((categoryCounts['Fuerza'] ?? 0) < 2) {
          suggestions.add(
            'Incluye 2-3 sesiones de fuerza con progresion de carga.',
          );
        }
        break;
      case FitnessGoalType.loseFat:
        if ((categoryCounts['Cardio'] ?? 0) < 1) {
          suggestions.add('Suma 1-2 sesiones de cardio moderado o intervalos.');
        }
        break;
      case FitnessGoalType.performance:
        suggestions.add(
          'Combina fuerza + cardio, y deja un dia tecnico ligero.',
        );
        break;
      case FitnessGoalType.maintain:
        suggestions.add('Con 2 fuerza + 1 cardio suave mantienes tu nivel.');
        break;
    }

    if (highIntensityCount >= 3) {
      suggestions.add('Esta semana fue intensa. Alterna con sesiones suaves.');
    }

    if (profile.equipment == EquipmentAccess.home) {
      suggestions.add('Aprovecha peso corporal, bandas y tempo controlado.');
    } else if (profile.equipment == EquipmentAccess.gym) {
      suggestions.add('Prioriza ejercicios compuestos con maquinas o barras.');
    }

    return suggestions.take(4).toList();
  }

  String _nextWorkoutFocus(
    CoachProfile profile,
    Map<String, int> categoryCounts,
  ) {
    if ((categoryCounts['Movilidad'] ?? 0) == 0) {
      return 'Movilidad y recuperacion (10-20 min)';
    }

    switch (profile.goal) {
      case FitnessGoalType.gainMuscle:
        return 'Fuerza: tren superior e inferior';
      case FitnessGoalType.loseFat:
        return 'Cardio intervalado 20-30 min';
      case FitnessGoalType.performance:
        return 'Fuerza + cardio tecnico';
      case FitnessGoalType.maintain:
        return 'Circuito mixto moderado';
    }
  }

  List<WorkoutEntry> _recentCompletedWorkouts({int days = 7}) {
    final now = DateTime.now();
    final endDay = DateTime(now.year, now.month, now.day);
    final startDay = endDay.subtract(Duration(days: days - 1));

    return widget.store.workouts.where((item) {
      if (!item.completed) {
        return false;
      }
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      return !day.isBefore(startDay) &&
          !day.isAfter(endDay.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, int> _categoryCounts(List<WorkoutEntry> workouts) {
    final counts = <String, int>{'Fuerza': 0, 'Cardio': 0, 'Movilidad': 0};
    for (final item in workouts) {
      final bucket = _categoryBucket(item.category);
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }
    return counts;
  }

  String _categoryBucket(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('cardio') ||
        normalized.contains('hiit') ||
        normalized.contains('correr') ||
        normalized.contains('run')) {
      return 'Cardio';
    }
    if (normalized.contains('mov') ||
        normalized.contains('recup') ||
        normalized.contains('yoga') ||
        normalized.contains('stretch') ||
        normalized.contains('pilates')) {
      return 'Movilidad';
    }
    return 'Fuerza';
  }

  Widget _buildWorkoutBadges(WorkoutEntry item) {
    final statusColor = item.completed
        ? const Color(0xFF047857)
        : const Color(0xFFB45309);
    final intensityColor = _intensityColor(item.intensity);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _badge(label: '${item.durationMinutes} min', color: Colors.blueGrey),
        _badge(label: '${item.caloriesBurned} kcal', color: Colors.deepOrange),
        _badge(label: item.intensity.label, color: intensityColor),
        _badge(
          label: item.completed ? 'Completado' : 'Pendiente',
          color: statusColor,
        ),
      ],
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _statPill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  _WeeklyWorkoutStats _weeklyWorkoutStats({int days = 7}) {
    final now = DateTime.now();
    final endDay = DateTime(now.year, now.month, now.day);
    final startDay = endDay.subtract(Duration(days: days - 1));
    final recent = widget.store.workouts.where((item) {
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      return (day.isAtSameMomentAs(startDay) || day.isAfter(startDay)) &&
          (day.isAtSameMomentAs(endDay) ||
              day.isBefore(endDay.add(const Duration(days: 1))));
    }).toList();

    final completed = recent.where((item) => item.completed).toList();
    final totalMinutes = completed.fold(
      0,
      (sum, item) => sum + item.durationMinutes,
    );
    final totalCalories = completed.fold(
      0,
      (sum, item) => sum + item.caloriesBurned,
    );
    final sessions = completed.length;
    final daysTrained = completed
        .map((item) => _dayKey(item.date))
        .toSet()
        .length;
    final averageMinutes = sessions == 0
        ? 0
        : (totalMinutes / sessions).round();

    return _WeeklyWorkoutStats(
      sessions: sessions,
      totalMinutes: totalMinutes,
      totalCalories: totalCalories,
      daysTrained: daysTrained,
      averageMinutes: averageMinutes,
    );
  }

  String _dayKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(normalized);
  }
}

class _WeeklyWorkoutStats {
  const _WeeklyWorkoutStats({
    required this.sessions,
    required this.totalMinutes,
    required this.totalCalories,
    required this.daysTrained,
    required this.averageMinutes,
  });

  final int sessions;
  final int totalMinutes;
  final int totalCalories;
  final int daysTrained;
  final int averageMinutes;
}

/// Pantalla para seguimiento de nutricion e hidratacion.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _showOnlyToday = true;

  @override
  Widget build(BuildContext context) {
    final entries = _showOnlyToday
        ? widget.store.mealsForDate(DateTime.now())
        : widget.store.meals;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen nutricional de hoy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MacroPill(
                        label: 'Proteina',
                        value: '${widget.store.proteinToday} g',
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroPill(
                        label: 'Carbos',
                        value: '${widget.store.carbsToday} g',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroPill(
                        label: 'Grasas',
                        value: '${widget.store.fatsToday} g',
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hidratacion',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.store.waterTodayMl} ml / ${widget.store.goals.waterGoalMl} ml',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _safeProgress(
                    widget.store.waterTodayMl,
                    widget.store.goals.waterGoalMl,
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => widget.store.addWater(250),
                      child: const Text('+250 ml'),
                    ),
                    OutlinedButton(
                      onPressed: () => widget.store.addWater(500),
                      child: const Text('+500 ml'),
                    ),
                    OutlinedButton(
                      onPressed: () => widget.store.addWater(-250),
                      child: const Text('-250 ml'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildNutritionCoachCard(),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: true, label: Text('Hoy')),
            ButtonSegment<bool>(value: false, label: Text('Historico')),
          ],
          selected: {_showOnlyToday},
          onSelectionChanged: (selection) {
            setState(() {
              _showOnlyToday = selection.first;
            });
          },
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay comidas registradas para este filtro.'),
            ),
          )
        else
          ...entries.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(item.type.icon),
                title: Text(item.name),
                subtitle: Text(
                  '${item.type.label} • ${_formatEntryDateTime(item.date)}\n${item.calories} kcal • P ${item.protein}g / C ${item.carbs}g / G ${item.fats}g',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => widget.store.deleteMeal(item.id),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionCoachCard() {
    final store = widget.store;
    final profile = store.coachProfile;
    final goals = store.goals;
    final calories = store.caloriesToday;
    final calorieGoal = goals.calorieGoal;
    final calorieGap = calorieGoal - calories;
    final weight = store.latestWeight ?? goals.targetWeightKg;
    final proteinTarget = _proteinTargetForGoal(profile.goal, weight);
    final proteinGap = proteinTarget - store.proteinToday;
    final mealsLogged = store.mealsForDate(DateTime.now()).length;
    final remainingMeals = profile.mealsPerDay - mealsLogged;
    final waterGap = goals.waterGoalMl - store.waterTodayMl;
    final mealPlanSuggestions = _buildMealPlanSuggestions(
      profile: profile,
      goals: goals,
      referenceWeight: weight,
    );

    final summary = _nutritionSummary(calorieGap, calorieGoal, profile);
    final suggestions = _nutritionSuggestions(
      calorieGap: calorieGap,
      proteinGap: proteinGap,
      remainingMeals: remainingMeals,
      waterGap: waterGap,
      proteinTarget: proteinTarget,
      mealsPerDay: profile.mealsPerDay,
      dietStyle: profile.dietStyle,
    );
    final contextNotes = _coachContextNotes(profile);
    final notesHint = _coachNotesHint(contextNotes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Coach IA de nutricion',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showCoachSheet(context, store),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Personalizar plan'),
            ),
            if (profile.isDefault) ...[
              Text(
                'Dinos tu objetivo para ajustar porciones y frecuencia.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(summary, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CoachChip(
                  icon: Icons.flag_outlined,
                  label: profile.goal.label,
                ),
                _CoachChip(
                  icon: Icons.restaurant_menu_outlined,
                  label: profile.dietStyle.label,
                ),
                _CoachChip(
                  icon: Icons.schedule_outlined,
                  label: '${profile.mealsPerDay} comidas/dia',
                ),
              ],
            ),
            if (mealPlanSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Comidas sugeridas para tu objetivo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...mealPlanSuggestions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MealPlanSuggestionCard(suggestion: item),
                ),
              ),
            ],
            if (notesHint != null) ...[
              const SizedBox(height: 10),
              _CoachSuggestionLine(
                icon: Icons.fact_check_outlined,
                text: notesHint,
                color: _appPrimaryDark,
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Ajustes para hoy',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (item) => _CoachSuggestionLine(
                icon: Icons.check_circle_outline,
                text: item,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nutritionSummary(
    int calorieGap,
    int calorieGoal,
    CoachProfile profile,
  ) {
    if (calorieGoal <= 0) {
      return 'Define tu meta de calorias para recomendaciones mas precisas.';
    }
    if (calorieGap > 200) {
      return 'Te faltan ~${calorieGap.abs()} kcal para tu meta diaria.';
    }
    if (calorieGap < -200) {
      return 'Vas ~${calorieGap.abs()} kcal por encima de tu meta.';
    }
    return 'Vas cerca de tu meta diaria. Buen equilibrio para ${profile.goal.label.toLowerCase()}.';
  }

  List<String> _nutritionSuggestions({
    required int calorieGap,
    required int proteinGap,
    required int remainingMeals,
    required int waterGap,
    required int proteinTarget,
    required int mealsPerDay,
    required DietStyle dietStyle,
  }) {
    final suggestions = <String>[];

    if (calorieGap > 250) {
      suggestions.add('Completa con una comida ligera rica en proteina.');
    } else if (calorieGap < -250) {
      suggestions.add('Ajusta porciones para no exceder tu objetivo.');
    } else {
      suggestions.add('Mantente en este rango y distribuye bien tus macros.');
    }

    if (proteinGap > 15) {
      suggestions.add('Aumenta ~${proteinGap.abs()} g de proteina hoy.');
    }

    final proteinPerMeal = mealsPerDay > 0
        ? (proteinTarget / mealsPerDay).round()
        : proteinTarget;
    suggestions.add('Meta: ~$proteinPerMeal g de proteina por comida.');

    if (remainingMeals > 0) {
      suggestions.add(
        'Te faltan $remainingMeals comidas para tu ritmo diario.',
      );
    }

    if (waterGap > 400) {
      suggestions.add('Suma ${waterGap.abs()} ml de agua para tu objetivo.');
    }

    if (dietStyle == DietStyle.lowCarb) {
      suggestions.add('Prioriza verduras, grasas buenas y proteina magra.');
    } else if (dietStyle == DietStyle.highProtein) {
      suggestions.add('Incluye una porcion proteica en cada comida.');
    }

    return suggestions.take(4).toList();
  }

  String _coachContextNotes(CoachProfile profile) {
    return [
      profile.allergies.trim(),
      profile.notes.trim(),
    ].where((item) => item.isNotEmpty).join('; ');
  }

  String? _coachNotesHint(String notes) {
    final normalized = notes.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.contains('sin lactosa') || normalized.contains('lactosa')) {
      return 'Ajuste activo: usa opciones sin lactosa o bebidas vegetales.';
    }

    if (normalized.contains('sin gluten') || normalized.contains('celia')) {
      return 'Ajuste activo: prioriza arroz, papa, quinoa y avena sin gluten.';
    }

    if (normalized.contains('vegano') || normalized.contains('vegana')) {
      return 'Ajuste activo: prioriza tofu, tempeh, legumbres y bebidas vegetales.';
    }

    if (normalized.contains('vegetar')) {
      return 'Ajuste activo: apoya la proteina con legumbres, tofu, huevos o lacteos si los toleras.';
    }

    if (normalized.contains('frutos secos') ||
        normalized.contains('mani') ||
        normalized.contains('nuez')) {
      return 'Ajuste activo: evita frutos secos y reemplazalos por semillas o aceite de oliva.';
    }

    if (normalized.contains('azucar')) {
      return 'Ajuste activo: prefiere fruta entera y snacks sin azucar agregada.';
    }

    return 'Ajuste activo: ten en cuenta esta preferencia al elegir alimentos: ${_shortCoachNote(notes)}.';
  }

  String _shortCoachNote(String notes) {
    final compact = notes.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.length <= 72) {
      return compact;
    }

    return '${compact.substring(0, 69).trim()}...';
  }
}

/// Pantalla de progreso: objetivos, peso, tendencias y rendimiento.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final goals = store.goals;
    final weightData = store.recentWeights(days: 30);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Objetivos diarios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Calorias: ${goals.calorieGoal} kcal'),
                Text('Agua: ${goals.waterGoalMl} ml'),
                Text('Entreno: ${goals.workoutGoalMinutes} min'),
                Text(
                  'Peso objetivo: ${goals.targetWeightKg.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => showGoalSheet(context, store),
                  icon: const Icon(Icons.tune),
                  label: const Text('Editar objetivos'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tendencia de peso (30 dias)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 180, child: WeightChart(entries: weightData)),
                const SizedBox(height: 8),
                Text(
                  'Cambio semanal: ${store.weeklyWeightDelta >= 0 ? '+' : ''}${store.weeklyWeightDelta.toStringAsFixed(1)} kg',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indicadores de rendimiento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrenos completados hoy: ${store.workoutsCompletedToday}',
                ),
                Text(
                  'Calorias quemadas hoy: ${store.caloriesBurnedToday} kcal',
                ),
                Text('Racha activa: ${store.workoutStreak} dias'),
                Text('Total entrenamientos: ${store.workouts.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de peso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (store.weights.isEmpty)
                  const Text('Sin registros de peso.')
                else
                  ...store.weights
                      .take(8)
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${entry.weightKg.toStringAsFixed(1)} kg',
                          ),
                          subtitle: Text(
                            DateFormat('d MMM yyyy').format(entry.date),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => store.deleteWeight(entry.id),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
