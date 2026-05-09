part of '../main.dart';

// -----------------------------------------------------------------------------
// Onboarding base.
// Flujo inicial para recoger datos del perfil antes del uso habitual.
// -----------------------------------------------------------------------------
class OnboardingSurveyScreen extends StatefulWidget {
  const OnboardingSurveyScreen({
    super.key,
    required this.store,
    required this.authStore,
    required this.user,
  });

  final FitnessStore store;
  final AuthStore authStore;
  final AuthUser user;

  @override
  State<OnboardingSurveyScreen> createState() => _OnboardingSurveyScreenState();
}

class _OnboardingSurveyScreenState extends State<OnboardingSurveyScreen> {
  final _formKey = GlobalKey<FormState>();

  late CoachProfile _profile;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _allergiesController;
  late TextEditingController _notesController;

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
    final notes = _notesController.text.trim();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2FBF8), Color(0xFFF9FCFB), Color(0xFFEAF7F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: _appHeroGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _appPrimary.withValues(alpha: 0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.assignment_turned_in_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Hola, ${widget.user.firstName}.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Completemos tu evaluación inicial.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildOnboardingSection(
                        title: 'Tu objetivo',
                        subtitle:
                            'Definimos el enfoque principal para entreno y alimentacion.',
                        child: Column(
                          children: [
                            _buildSurveyFieldBlock(
                              title: 'Objetivo principal',
                              helper:
                                  'Selecciona el resultado prioritario que debemos perseguir desde el inicio.',
                              child: DropdownButtonFormField<FitnessGoalType>(
                                initialValue: _profile.goal,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  hintText: 'Selecciona una opcion',
                                ),
                                items: FitnessGoalType.values
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _profile = _profile.copyWith(goal: value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            _buildSurveyFieldBlock(
                              title: 'Nivel actual',
                              helper:
                                  'Usamos tu experiencia para ajustar volumen, complejidad técnica y recuperación.',
                              child:
                                  DropdownButtonFormField<TrainingExperience>(
                                    initialValue: _profile.experience,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Selecciona una opcion',
                                    ),
                                    items: TrainingExperience.values
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() {
                                        _profile = _profile.copyWith(
                                          experience: value,
                                        );
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            _buildSurveyFieldBlock(
                              title: 'Dónde entrenas',
                              helper:
                                  'Definimos el entorno principal y el equipamiento disponible para tus rutinas.',
                              child: DropdownButtonFormField<EquipmentAccess>(
                                initialValue: _profile.equipment,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  hintText: 'Selecciona una opcion',
                                ),
                                items: EquipmentAccess.values
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _profile = _profile.copyWith(
                                      equipment: value,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildOnboardingSection(
                        title: 'Tu ritmo',
                        subtitle:
                            'Ajustamos frecuencia de entreno, comidas y estilo de alimentacion.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dias de entreno por semana: ${_profile.daysPerWeek}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: _profile.daysPerWeek.toDouble(),
                              min: 1,
                              max: 6,
                              divisions: 5,
                              label: '${_profile.daysPerWeek} dias',
                              onChanged: (value) {
                                setState(() {
                                  _profile = _profile.copyWith(
                                    daysPerWeek: value.round(),
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<DietStyle>(
                              initialValue: _profile.dietStyle,
                              decoration: const InputDecoration(
                                labelText: 'Estilo alimentario',
                              ),
                              items: DietStyle.values
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _profile = _profile.copyWith(
                                    dietStyle: value,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Comidas por dia: ${_profile.mealsPerDay}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: _profile.mealsPerDay.toDouble(),
                              min: 2,
                              max: 6,
                              divisions: 4,
                              label: '${_profile.mealsPerDay} comidas',
                              onChanged: (value) {
                                setState(() {
                                  _profile = _profile.copyWith(
                                    mealsPerDay: value.round(),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildOnboardingSection(
                        title: 'Datos base',
                        subtitle:
                            'Mientras mas preciso seas, mejores seran las metas recomendadas.',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Edad (opcional)',
                              ),
                              validator: _optionalAgeValidator,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            TextFormField(
                              controller: _heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Estatura en cm (opcional)',
                              ),
                              validator: _optionalHeightValidator,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            TextFormField(
                              controller: _currentWeightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Peso actual en kg (opcional)',
                              ),
                              validator: _optionalPositiveDecimalValidator,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            TextFormField(
                              controller: _targetWeightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Peso objetivo en kg (opcional)',
                              ),
                              validator: _optionalPositiveDecimalValidator,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            TextFormField(
                              controller: _allergiesController,
                              decoration: const InputDecoration(
                                labelText:
                                    'Alergias, intolerancias o restricciones clínicas',
                              ),
                              minLines: 2,
                              maxLines: 3,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: _appFormFieldGap),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText:
                                    'Lesiones, limitaciones o preferencias adicionales',
                              ),
                              minLines: 2,
                              maxLines: 3,
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen de tu plan inicial',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Asi quedarian tus parametros recomendados y el enfoque que recibiras al entrar.',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.62),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildGoalPreviewChip(
                                    icon: Icons.local_fire_department_outlined,
                                    label:
                                        '${recommendedGoals.calorieGoal} kcal/dia',
                                  ),
                                  _buildGoalPreviewChip(
                                    icon: Icons.water_drop_outlined,
                                    label:
                                        '${recommendedGoals.waterGoalMl} ml/dia',
                                  ),
                                  _buildGoalPreviewChip(
                                    icon: Icons.fitness_center_outlined,
                                    label:
                                        '${recommendedGoals.workoutGoalMinutes} min/dia',
                                  ),
                                  _buildGoalPreviewChip(
                                    icon: Icons.monitor_weight_outlined,
                                    label:
                                        '${recommendedGoals.targetWeightKg.toStringAsFixed(1)} kg objetivo',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow(
                                label: 'Objetivo principal',
                                value: _profile.goal.label,
                              ),
                              _buildSummaryRow(
                                label: 'Nivel operativo',
                                value: _profile.experience.label,
                              ),
                              _buildSummaryRow(
                                label: 'Entorno de entrenamiento',
                                value: _profile.equipment.label,
                              ),
                              _buildSummaryRow(
                                label: 'Frecuencia sugerida',
                                value:
                                    '${_profile.daysPerWeek} sesiones de ${recommendedGoals.workoutGoalMinutes} min por semana',
                              ),
                              _buildSummaryRow(
                                label: 'Plan de comidas',
                                value:
                                    '${_profile.mealsPerDay} ingestas al dia en ${_profile.dietStyle.label.toLowerCase()}',
                              ),
                              if (allergies.isNotEmpty)
                                _buildSummaryRow(
                                  label: 'Restricciones alimentarias',
                                  value: allergies,
                                ),
                              if (notes.isNotEmpty)
                                _buildSummaryRow(
                                  label: 'Consideraciones adicionales',
                                  value: notes,
                                ),
                              const SizedBox(height: 10),
                              const Text(
                                'Lo que te sugeriremos desde el día 1',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...recommendations.map(_buildRecommendationTile),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving
                              ? null
                              : () => _submit(
                                  recommendedGoals: recommendedGoals,
                                  currentWeightKg: currentWeight,
                                  targetWeightKg: targetWeight,
                                ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar encuesta y entrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
            ),
            const SizedBox(height: _appFormSectionGap),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyFieldBlock({
    required String title,
    required String helper,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.62),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(height: 1.4))),
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
              color: Color(0xFF0F172A),
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
              color: _appPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 15, color: _appPrimaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }

  Future<void> _submit({
    required FitnessGoals recommendedGoals,
    required double? currentWeightKg,
    required double? targetWeightKg,
  }) async {
    if (!_formKey.currentState!.validate()) {
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
        notes: _notesController.text.trim(),
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
