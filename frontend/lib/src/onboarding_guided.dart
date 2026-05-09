part of '../main.dart';

// -----------------------------------------------------------------------------
// Onboarding guiado extendido.
// Version paso a paso con preguntas mas ricas sobre salud, horarios y nutricion.
// -----------------------------------------------------------------------------
class GuidedOnboardingSurveyScreen extends StatefulWidget {
  const GuidedOnboardingSurveyScreen({
    super.key,
    required this.store,
    required this.authStore,
    required this.user,
  });

  final FitnessStore store;
  final AuthStore authStore;
  final AuthUser user;

  @override
  State<GuidedOnboardingSurveyScreen> createState() =>
      _GuidedOnboardingSurveyScreenState();
}

class _GuidedOnboardingSurveyScreenState
    extends State<GuidedOnboardingSurveyScreen> {
  static const int _finalSurveyStep = 7;
  static const List<String> _healthFlagOptions = [
    'Discapacidad',
    'Lesión',
    'Enfermedad',
    'Embarazo',
    'Otras',
    'No poseo',
  ];

  final _formKey = GlobalKey<FormState>();
  final Set<String> _healthFlags = <String>{};

  late CoachProfile _profile;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _allergiesController;
  late TextEditingController _notesController;

  int _step = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.store.coachProfile;
    final latestWeight = widget.store.latestWeight;
    final targetWeight = widget.store.goals.targetWeightKg;
    _ageController = TextEditingController(
      text: widget.user.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.user.heightCm == null
          ? ''
          : widget.user.heightCm!.toStringAsFixed(0),
    );
    _currentWeightController = TextEditingController(
      text: latestWeight == null ? '' : latestWeight.toStringAsFixed(1),
    );
    _targetWeightController = TextEditingController(
      text: widget.store.goals.isDefault && latestWeight == null
          ? ''
          : targetWeight.toStringAsFixed(1),
    );
    _allergiesController = TextEditingController(text: _profile.allergies);
    _notesController = TextEditingController(text: _profile.notes);
    _seedHealthFlags();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final age = _parseOptionalInt(_ageController.text);
    final heightCm = _parseOptionalDouble(_heightController.text);
    final currentWeight = _parseOptionalDouble(_currentWeightController.text);
    final targetWeight = _parseOptionalDouble(_targetWeightController.text);
    final allergies = _allergiesController.text.trim();
    final notes = _composeSurveyNotes();
    final surveyProfile = _profile.copyWith(allergies: allergies, notes: notes);
    final recommendedGoals = _buildRecommendedGoals(
      profile: surveyProfile,
      currentWeightKg: currentWeight,
      targetWeightKg: targetWeight,
      age: age,
      heightCm: heightCm,
    );
    final recommendations = _buildOnboardingRecommendations(
      profile: surveyProfile,
      goals: recommendedGoals,
      currentWeightKg: currentWeight,
      targetWeightKg: targetWeight,
    );

    return Scaffold(
      backgroundColor: _appBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1FAF7), Color(0xFFF7FBFA), Color(0xFFEDF7F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _buildGuidedTopBar(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                            child: _buildGuidedStepContent(
                              recommendedGoals: recommendedGoals,
                              recommendations: recommendations,
                              currentWeightKg: currentWeight,
                              notes: notes,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildGuidedBottomActionBar(
                    recommendedGoals: recommendedGoals,
                    currentWeightKg: currentWeight,
                    targetWeightKg: targetWeight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedTopBar() {
    final progress = (_step + 1) / (_finalSurveyStep + 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _appSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _appOutline),
          boxShadow: const [
            BoxShadow(color: _appShadow, blurRadius: 24, offset: Offset(0, 14)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: _step == 0
                  ? const SizedBox.shrink()
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: _appPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: _goBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _appPrimaryDark,
                          size: 19,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _step == 0
                        ? 'Evaluación inicial'
                        : 'Paso $_step de $_finalSurveyStep',
                    style: const TextStyle(
                      color: _appMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress,
                      backgroundColor: _appPrimary.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _appPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: _appHeroGradient,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidedStepContent({
    required FitnessGoals recommendedGoals,
    required List<String> recommendations,
    required double? currentWeightKg,
    required String notes,
  }) {
    return switch (_step) {
      0 => _buildGuidedWelcomeStep(),
      1 => _buildGuidedGoalStep(),
      2 => _buildGuidedTrainingHistoryStep(),
      3 => _buildGuidedKnowledgeStep(),
      4 => _buildGuidedScheduleStep(),
      5 => _buildGuidedMetricsStep(),
      6 => _buildGuidedHealthAndNutritionStep(),
      _ => _buildGuidedSummaryStep(
        recommendedGoals: recommendedGoals,
        recommendations: recommendations,
        currentWeightKg: currentWeightKg,
        notes: notes,
      ),
    };
  }

  Widget _buildGuidedWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _appHeroGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _appPrimary.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Comencemos tu evaluación inicial, ${widget.user.firstName}.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Te haré pocas preguntas para organizar tu objetivo, disponibilidad, historial y consideraciones clínicas antes de sugerirte una rutina.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildGuidedHighlight(
                    icon: Icons.flag_circle_outlined,
                    label: 'Objetivo',
                  ),
                  _buildGuidedHighlight(
                    icon: Icons.schedule_rounded,
                    label: 'Horarios',
                  ),
                  _buildGuidedHighlight(
                    icon: Icons.health_and_safety_outlined,
                    label: 'Salud',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildGuidedSurveyIntroCard(
          icon: Icons.flag_circle_outlined,
          title: 'Qué definiremos hoy',
          description:
              'Objetivo, experiencia, frecuencia, horarios, datos físicos, salud y preferencias nutricionales.',
        ),
        const SizedBox(height: 12),
        _buildGuidedSurveyIntroCard(
          icon: Icons.tips_and_updates_outlined,
          title: 'Qué recibirás al terminar',
          description:
              'Una configuración inicial de calorías, hidratación, frecuencia de entrenamiento y recomendaciones personalizadas.',
        ),
      ],
    );
  }

  Widget _buildGuidedHighlight({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedFormStep({
    required IconData icon,
    required String eyebrow,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _appSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _appOutline),
        boxShadow: const [
          BoxShadow(color: _appShadow, blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _appPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _appPrimaryDark),
          ),
          const SizedBox(height: 16),
          Text(
            eyebrow,
            style: const TextStyle(
              color: _appPrimaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: _appText,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: _appMuted, height: 1.45),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _buildGuidedSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _appText,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildGuidedGoalStep() {
    return _buildGuidedFormStep(
      icon: Icons.flag_circle_outlined,
      eyebrow: 'Enfoque del plan',
      title: 'Mi objetivo principal es:',
      description:
          'Selecciona el resultado que quieres priorizar al comenzar tu plan.',
      child: Column(
        children: [
          ...FitnessGoalType.values.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGuidedChoiceCard(
                title: goal.label,
                subtitle: switch (goal) {
                  FitnessGoalType.loseFat =>
                    'Enfoque en déficit calórico controlado, adherencia y gasto energético sostenible.',
                  FitnessGoalType.gainMuscle =>
                    'Prioriza sobrecarga progresiva, recuperación y soporte proteico.',
                  FitnessGoalType.maintain =>
                    'Busca estabilidad corporal, salud general y continuidad de hábitos.',
                  FitnessGoalType.performance =>
                    'Orienta el trabajo hacia condición física, capacidad aeróbica y rendimiento.',
                },
                selected: _profile.goal == goal,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(goal: goal);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedTrainingHistoryStep() {
    return _buildGuidedFormStep(
      icon: Icons.history_rounded,
      eyebrow: 'Punto de partida',
      title: 'Durante los últimos 4 meses:',
      description:
          'Esto nos ayuda a decidir el punto de partida y el volumen de entrenamiento inicial.',
      child: Column(
        children: [
          ...TrainingHistory.values.map(
            (history) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGuidedChoiceCard(
                title: history.label,
                subtitle: switch (history) {
                  TrainingHistory.none =>
                    'Sin trabajo estructurado reciente. Conviene empezar con carga progresiva y técnica básica.',
                  TrainingHistory.onceWeekly =>
                    'Base ligera de entrenamiento. Puede iniciarse con frecuencia moderada y control de fatiga.',
                  TrainingHistory.twoToThreeWeekly =>
                    'Buen punto de entrada para una rutina regular y progresión sostenida.',
                  TrainingHistory.fourPlusWeekly =>
                    'Historial consistente. Se puede proponer una carga inicial más completa.',
                },
                selected: _profile.trainingHistory == history,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(trainingHistory: history);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedKnowledgeStep() {
    return _buildGuidedFormStep(
      icon: Icons.school_outlined,
      eyebrow: 'Experiencia y entorno',
      title: 'Evaluando tu conocimiento sobre entrenamiento:',
      description:
          'También necesito saber dónde entrenas con mayor frecuencia para ajustar el equipamiento sugerido.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...TrainingExperience.values.map(
            (experience) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGuidedChoiceCard(
                title: experience.label,
                subtitle: switch (experience) {
                  TrainingExperience.beginner =>
                    'Necesito una guía completa de técnica, estructura y progresión.',
                  TrainingExperience.intermediate =>
                    'Conozco los patrones principales y puedo seguir una rutina con poca supervisión.',
                  TrainingExperience.advanced =>
                    'Tengo autonomía técnica y tolero programaciones más exigentes.',
                },
                selected: _profile.experience == experience,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(experience: experience);
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildGuidedSectionLabel('¿Dónde entrenas la mayoría de las veces?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: EquipmentAccess.values
                .map(
                  (equipment) => _buildGuidedSelectableChip(
                    label: equipment.label,
                    selected: _profile.equipment == equipment,
                    onTap: () {
                      setState(() {
                        _profile = _profile.copyWith(equipment: equipment);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedScheduleStep() {
    return _buildGuidedFormStep(
      icon: Icons.calendar_month_outlined,
      eyebrow: 'Frecuencia y horarios',
      title: 'Planifiquemos tu frecuencia y horario:',
      description:
          'Con esto puedo sugerirte una rutina que sí encaje con tu semana real.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidedSectionLabel(
            '¿Cuántas sesiones puedes sostener por semana?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              6,
              (index) => _buildGuidedSelectableChip(
                label: index == 0 ? '1 sesión' : '${index + 1} sesiones',
                selected: _profile.daysPerWeek == index + 1,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(daysPerWeek: index + 1);
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildGuidedSectionLabel(
            '¿En qué franja piensas entrenar la mayoría de los días?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RoutineTimeWindow.values
                .map(
                  (window) => _buildGuidedSelectableChip(
                    label: window.label,
                    selected: _profile.workoutWindow == window,
                    onTap: () {
                      setState(() {
                        _profile = _profile.copyWith(workoutWindow: window);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedMetricsStep() {
    return _buildGuidedFormStep(
      icon: Icons.straighten_rounded,
      eyebrow: 'Datos base',
      title: '¿Cuál es tu peso, altura y edad actuales?',
      description:
          'Son datos opcionales, pero mejoran mucho la precisión de las metas iniciales.',
      child: Column(
        children: [
          _buildGuidedSurveyTextField(
            controller: _currentWeightController,
            label: 'Peso actual (kg)',
            hint: 'Ej. 72.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _optionalPositiveDecimalValidator,
          ),
          const SizedBox(height: 12),
          _buildGuidedSurveyTextField(
            controller: _targetWeightController,
            label: 'Peso objetivo (kg)',
            hint: 'Ej. 68.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _optionalPositiveDecimalValidator,
          ),
          const SizedBox(height: 12),
          _buildGuidedSurveyTextField(
            controller: _heightController,
            label: 'Altura (cm)',
            hint: 'Ej. 175',
            keyboardType: TextInputType.number,
            validator: _optionalHeightValidator,
          ),
          const SizedBox(height: 12),
          _buildGuidedSurveyTextField(
            controller: _ageController,
            label: 'Edad',
            hint: 'Ej. 28',
            keyboardType: TextInputType.number,
            validator: _optionalAgeValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedHealthAndNutritionStep() {
    return _buildGuidedFormStep(
      icon: Icons.favorite_border_rounded,
      eyebrow: 'Salud y nutrición',
      title: 'Salud, nutrición y horarios de comida:',
      description:
          'Aquí registramos condiciones de salud, alergias y cómo prefieres organizar tu alimentación.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidedSectionLabel(
            '¿Hay alguna condición física o de salud a considerar?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _healthFlagOptions
                .map(
                  (option) => _buildGuidedSelectableChip(
                    label: option,
                    selected: _healthFlags.contains(option),
                    onTap: () => _toggleHealthFlag(option),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          _buildGuidedSurveyTextField(
            controller: _allergiesController,
            label: 'Alergias, intolerancias o restricciones clínicas',
            hint: 'Ej. Intolerancia a la lactosa, alergia al maní.',
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildGuidedSurveyTextField(
            controller: _notesController,
            label: 'Observaciones adicionales',
            hint:
                'Ej. Molestia lumbar, preferencia por rutinas cortas o ejercicios a evitar.',
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          _buildGuidedSectionLabel('Estilo de alimentación sugerido'),
          const SizedBox(height: 12),
          ...DietStyle.values.map(
            (dietStyle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGuidedChoiceCard(
                title: dietStyle.label,
                subtitle: switch (dietStyle) {
                  DietStyle.balanced =>
                    'Distribución general equilibrada entre carbohidratos, proteína y grasas.',
                  DietStyle.highProtein =>
                    'Mayor soporte proteico para recuperación y preservación de masa muscular.',
                  DietStyle.lowCarb =>
                    'Control superior de carbohidratos para mejorar adherencia o control glucémico.',
                  DietStyle.vegetarian =>
                    'Enfoque sin carnes, cuidando la calidad proteica y micronutrientes clave.',
                },
                selected: _profile.dietStyle == dietStyle,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(dietStyle: dietStyle);
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildGuidedSectionLabel('¿Cuántas comidas sueles hacer al día?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              5,
              (index) => _buildGuidedSelectableChip(
                label: '${index + 2} comidas',
                selected: _profile.mealsPerDay == index + 2,
                onTap: () {
                  setState(() {
                    _profile = _profile.copyWith(mealsPerDay: index + 2);
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildGuidedSectionLabel(
            '¿En qué horario cae tu comida principal la mayoría de los días?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RoutineTimeWindow.values
                .map(
                  (window) => _buildGuidedSelectableChip(
                    label: window.label,
                    selected: _profile.mealWindow == window,
                    onTap: () {
                      setState(() {
                        _profile = _profile.copyWith(mealWindow: window);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedSummaryStep({
    required FitnessGoals recommendedGoals,
    required List<String> recommendations,
    required double? currentWeightKg,
    required String notes,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _appSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _appOutline),
        boxShadow: const [
          BoxShadow(color: _appShadow, blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tus respuestas',
            style: TextStyle(
              color: _appText,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Este es el perfil base con el que quedará configurado tu plan al entrar a la app.',
            style: TextStyle(color: _appMuted, height: 1.45),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildGuidedGoalPreviewChip(
                icon: Icons.local_fire_department_outlined,
                label: '${recommendedGoals.calorieGoal} kcal/día',
              ),
              _buildGuidedGoalPreviewChip(
                icon: Icons.water_drop_outlined,
                label: '${recommendedGoals.waterGoalMl} ml/día',
              ),
              _buildGuidedGoalPreviewChip(
                icon: Icons.fitness_center_outlined,
                label: '${recommendedGoals.workoutGoalMinutes} min/sesión',
              ),
              _buildGuidedGoalPreviewChip(
                icon: Icons.monitor_weight_outlined,
                label:
                    '${recommendedGoals.targetWeightKg.toStringAsFixed(1)} kg objetivo',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGuidedSummaryRow(label: 'Objetivo', value: _profile.goal.label),
          _buildGuidedSummaryRow(
            label: 'Historial reciente',
            value: _profile.trainingHistory.label,
          ),
          _buildGuidedSummaryRow(
            label: 'Experiencia declarada',
            value: _profile.experience.label,
          ),
          _buildGuidedSummaryRow(
            label: 'Entorno principal',
            value: _profile.equipment.label,
          ),
          _buildGuidedSummaryRow(
            label: 'Frecuencia semanal',
            value: '${_profile.daysPerWeek} sesiones por semana',
          ),
          _buildGuidedSummaryRow(
            label: 'Horario de entrenamiento',
            value: _profile.workoutWindow.label,
          ),
          _buildGuidedSummaryRow(
            label: 'Peso y altura',
            value: _formatBodyMetricsSummary(
              currentWeightKg: currentWeightKg,
              targetWeightKg: _parseOptionalDouble(
                _targetWeightController.text,
              ),
              heightCm: _parseOptionalDouble(_heightController.text),
              age: _parseOptionalInt(_ageController.text),
            ),
          ),
          _buildGuidedSummaryRow(
            label: 'Salud y condición física',
            value: _healthFlagsSummary(),
          ),
          _buildGuidedSummaryRow(
            label: 'Plan nutricional',
            value:
                '${_profile.mealsPerDay} comidas al día, ${_profile.dietStyle.label.toLowerCase()}',
          ),
          _buildGuidedSummaryRow(
            label: 'Franja de comida principal',
            value: _profile.mealWindow.label,
          ),
          if (_allergiesController.text.trim().isNotEmpty)
            _buildGuidedSummaryRow(
              label: 'Alergias o restricciones',
              value: _allergiesController.text.trim(),
            ),
          if (notes.isNotEmpty)
            _buildGuidedSummaryRow(label: 'Observaciones', value: notes),
          const SizedBox(height: 18),
          const Text(
            'Lo que te sugeriremos desde el día 1',
            style: TextStyle(
              color: _appText,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map(_buildGuidedRecommendationTile),
        ],
      ),
    );
  }

  Widget _buildGuidedSurveyIntroCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _appOutline),
        boxShadow: const [
          BoxShadow(color: _appShadow, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _appPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _appPrimaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _appText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: _appMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedChoiceCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? _appPrimary.withValues(alpha: 0.08) : _appSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? _appPrimary : _appOutline,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: _appShadow,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _appText,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _appMuted, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? _appPrimaryDark : _appMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedSelectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _appPrimary : _appSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _appPrimary : _appOutline),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _appPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedSurveyTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: _appText),
      cursorColor: _appPrimary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _appMuted),
        hintStyle: TextStyle(color: _appMuted.withValues(alpha: 0.7)),
        filled: true,
        fillColor: _appSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _appOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _appOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _appPrimary, width: 1.4),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildGuidedSummaryRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 162,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _appMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: _appText, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedGoalPreviewChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _appPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _appPrimaryDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _appText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedRecommendationTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _appPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 15, color: _appPrimaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _appText, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedBottomActionBar({
    required FitnessGoals recommendedGoals,
    required double? currentWeightKg,
    required double? targetWeightKg,
  }) {
    final isSummary = _step == _finalSurveyStep;
    final primaryLabel = switch (_step) {
      0 => 'Empezar evaluación',
      _finalSurveyStep => 'Confirmar y crear mi plan',
      _ => 'Siguiente',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: _appSurface.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: _appOutline)),
        boxShadow: const [
          BoxShadow(color: _appShadow, blurRadius: 18, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _appPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              onPressed: _saving
                  ? null
                  : isSummary
                  ? () => _submit(
                      recommendedGoals: recommendedGoals,
                      currentWeightKg: currentWeightKg,
                      targetWeightKg: targetWeightKg,
                    )
                  : _goNext,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(primaryLabel),
            ),
          ),
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        if (isSummary) {
                          setState(() {
                            _step = 1;
                          });
                          return;
                        }
                        _goBack();
                      },
                child: Text(
                  isSummary ? 'Cambiar respuestas' : 'Atrás',
                  style: const TextStyle(
                    color: _appPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: _step == 0
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _step == 0
                      ? 'Evaluación inicial'
                      : 'Paso $_step de $_finalSurveyStep',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: (_step + 1) / (_finalSurveyStep + 1),
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _surveyAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: _surveyAccent,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepContent({
    required FitnessGoals recommendedGoals,
    required List<String> recommendations,
    required double? currentWeightKg,
    required String notes,
  }) {
    final stepWidget = switch (_step) {
      0 => _buildWelcomeStep(),
      1 => _buildGoalStep(),
      2 => _buildTrainingHistoryStep(),
      3 => _buildKnowledgeStep(),
      4 => _buildScheduleStep(),
      5 => _buildMetricsStep(),
      6 => _buildHealthAndNutritionStep(),
      _ => _buildSummaryStep(
        recommendedGoals: recommendedGoals,
        recommendations: recommendations,
        currentWeightKg: currentWeightKg,
        notes: notes,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_step > 0) ...[
          _buildReferenceFrame(
            assetPath:
                _onboardingSurveyAssetPaths[math.min(
                  (_step * 2) - 1,
                  _onboardingSurveyAssetPaths.length - 1,
                )],
          ),
          const SizedBox(height: 24),
        ],
        stepWidget,
      ],
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comencemos tu evaluación inicial, ${widget.user.firstName}.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Te haré pocas preguntas para organizar tu objetivo, disponibilidad, historial y consideraciones clínicas antes de sugerirte una rutina.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 16,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Vista previa de la evaluación',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _onboardingSurveyAssetPaths.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 102,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    _onboardingSurveyAssetPaths[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        _buildSurveyIntroCard(
          icon: Icons.flag_circle_outlined,
          title: 'Qué definiremos hoy',
          description:
              'Objetivo, experiencia, frecuencia, horarios, datos físicos, salud y preferencias nutricionales.',
        ),
        const SizedBox(height: 12),
        _buildSurveyIntroCard(
          icon: Icons.tips_and_updates_outlined,
          title: 'Qué recibirás al terminar',
          description:
              'Una configuración inicial de calorías, hidratación, frecuencia de entrenamiento y recomendaciones personalizadas.',
        ),
      ],
    );
  }

  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mi objetivo principal es:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Selecciona el resultado que quieres priorizar al comenzar tu plan.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        ...FitnessGoalType.values.map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              title: goal.label,
              subtitle: switch (goal) {
                FitnessGoalType.loseFat =>
                  'Enfoque en déficit calórico controlado, adherencia y gasto energético sostenible.',
                FitnessGoalType.gainMuscle =>
                  'Prioriza sobrecarga progresiva, recuperación y soporte proteico.',
                FitnessGoalType.maintain =>
                  'Busca estabilidad corporal, salud general y continuidad de hábitos.',
                FitnessGoalType.performance =>
                  'Orienta el trabajo hacia condición física, capacidad aeróbica y rendimiento.',
              },
              selected: _profile.goal == goal,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(goal: goal);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingHistoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durante los últimos 4 meses:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Esto nos ayuda a decidir el punto de partida y el volumen de entrenamiento inicial.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        ...TrainingHistory.values.map(
          (history) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              title: history.label,
              subtitle: switch (history) {
                TrainingHistory.none =>
                  'Sin trabajo estructurado reciente. Conviene empezar con carga progresiva y técnica básica.',
                TrainingHistory.onceWeekly =>
                  'Base ligera de entrenamiento. Puede iniciarse con frecuencia moderada y control de fatiga.',
                TrainingHistory.twoToThreeWeekly =>
                  'Buen punto de entrada para una rutina regular y progresión sostenida.',
                TrainingHistory.fourPlusWeekly =>
                  'Historial consistente. Se puede proponer una carga inicial más completa.',
              },
              selected: _profile.trainingHistory == history,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(trainingHistory: history);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evaluando tu conocimiento sobre entrenamiento:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'También necesito saber dónde entrenas con mayor frecuencia para ajustar el equipamiento sugerido.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        ...TrainingExperience.values.map(
          (experience) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              title: experience.label,
              subtitle: switch (experience) {
                TrainingExperience.beginner =>
                  'Necesito una guía completa de técnica, estructura y progresión.',
                TrainingExperience.intermediate =>
                  'Conozco los patrones principales y puedo seguir una rutina con poca supervisión.',
                TrainingExperience.advanced =>
                  'Tengo autonomía técnica y tolero programaciones más exigentes.',
              },
              selected: _profile.experience == experience,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(experience: experience);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '¿Dónde entrenas la mayoría de las veces?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: EquipmentAccess.values
              .map(
                (equipment) => _buildSelectableChip(
                  label: equipment.label,
                  selected: _profile.equipment == equipment,
                  onTap: () {
                    setState(() {
                      _profile = _profile.copyWith(equipment: equipment);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planifiquemos tu frecuencia y horario:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Con esto puedo sugerirte una rutina que sí encaje con tu semana real.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¿Cuántas sesiones puedes sostener por semana?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            6,
            (index) => _buildSelectableChip(
              label: index == 0 ? '1 sesión' : '${index + 1} sesiones',
              selected: _profile.daysPerWeek == index + 1,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(daysPerWeek: index + 1);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          '¿En qué franja piensas entrenar la mayoría de los días?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: RoutineTimeWindow.values
              .map(
                (window) => _buildSelectableChip(
                  label: window.label,
                  selected: _profile.workoutWindow == window,
                  onTap: () {
                    setState(() {
                      _profile = _profile.copyWith(workoutWindow: window);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMetricsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cuál es tu peso, altura y edad actuales?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Son datos opcionales, pero mejoran mucho la precisión de las metas iniciales.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        _buildSurveyTextField(
          controller: _currentWeightController,
          label: 'Peso actual (kg)',
          hint: 'Ej. 72.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _optionalPositiveDecimalValidator,
        ),
        const SizedBox(height: 12),
        _buildSurveyTextField(
          controller: _targetWeightController,
          label: 'Peso objetivo (kg)',
          hint: 'Ej. 68.0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _optionalPositiveDecimalValidator,
        ),
        const SizedBox(height: 12),
        _buildSurveyTextField(
          controller: _heightController,
          label: 'Altura (cm)',
          hint: 'Ej. 175',
          keyboardType: TextInputType.number,
          validator: _optionalHeightValidator,
        ),
        const SizedBox(height: 12),
        _buildSurveyTextField(
          controller: _ageController,
          label: 'Edad',
          hint: 'Ej. 28',
          keyboardType: TextInputType.number,
          validator: _optionalAgeValidator,
        ),
      ],
    );
  }

  Widget _buildHealthAndNutritionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salud, nutrición y horarios de comida:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Aquí registramos condiciones de salud, alergias y cómo prefieres organizar tu alimentación.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¿Hay alguna condición física o de salud a considerar?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _healthFlagOptions
              .map(
                (option) => _buildSelectableChip(
                  label: option,
                  selected: _healthFlags.contains(option),
                  onTap: () => _toggleHealthFlag(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        _buildSurveyTextField(
          controller: _allergiesController,
          label: 'Alergias, intolerancias o restricciones clínicas',
          hint: 'Ej. Intolerancia a la lactosa, alergia al maní.',
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _buildSurveyTextField(
          controller: _notesController,
          label: 'Observaciones adicionales',
          hint:
              'Ej. Molestia lumbar, preferencia por rutinas cortas o ejercicios a evitar.',
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: 22),
        const Text(
          'Estilo de alimentación sugerido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...DietStyle.values.map(
          (dietStyle) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(
              title: dietStyle.label,
              subtitle: switch (dietStyle) {
                DietStyle.balanced =>
                  'Distribución general equilibrada entre carbohidratos, proteína y grasas.',
                DietStyle.highProtein =>
                  'Mayor soporte proteico para recuperación y preservación de masa muscular.',
                DietStyle.lowCarb =>
                  'Control superior de carbohidratos para mejorar adherencia o control glucémico.',
                DietStyle.vegetarian =>
                  'Enfoque sin carnes, cuidando la calidad proteica y micronutrientes clave.',
              },
              selected: _profile.dietStyle == dietStyle,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(dietStyle: dietStyle);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '¿Cuántas comidas sueles hacer al día?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            5,
            (index) => _buildSelectableChip(
              label: '${index + 2} comidas',
              selected: _profile.mealsPerDay == index + 2,
              onTap: () {
                setState(() {
                  _profile = _profile.copyWith(mealsPerDay: index + 2);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          '¿En qué horario cae tu comida principal la mayoría de los días?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: RoutineTimeWindow.values
              .map(
                (window) => _buildSelectableChip(
                  label: window.label,
                  selected: _profile.mealWindow == window,
                  onTap: () {
                    setState(() {
                      _profile = _profile.copyWith(mealWindow: window);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryStep({
    required FitnessGoals recommendedGoals,
    required List<String> recommendations,
    required double? currentWeightKg,
    required String notes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surveyCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tus respuestas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Este es el perfil base con el que quedará configurado tu plan al entrar a la app.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildGoalPreviewChip(
                icon: Icons.local_fire_department_outlined,
                label: '${recommendedGoals.calorieGoal} kcal/día',
              ),
              _buildGoalPreviewChip(
                icon: Icons.water_drop_outlined,
                label: '${recommendedGoals.waterGoalMl} ml/día',
              ),
              _buildGoalPreviewChip(
                icon: Icons.fitness_center_outlined,
                label: '${recommendedGoals.workoutGoalMinutes} min/sesión',
              ),
              _buildGoalPreviewChip(
                icon: Icons.monitor_weight_outlined,
                label:
                    '${recommendedGoals.targetWeightKg.toStringAsFixed(1)} kg objetivo',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(label: 'Objetivo', value: _profile.goal.label),
          _buildSummaryRow(
            label: 'Historial reciente',
            value: _profile.trainingHistory.label,
          ),
          _buildSummaryRow(
            label: 'Experiencia declarada',
            value: _profile.experience.label,
          ),
          _buildSummaryRow(
            label: 'Entorno principal',
            value: _profile.equipment.label,
          ),
          _buildSummaryRow(
            label: 'Frecuencia semanal',
            value: '${_profile.daysPerWeek} sesiones por semana',
          ),
          _buildSummaryRow(
            label: 'Horario de entrenamiento',
            value: _profile.workoutWindow.label,
          ),
          _buildSummaryRow(
            label: 'Peso y altura',
            value: _formatBodyMetricsSummary(
              currentWeightKg: currentWeightKg,
              targetWeightKg: _parseOptionalDouble(
                _targetWeightController.text,
              ),
              heightCm: _parseOptionalDouble(_heightController.text),
              age: _parseOptionalInt(_ageController.text),
            ),
          ),
          _buildSummaryRow(
            label: 'Salud y condición física',
            value: _healthFlagsSummary(),
          ),
          _buildSummaryRow(
            label: 'Plan nutricional',
            value:
                '${_profile.mealsPerDay} comidas al día, ${_profile.dietStyle.label.toLowerCase()}',
          ),
          _buildSummaryRow(
            label: 'Franja de comida principal',
            value: _profile.mealWindow.label,
          ),
          if (_allergiesController.text.trim().isNotEmpty)
            _buildSummaryRow(
              label: 'Alergias o restricciones',
              value: _allergiesController.text.trim(),
            ),
          if (notes.isNotEmpty)
            _buildSummaryRow(label: 'Observaciones', value: notes),
          const SizedBox(height: 18),
          const Text(
            'Lo que te sugeriremos desde el día 1',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map(_buildRecommendationTile),
        ],
      ),
    );
  }

  Widget _buildReferenceFrame({required String assetPath}) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: _surveyCardSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildSurveyIntroCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surveyCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surveyAccent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _surveyAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF242424) : _surveyCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? _surveyAccent : _surveyStroke,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? _surveyAccent : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _surveyAccent : _surveyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _surveyAccent : _surveyStroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: _surveyAccent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38)),
        filled: true,
        fillColor: _surveyCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _surveyStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _surveyStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _surveyAccent, width: 1.4),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 162,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.94),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPreviewChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surveyAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _surveyAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _surveyAccent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 15, color: _surveyAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildBottomActionBar({
    required FitnessGoals recommendedGoals,
    required double? currentWeightKg,
    required double? targetWeightKg,
  }) {
    final isSummary = _step == _finalSurveyStep;
    final primaryLabel = switch (_step) {
      0 => 'Empezar evaluación',
      _finalSurveyStep => 'Confirmar y crear mi plan',
      _ => 'Siguiente',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: _surveyDarkBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _surveyAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              onPressed: _saving
                  ? null
                  : isSummary
                  ? () => _submit(
                      recommendedGoals: recommendedGoals,
                      currentWeightKg: currentWeightKg,
                      targetWeightKg: targetWeightKg,
                    )
                  : _goNext,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(primaryLabel),
            ),
          ),
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        if (isSummary) {
                          setState(() {
                            _step = 1;
                          });
                          return;
                        }
                        _goBack();
                      },
                child: Text(
                  isSummary ? 'Cambiar respuestas' : 'Atrás',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _seedHealthFlags() {
    final lowerNotes = _profile.notes.toLowerCase();
    for (final option in _healthFlagOptions) {
      if (option == 'No poseo') {
        continue;
      }
      if (lowerNotes.contains(option.toLowerCase())) {
        _healthFlags.add(option);
      }
    }
    if (_healthFlags.isEmpty && _profile.notes.trim().isEmpty) {
      _healthFlags.add('No poseo');
    }
  }

  String _composeSurveyNotes() {
    final manualNotes = _notesController.text.trim();
    final activeFlags = _healthFlags
        .where((item) => item != 'No poseo')
        .join(', ');

    if (activeFlags.isEmpty) {
      return manualNotes;
    }

    if (manualNotes.isEmpty) {
      return 'Condiciones reportadas: $activeFlags.';
    }

    return 'Condiciones reportadas: $activeFlags. $manualNotes';
  }

  void _goBack() {
    if (_step == 0) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _step -= 1;
    });
  }

  void _goNext() {
    if (!_validateCurrentStep()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _step = math.min(_step + 1, _finalSurveyStep);
    });
  }

  bool _validateCurrentStep() {
    if (_step != 5) {
      return true;
    }

    final validators = <String?>[
      _optionalAgeValidator(_ageController.text),
      _optionalHeightValidator(_heightController.text),
      _optionalPositiveDecimalValidator(_currentWeightController.text),
      _optionalPositiveDecimalValidator(_targetWeightController.text),
    ].whereType<String>().toList();

    if (validators.isEmpty) {
      return true;
    }

    _showAuthSnackBar(context, validators.first, success: false);
    return false;
  }

  void _toggleHealthFlag(String option) {
    setState(() {
      if (option == 'No poseo') {
        _healthFlags
          ..clear()
          ..add(option);
        return;
      }

      _healthFlags.remove('No poseo');
      if (_healthFlags.contains(option)) {
        _healthFlags.remove(option);
      } else {
        _healthFlags.add(option);
      }
    });
  }

  String _healthFlagsSummary() {
    final activeFlags = _healthFlags
        .where((item) => item != 'No poseo')
        .toList(growable: false);
    if (activeFlags.isEmpty) {
      return 'No reporta condiciones relevantes';
    }
    return activeFlags.join(', ');
  }

  String _formatBodyMetricsSummary({
    required double? currentWeightKg,
    required double? targetWeightKg,
    required double? heightCm,
    required int? age,
  }) {
    final parts = <String>[];
    if (currentWeightKg != null) {
      parts.add('${currentWeightKg.toStringAsFixed(1)} kg actuales');
    }
    if (targetWeightKg != null) {
      parts.add('${targetWeightKg.toStringAsFixed(1)} kg objetivo');
    }
    if (heightCm != null) {
      parts.add('${heightCm.toStringAsFixed(0)} cm');
    }
    if (age != null) {
      parts.add('$age años');
    }
    if (parts.isEmpty) {
      return 'Sin métricas base registradas todavía';
    }
    return parts.join(' · ');
  }

  Future<void> _submit({
    required FitnessGoals recommendedGoals,
    required double? currentWeightKg,
    required double? targetWeightKg,
  }) async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final result = await widget.authStore.updateCurrentUserProfile(
      name: widget.user.name,
      age: _parseOptionalInt(_ageController.text),
      heightCm: _parseOptionalDouble(_heightController.text),
    );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() {
        _saving = false;
      });
      _showAuthSnackBar(context, result.message, success: false);
      return;
    }

    final resolvedGoals = recommendedGoals.copyWith(
      targetWeightKg:
          targetWeightKg ?? currentWeightKg ?? recommendedGoals.targetWeightKg,
    );

    await widget.store.completeOnboarding(
      profile: _profile.copyWith(
        allergies: _allergiesController.text.trim(),
        notes: _composeSurveyNotes(),
      ),
      goals: resolvedGoals,
      currentWeightKg: currentWeightKg,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });
    _showAuthSnackBar(
      context,
      'Perfil listo. Ya puedes empezar con recomendaciones personalizadas.',
      success: true,
    );
  }

  int? _parseOptionalInt(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return int.tryParse(normalized);
  }

  double? _parseOptionalDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }
}

FitnessGoals _buildRecommendedGoals({
  required CoachProfile profile,
  double? currentWeightKg,
  double? targetWeightKg,
  int? age,
  double? heightCm,
}) {
  final referenceWeight = currentWeightKg ?? targetWeightKg ?? 70;
  var calorieGoal = (referenceWeight * 30).round();
  calorieGoal += switch (profile.goal) {
    FitnessGoalType.loseFat => -300,
    FitnessGoalType.gainMuscle => 250,
    FitnessGoalType.performance => 120,
    FitnessGoalType.maintain => 0,
  };

  if (profile.experience == TrainingExperience.advanced) {
    calorieGoal += 120;
  } else if (profile.experience == TrainingExperience.intermediate) {
    calorieGoal += 60;
  }

  if (age != null && age >= 45) {
    calorieGoal -= 60;
  }

  if (heightCm != null && heightCm >= 185) {
    calorieGoal += 80;
  }

  calorieGoal = _clampInt(calorieGoal, 1500, 3800);

  var waterGoalMl = ((referenceWeight * 35) / 250).round() * 250;
  if (profile.daysPerWeek >= 5) {
    waterGoalMl += 250;
  }
  waterGoalMl = _clampInt(waterGoalMl, 2000, 4200);

  var workoutGoalMinutes = 20 + (profile.daysPerWeek * 8);
  if (profile.goal == FitnessGoalType.performance) {
    workoutGoalMinutes += 10;
  } else if (profile.goal == FitnessGoalType.gainMuscle) {
    workoutGoalMinutes += 5;
  }
  workoutGoalMinutes += switch (profile.trainingHistory) {
    TrainingHistory.none => -5,
    TrainingHistory.onceWeekly => 0,
    TrainingHistory.twoToThreeWeekly => 4,
    TrainingHistory.fourPlusWeekly => 8,
  };
  if (profile.experience == TrainingExperience.beginner) {
    workoutGoalMinutes -= 5;
  }
  workoutGoalMinutes = _clampInt(workoutGoalMinutes, 20, 90);

  return FitnessGoals(
    calorieGoal: calorieGoal,
    waterGoalMl: waterGoalMl,
    workoutGoalMinutes: workoutGoalMinutes,
    targetWeightKg: targetWeightKg ?? currentWeightKg ?? 70,
  );
}
