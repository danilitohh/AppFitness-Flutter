part of '../main.dart';

// -----------------------------------------------------------------------------
// Modales de captura y edicion.
// Hojas inferiores para registrar entrenos, comidas, peso, metas y coach.
// -----------------------------------------------------------------------------
/// Modal para registrar una comida y sus macros.
Future<void> showMealSheet(BuildContext context, FitnessStore store) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final caloriesController = TextEditingController(text: '500');
  final proteinController = TextEditingController(text: '25');
  final carbsController = TextEditingController(text: '50');
  final fatsController = TextEditingController(text: '15');
  var selectedType = MealType.lunch;
  var selectedDateTime = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _DisposeControllersOnUnmount(
        controllers: [
          nameController,
          caloriesController,
          proteinController,
          carbsController,
          fatsController,
        ],
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nueva comida',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MealType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: MealType.values
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
                          setSheetState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del plato',
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Calorías',
                              ),
                              validator: _positiveIntValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: proteinController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Proteína (g)',
                              ),
                              validator: _positiveIntValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: carbsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Carbos (g)',
                              ),
                              validator: _positiveIntValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: fatsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Grasas (g)',
                              ),
                              validator: _positiveIntValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fecha'),
                        subtitle: Text(
                          DateFormat('d MMM yyyy').format(selectedDateTime),
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked == null) {
                            return;
                          }
                          setSheetState(() {
                            selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              selectedDateTime.hour,
                              selectedDateTime.minute,
                            );
                          });
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hora'),
                        subtitle: Text(
                          _formatTimeOfDayLabel(
                            TimeOfDay.fromDateTime(selectedDateTime),
                          ),
                        ),
                        trailing: const Icon(Icons.schedule),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              selectedDateTime,
                            ),
                          );
                          if (picked == null) {
                            return;
                          }
                          setSheetState(() {
                            selectedDateTime = DateTime(
                              selectedDateTime.year,
                              selectedDateTime.month,
                              selectedDateTime.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            store.addMeal(
                              type: selectedType,
                              name: nameController.text.trim(),
                              calories: int.parse(
                                caloriesController.text.trim(),
                              ),
                              protein: int.parse(proteinController.text.trim()),
                              carbs: int.parse(carbsController.text.trim()),
                              fats: int.parse(fatsController.text.trim()),
                              date: selectedDateTime,
                            );

                            FocusScope.of(sheetContext).unfocus();
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Guardar comida'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

/// Modal para registrar peso corporal.
Future<void> showWeightSheet(BuildContext context, FitnessStore store) async {
  final formKey = GlobalKey<FormState>();
  final weightController = TextEditingController(
    text: store.latestWeight?.toStringAsFixed(1) ?? '70.0',
  );
  var selectedDate = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _DisposeControllersOnUnmount(
        controllers: [weightController],
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar peso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                        ),
                        validator: _positiveDecimalValidator,
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fecha'),
                        subtitle: Text(
                          DateFormat('d MMM yyyy').format(selectedDate),
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked == null) {
                            return;
                          }
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        },
                      ),
                      const SizedBox(height: _appFormFieldGap),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            store.addWeight(
                              double.parse(weightController.text.trim()),
                              date: selectedDate,
                            );

                            FocusScope.of(sheetContext).unfocus();
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Guardar peso'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

/// Modal para editar objetivos diarios y peso objetivo.
Future<void> showGoalSheet(BuildContext context, FitnessStore store) async {
  final formKey = GlobalKey<FormState>();
  final calorieController = TextEditingController(
    text: store.goals.calorieGoal.toString(),
  );
  final waterController = TextEditingController(
    text: store.goals.waterGoalMl.toString(),
  );
  final workoutController = TextEditingController(
    text: store.goals.workoutGoalMinutes.toString(),
  );
  final targetWeightController = TextEditingController(
    text: store.goals.targetWeightKg.toStringAsFixed(1),
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _DisposeControllersOnUnmount(
        controllers: [
          calorieController,
          waterController,
          workoutController,
          targetWeightController,
        ],
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar objetivos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calorias diarias',
                    ),
                    validator: _positiveIntValidator,
                  ),
                  const SizedBox(height: _appFormFieldGap),
                  TextFormField(
                    controller: waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Agua diaria (ml)',
                    ),
                    validator: _positiveIntValidator,
                  ),
                  const SizedBox(height: _appFormFieldGap),
                  TextFormField(
                    controller: workoutController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Entreno diario (min)',
                    ),
                    validator: _positiveIntValidator,
                  ),
                  const SizedBox(height: _appFormFieldGap),
                  TextFormField(
                    controller: targetWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Peso objetivo (kg)',
                    ),
                    validator: _positiveDecimalValidator,
                  ),
                  const SizedBox(height: _appFormSectionGap),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        store.updateGoals(
                          store.goals.copyWith(
                            calorieGoal: int.parse(
                              calorieController.text.trim(),
                            ),
                            waterGoalMl: int.parse(waterController.text.trim()),
                            workoutGoalMinutes: int.parse(
                              workoutController.text.trim(),
                            ),
                            targetWeightKg: double.parse(
                              targetWeightController.text.trim(),
                            ),
                          ),
                        );

                        FocusScope.of(sheetContext).unfocus();
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Guardar objetivos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Modal para personalizar las preferencias del Coach IA.
Future<void> showCoachSheet(BuildContext context, FitnessStore store) async {
  var profile = store.coachProfile;
  final allergiesController = TextEditingController(text: profile.allergies);
  final notesController = TextEditingController(text: profile.notes);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _DisposeControllersOnUnmount(
        controllers: [allergiesController, notesController],
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personaliza tu Coach IA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Estas respuestas se guardan en este dispositivo.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FitnessGoalType>(
                      initialValue: profile.goal,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Objetivo principal',
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
                        setSheetState(() {
                          profile = profile.copyWith(goal: value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TrainingExperience>(
                      initialValue: profile.experience,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Nivel actual',
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
                        setSheetState(() {
                          profile = profile.copyWith(experience: value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EquipmentAccess>(
                      initialValue: profile.equipment,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Entorno de entrenamiento',
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
                        setSheetState(() {
                          profile = profile.copyWith(equipment: value);
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dias de entreno por semana: ${profile.daysPerWeek}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: profile.daysPerWeek.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: '${profile.daysPerWeek} dias',
                      onChanged: (value) {
                        setSheetState(() {
                          profile = profile.copyWith(
                            daysPerWeek: value.round(),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DietStyle>(
                      initialValue: profile.dietStyle,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Estrategia alimentaria',
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
                        setSheetState(() {
                          profile = profile.copyWith(dietStyle: value);
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Comidas por dia: ${profile.mealsPerDay}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: profile.mealsPerDay.toDouble(),
                      min: 2,
                      max: 6,
                      divisions: 4,
                      label: '${profile.mealsPerDay} comidas',
                      onChanged: (value) {
                        setSheetState(() {
                          profile = profile.copyWith(
                            mealsPerDay: value.round(),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: allergiesController,
                      decoration: const InputDecoration(
                        labelText:
                            'Alergias, intolerancias o restricciones clínicas',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Lesiones, preferencias o notas adicionales',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: _appFormSectionGap),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          store.updateCoachProfile(
                            profile.copyWith(
                              allergies: allergiesController.text.trim(),
                              notes: notesController.text.trim(),
                            ),
                          );
                          FocusScope.of(sheetContext).unfocus();
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Guardar preferencias'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

/// Valida que el campo no venga vacio.
String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obligatorio';
  }
  return null;
}

String? _optionalAgeValidator(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    return null;
  }

  final parsed = int.tryParse(normalized);
  if (parsed == null || parsed < 10 || parsed > 120) {
    return 'Ingresa una edad valida';
  }
  return null;
}

String? _optionalHeightValidator(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    return null;
  }

  final parsed = int.tryParse(normalized);
  if (parsed == null || parsed < 80 || parsed > 250) {
    return 'Ingresa una estatura valida en cm';
  }
  return null;
}

/// Valida enteros positivos.
String? _positiveIntValidator(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Ingresa un numero mayor a 0';
  }
  return null;
}

/// Valida decimales positivos.
String? _positiveDecimalValidator(String? value) {
  final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) {
    return 'Ingresa un numero valido';
  }
  return null;
}

String? _optionalPositiveDecimalValidator(String? value) {
  final normalized = (value ?? '').trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }

  final parsed = double.tryParse(normalized);
  if (parsed == null || parsed <= 0) {
    return 'Ingresa un numero valido';
  }
  return null;
}

/// Valida formato basico de email.
String? _emailFieldValidator(String? value) {
  final normalizedEmail = _normalizeEmail(value ?? '');
  if (normalizedEmail.isEmpty) {
    return 'Ingresa tu correo.';
  }
  if (!_isValidEmail(normalizedEmail)) {
    return 'Correo no valido.';
  }
  return null;
}

/// Adaptador para usar reglas de contraseña desde TextFormField.
String? _passwordFieldValidator(String? value) {
  return _passwordError(value ?? '');
}

/// Reglas de seguridad minima para contraseñas.
String? _passwordError(String value) {
  if (value.trim().isEmpty) {
    return 'Ingresa una contraseña.';
  }
  if (value.length < 8) {
    return 'Minimo 8 caracteres.';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
    return 'Incluye al menos una letra.';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Incluye al menos un numero.';
  }
  return null;
}
