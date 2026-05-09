part of '../main.dart';

// -----------------------------------------------------------------------------
// Catalogo de rutinas y demostraciones.
// Templates, ilustraciones, tarjetas y detalle visual de ejercicios.
// -----------------------------------------------------------------------------
class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.purpose,
    required this.howToSteps,
    required this.exampleExercises,
    required this.targetZones,
    required this.icon,
    required this.accent,
    required this.defaultDurationMinutes,
    required this.defaultCalories,
    required this.intensity,
    required this.demoExercise,
    required this.demoFocus,
    required this.demoCues,
    required this.demoPhases,
    required this.videoTitle,
    required this.videoSearchQuery,
    required this.videoSummary,
    required this.youtubeVideoId,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String purpose;
  final List<String> howToSteps;
  final List<String> exampleExercises;
  final List<String> targetZones;
  final IconData icon;
  final Color accent;
  final int defaultDurationMinutes;
  final int defaultCalories;
  final WorkoutIntensity intensity;
  final String demoExercise;
  final String demoFocus;
  final List<String> demoCues;
  final List<WorkoutDemoPhase> demoPhases;
  final String videoTitle;
  final String videoSearchQuery;
  final String videoSummary;
  final String youtubeVideoId;
}

class WorkoutDemoPhase {
  const WorkoutDemoPhase({
    required this.label,
    required this.instruction,
    required this.progress,
    required this.icon,
  });

  final String label;
  final String instruction;
  final double progress;
  final IconData icon;
}

const _workoutTemplates = <WorkoutTemplate>[
  WorkoutTemplate(
    id: 'full-body-strength',
    title: 'Fuerza total del cuerpo',
    category: 'Fuerza',
    description:
        'Sesion orientada a patrones compuestos para desarrollar fuerza general y masa muscular.',
    purpose:
        'Sirve para mejorar fuerza base, estabilidad y composicion corporal con ejercicios multiarticulares.',
    howToSteps: [
      'Realiza 8-10 min de calentamiento dinamico antes de cargar peso.',
      'Trabaja 4-6 ejercicios compuestos con tecnica controlada y rango completo.',
      'Descansa 60-90 s entre series y registra sensaciones al finalizar.',
    ],
    exampleExercises: [
      'Sentadilla goblet',
      'Press de pecho',
      'Remo con mancuerna',
      'Peso muerto rumano',
    ],
    targetZones: ['Piernas', 'Espalda', 'Pecho', 'Core'],
    icon: Icons.fitness_center,
    accent: Color(0xFF0F766E),
    defaultDurationMinutes: 50,
    defaultCalories: 320,
    intensity: WorkoutIntensity.medium,
    demoExercise: 'Sentadilla goblet',
    demoFocus: 'Patron de fuerza total',
    demoCues: ['Pecho alto', 'Cadera atras', 'Empuja el suelo'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Inicio',
        instruction:
            'Sostén la carga cerca del pecho, pies firmes y columna larga.',
        progress: 0.0,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Bajada',
        instruction: 'Lleva la cadera atrás y baja sin colapsar las rodillas.',
        progress: 0.5,
        icon: Icons.south_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Subida',
        instruction:
            'Empuja el suelo y vuelve arriba manteniendo el abdomen activo.',
        progress: 0.85,
        icon: Icons.north_rounded,
      ),
    ],
    videoTitle: 'Tecnica de fuerza para cuerpo completo',
    videoSearchQuery:
        'rutina fuerza cuerpo completo tecnica sentadilla remo press',
    videoSummary:
        'Abre una guia en video para revisar patrones compuestos y control postural antes de cargar.',
    youtubeVideoId: 'XANUniwN1Jg',
  ),
  WorkoutTemplate(
    id: 'upper-body-strength',
    title: 'Tren superior',
    category: 'Fuerza',
    description:
        'Bloque de empuje y traccion para ganar fuerza en torso, hombros y brazos.',
    purpose:
        'Ayuda a mejorar postura, fuerza funcional y capacidad para progresar en ejercicios de empuje y traccion.',
    howToSteps: [
      'Activa hombros y escapulas antes de iniciar la parte principal.',
      'Alterna ejercicios de empuje con movimientos de traccion para equilibrar el volumen.',
      'Mantén abdomen activo y evita compensaciones lumbares.',
    ],
    exampleExercises: [
      'Press militar',
      'Remo sentado',
      'Fondos asistidos',
      'Jalon al rostro',
    ],
    targetZones: ['Pecho', 'Espalda', 'Hombros', 'Brazos'],
    icon: Icons.accessibility_new_rounded,
    accent: Color(0xFF2563EB),
    defaultDurationMinutes: 45,
    defaultCalories: 290,
    intensity: WorkoutIntensity.medium,
    demoExercise: 'Press militar',
    demoFocus: 'Empuje y control escapular',
    demoCues: ['Core firme', 'Codos guiados', 'Sube con control'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Inicio',
        instruction:
            'Mancuernas a la altura de hombros, glúteos y abdomen apretados.',
        progress: 0.0,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Empuje',
        instruction:
            'Empuja en vertical y deja que la cabeza pase entre los brazos.',
        progress: 0.5,
        icon: Icons.north_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Final',
        instruction:
            'Bloquea arriba sin arquear la zona lumbar y baja con control.',
        progress: 0.99,
        icon: Icons.check_rounded,
      ),
    ],
    videoTitle: 'Tecnica de tren superior: empuje y traccion',
    videoSearchQuery:
        'tecnica tren superior press militar remo jalon al rostro espalda hombros',
    videoSummary:
        'Te lleva a una demostracion enfocada en hombros, escápulas y control del torso.',
    youtubeVideoId: 'B3WwHo_OZLE',
  ),
  WorkoutTemplate(
    id: 'lower-body-core',
    title: 'Tren inferior y core',
    category: 'Fuerza',
    description:
        'Sesion enfocada en estabilidad lumbopelvica y fuerza de piernas para mejorar base atletica.',
    purpose:
        'Permite desarrollar potencia, control del core y tolerancia al esfuerzo en miembros inferiores.',
    howToSteps: [
      'Inicia con movilidad de cadera y tobillo para mejorar la mecanica.',
      'Prioriza sentadillas, bisagras y patrones unilaterales con control postural.',
      'Finaliza con ejercicios antirotacion o estabilizacion de core.',
    ],
    exampleExercises: [
      'Sentadilla frontal',
      'Zancadas',
      'Elevacion de cadera',
      'Plancha con alcance',
    ],
    targetZones: ['Gluteos', 'Cuadriceps', 'Isquiotibiales', 'Core'],
    icon: Icons.directions_run_rounded,
    accent: Color(0xFF7C3AED),
    defaultDurationMinutes: 48,
    defaultCalories: 310,
    intensity: WorkoutIntensity.medium,
    demoExercise: 'Sentadilla frontal',
    demoFocus: 'Sentadilla y brace del core',
    demoCues: ['Rodillas estables', 'Baja alineado', 'Aprieta abdomen'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Inicio',
        instruction: 'Codos altos, torso erguido y pies al ancho cómodo.',
        progress: 0.0,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Descenso',
        instruction:
            'Baja recto entre las piernas manteniendo el pecho abierto.',
        progress: 0.5,
        icon: Icons.south_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Ascenso',
        instruction:
            'Sube en bloque, con abdomen tenso y rodillas siguiendo el pie.',
        progress: 0.85,
        icon: Icons.north_rounded,
      ),
    ],
    videoTitle: 'Tecnica de tren inferior y core',
    videoSearchQuery:
        'tecnica tren inferior core sentadilla frontal elevacion de cadera zancadas',
    videoSummary:
        'Muestra referencias de sentadilla, bisagra y estabilidad del core para ejecutar mejor la sesion.',
    youtubeVideoId: 'SJ97z1-YVGs',
  ),
  WorkoutTemplate(
    id: 'hiit-conditioning',
    title: 'HIIT metabolico',
    category: 'Cardio',
    description:
        'Intervalos cortos de alta intensidad para elevar el gasto energetico y la capacidad anaerobica.',
    purpose:
        'Util para mejorar condicion fisica, tolerancia al lactato y eficiencia en sesiones cortas.',
    howToSteps: [
      'Calienta 6-8 min con movilidad y un bloque cardio progresivo.',
      'Alterna esfuerzos de 20-40 s con pausas incompletas o activas.',
      'Mantén tecnica consistente incluso cuando aumente la fatiga.',
    ],
    exampleExercises: [
      'Sprints en bici',
      'Burpees',
      'Escaladores',
      'Sentadillas con salto',
    ],
    targetZones: ['Sistema cardiovascular', 'Piernas', 'Core'],
    icon: Icons.bolt_rounded,
    accent: Color(0xFFEA580C),
    defaultDurationMinutes: 24,
    defaultCalories: 280,
    intensity: WorkoutIntensity.high,
    demoExercise: 'Burpee',
    demoFocus: 'Ritmo rapido y aterrizaje suave',
    demoCues: ['Abre explosivo', 'Cae suave', 'Respira y repite'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Entrada',
        instruction:
            'Flexiona y lleva manos al suelo sin perder tensión en el tronco.',
        progress: 0.15,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Transicion',
        instruction:
            'Extiende rápido las piernas y prepara el regreso con control.',
        progress: 0.5,
        icon: Icons.sync_alt_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Salida',
        instruction:
            'Salta suave y aterriza estable antes de la siguiente repetición.',
        progress: 0.85,
        icon: Icons.north_rounded,
      ),
    ],
    videoTitle: 'Tecnica HIIT para intervalos cortos',
    videoSearchQuery:
        'hiit tecnica burpees escaladores sentadillas con salto intensidad',
    videoSummary:
        'Incluye una demostracion de tecnica y ritmo para sostener intensidad sin perder forma.',
    youtubeVideoId: 'awbFx6HqWns',
  ),
  WorkoutTemplate(
    id: 'zone-2-cardio',
    title: 'Cardio zona 2',
    category: 'Cardio',
    description:
        'Trabajo continuo de intensidad moderada para mejorar base aerobica y recuperacion.',
    purpose:
        'Aumenta capacidad cardiorrespiratoria, tolerancia al volumen y control de la fatiga.',
    howToSteps: [
      'Mantén un ritmo que te permita hablar con frases cortas sin perder el control respiratorio.',
      'Sostén la intensidad entre 30 y 45 min sin picos bruscos.',
      'Usa caminata inclinada, bici o trote suave segun tu nivel.',
    ],
    exampleExercises: [
      'Caminata inclinada',
      'Bicicleta estatica',
      'Trote continuo',
      'Eliptica',
    ],
    targetZones: ['Sistema cardiovascular', 'Piernas'],
    icon: Icons.monitor_heart_outlined,
    accent: Color(0xFF0891B2),
    defaultDurationMinutes: 35,
    defaultCalories: 260,
    intensity: WorkoutIntensity.low,
    demoExercise: 'Caminata inclinada',
    demoFocus: 'Paso continuo en zona 2',
    demoCues: ['Ritmo estable', 'Hombros sueltos', 'Respiracion controlada'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Postura',
        instruction:
            'Mira al frente, hombros relajados y abdomen suave pero activo.',
        progress: 0.0,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Paso',
        instruction:
            'Mantén zancada corta y constante, sin rebotar ni agarrarte fuerte.',
        progress: 0.35,
        icon: Icons.directions_walk_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Ritmo',
        instruction:
            'Respira nasal o mixta y sostén un esfuerzo que te deje hablar.',
        progress: 0.7,
        icon: Icons.favorite_rounded,
      ),
    ],
    videoTitle: 'Explicacion practica de cardio zona 2',
    videoSearchQuery:
        'cardio zona 2 explicacion tecnica caminata inclinada bicicleta',
    videoSummary:
        'Sirve para entender el ritmo correcto y como controlar el esfuerzo durante el cardio continuo.',
    youtubeVideoId: 'z13CzuPc79g',
  ),
  WorkoutTemplate(
    id: 'mobility-recovery',
    title: 'Movilidad y recuperacion',
    category: 'Movilidad',
    description:
        'Sesion suave para mejorar rango articular, respiracion y calidad de movimiento.',
    purpose:
        'Favorece la recuperacion, reduce rigidez y prepara al cuerpo para sesiones mas intensas.',
    howToSteps: [
      'Empieza con respiracion diafragmatica y movilidad controlada.',
      'Trabaja columna toracica, cadera, tobillo y hombro con repeticiones lentas.',
      'Cierra con estiramientos activos y liberacion ligera.',
    ],
    exampleExercises: [
      'Estiramiento global',
      '90/90 de cadera',
      'Rotaciones toracicas',
      'Respiracion supina',
    ],
    targetZones: ['Cadera', 'Columna', 'Hombros', 'Tobillos'],
    icon: Icons.self_improvement_rounded,
    accent: Color(0xFF059669),
    defaultDurationMinutes: 20,
    defaultCalories: 110,
    intensity: WorkoutIntensity.low,
    demoExercise: '90/90 de cadera',
    demoFocus: 'Movilidad lenta y controlada',
    demoCues: ['Alarga columna', 'Exhala al abrir', 'Sin rebotes'],
    demoPhases: [
      WorkoutDemoPhase(
        label: 'Base',
        instruction:
            'Siéntate alto y acomoda ambas piernas en 90/90 sin colapsar el torso.',
        progress: 0.0,
        icon: Icons.play_arrow_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Apertura',
        instruction:
            'Inclínate desde la cadera y exhala mientras ganas rango lentamente.',
        progress: 0.45,
        icon: Icons.open_in_full_rounded,
      ),
      WorkoutDemoPhase(
        label: 'Regreso',
        instruction:
            'Vuelve al centro sin rebote y cambia de lado manteniendo control.',
        progress: 0.85,
        icon: Icons.refresh_rounded,
      ),
    ],
    videoTitle: 'Rutina guiada de movilidad y recuperacion',
    videoSearchQuery:
        'rutina movilidad cadera hombros recuperacion guiada tecnica 90 90',
    videoSummary:
        'Abre una rutina en video para seguir movilidad suave con buena respiracion y amplitud.',
    youtubeVideoId: 'adRzu0Vz37s',
  ),
];

void _registerWorkoutTemplate(
  BuildContext context,
  FitnessStore store,
  WorkoutTemplate template,
) {
  showWorkoutSheet(
    context,
    store,
    presetName: template.title,
    presetCategory: template.category,
    presetDurationMinutes: template.defaultDurationMinutes,
    presetCaloriesBurned: template.defaultCalories,
    presetIntensity: template.intensity,
    presetDate: DateTime.now(),
  );
}

Future<void> openWorkoutCatalog(BuildContext context, FitnessStore store) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => WorkoutCatalogScreen(store: store)));
}

Future<void> openWorkoutTemplateDetails(
  BuildContext context,
  FitnessStore store,
  WorkoutTemplate template,
) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          WorkoutTemplateDetailScreen(store: store, template: template),
    ),
  );
}

class WorkoutCatalogScreen extends StatelessWidget {
  const WorkoutCatalogScreen({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de entrenamientos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona una rutina guiada',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aqui puedes entrar a cada rutina para revisar la guia completa del ejercicio antes de registrar la sesion.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.66),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => showWorkoutSheet(context, store),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Registrar entrenamiento libre'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._workoutTemplates.map(
            (template) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkoutTemplateCard(
                template: template,
                onOpen: () =>
                    openWorkoutTemplateDetails(context, store, template),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutTemplateDetailScreen extends StatelessWidget {
  const WorkoutTemplateDetailScreen({
    super.key,
    required this.store,
    required this.template,
  });

  final FitnessStore store;
  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WorkoutTemplateVisual(
                  template: template,
                  headline: 'Resumen del ejercicio',
                  supportingText:
                      'Revisa los puntos clave y la tecnica principal antes de registrar la sesion.',
                  showDefaultBadges: false,
                  animatePreview: false,
                  showPreview: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  template.description,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _CoachChip(
                            icon: Icons.schedule_outlined,
                            label: '${template.defaultDurationMinutes} min',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CoachChip(
                            icon: template.icon,
                            label: template.category,
                          ),
                          ...template.targetZones
                              .take(2)
                              .map(
                                (zone) => _CoachChip(
                                  icon: Icons.my_location_outlined,
                                  label: zone,
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _TemplateSection(
                        title: 'Secuencia visual',
                        child: _WorkoutExerciseIllustrationCard(
                          template: template,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TemplateSection(
                        title: 'Como hacerlo',
                        child: Column(
                          children: template.demoPhases
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _WorkoutQuickStep(
                                    index: entry.key + 1,
                                    title: entry.value.label,
                                    instruction: entry.value.instruction,
                                    accent: template.accent,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TemplateSection(
                        title: 'Trabaja principalmente',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: template.targetZones
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: template.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: template.accent,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _registerWorkoutTemplate(
                            context,
                            store,
                            template,
                          ),
                          icon: const Icon(Icons.add_task_outlined),
                          label: const Text('Registrar este entrenamiento'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutTemplateCard extends StatelessWidget {
  const _WorkoutTemplateCard({required this.template, required this.onOpen});

  final WorkoutTemplate template;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkoutTemplateCatalogHero(template: template),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Toca para ver detalle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver detalle',
                        style: TextStyle(
                          color: template.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: template.accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTemplateCatalogHero extends StatelessWidget {
  const _WorkoutTemplateCatalogHero({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [template.accent, template.accent.withValues(alpha: 0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _WorkoutVisualHeader(template: template, headline: template.title),
    );
  }
}

class _WorkoutExerciseIllustrationCard extends StatelessWidget {
  const _WorkoutExerciseIllustrationCard({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    final phases = template.demoPhases;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: template.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: template.accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CoachChip(icon: template.icon, label: template.demoExercise),
              _CoachChip(
                icon: Icons.auto_awesome_outlined,
                label: template.demoFocus,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Estas son las tres posiciones clave del movimiento.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.68),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: phases
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == phases.length - 1 ? 0 : 10,
                    ),
                    child: _WorkoutPhasePreviewCard(
                      index: entry.key + 1,
                      phase: entry.value,
                      accent: template.accent,
                      template: template,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPhasePreviewCard extends StatelessWidget {
  const _WorkoutPhasePreviewCard({
    required this.index,
    required this.phase,
    required this.accent,
    required this.template,
  });

  final int index;
  final WorkoutDemoPhase phase;
  final Color accent;
  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phase.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(phase.icon, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Paso $index',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Color.lerp(Colors.white, accent, 0.22)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomPaint(
                    painter: _WorkoutTechniquePainter(
                      template: template,
                      progress: phase.progress,
                      showMotionEchoes: false,
                      showBackdrop: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            phase.instruction,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.72),
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutQuickStep extends StatelessWidget {
  const _WorkoutQuickStep({
    required this.index,
    required this.title,
    required this.instruction,
    required this.accent,
  });

  final int index;
  final String title;
  final String instruction;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: TextStyle(color: accent, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                instruction,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _WorkoutTechniquePainter extends CustomPainter {
  const _WorkoutTechniquePainter({
    required this.template,
    required this.progress,
    this.showMotionEchoes = true,
    this.showBackdrop = true,
  });

  final WorkoutTemplate template;
  final double progress;
  final bool showMotionEchoes;
  final bool showBackdrop;

  @override
  void paint(Canvas canvas, Size size) {
    final kind = _motionKindForTemplate(template);
    final floorY = size.height * 0.8;
    final currentFrame = _frameForPose(
      size,
      _poseForTemplate(progress),
      floorY,
    );
    final previousFrame = _frameForPose(
      size,
      _poseForTemplate(progress - 0.08),
      floorY,
    );
    final nextFrame = _frameForPose(
      size,
      _poseForTemplate(progress + 0.08),
      floorY,
    );

    if (!showBackdrop) {
      _paintCartoonPreview(canvas, size, currentFrame, kind, floorY);
      return;
    }

    _drawBackdrop(canvas, size);
    _drawPerspectiveFloor(canvas, size, floorY);
    _drawEquipmentBackdrop(canvas, size, currentFrame, kind, floorY);
    if (showMotionEchoes) {
      _drawGhostFigure(
        canvas,
        previousFrame,
        Colors.white.withValues(alpha: 0.16),
      );
      _drawGhostFigure(canvas, nextFrame, Colors.white.withValues(alpha: 0.1));
    }
    _drawFigureShadow(canvas, currentFrame, floorY);
    _drawFigure(canvas, size, currentFrame);
    _drawEquipmentOverlay(canvas, size, currentFrame, kind, floorY);
  }

  WorkoutDemoPhase _activeDemoPhase() {
    if (template.demoPhases.isEmpty) {
      return const WorkoutDemoPhase(
        label: 'Posicion',
        instruction: '',
        progress: 0,
        icon: Icons.play_arrow_rounded,
      );
    }
    var selected = template.demoPhases.first;
    var nearestDistance = double.infinity;
    for (final phase in template.demoPhases) {
      final distance = (phase.progress - progress).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        selected = phase;
      }
    }
    return selected;
  }

  void _paintCartoonPreview(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    _WorkoutMotionKind kind,
    double floorY,
  ) {
    final badgePhase = _activeDemoPhase();
    _drawCartoonFloor(canvas, size, floorY);
    _drawCartoonBubble(canvas, size, badgePhase);
    _drawCartoonEquipment(canvas, size, frame, kind, floorY);
    _drawCartoonShadow(canvas, frame, floorY);
    _drawCartoonFigure(canvas, size, frame);
    _drawCartoonCueArrow(canvas, size, badgePhase);
  }

  void _drawCartoonFloor(Canvas canvas, Size size, double floorY) {
    final floorPaint = Paint()
      ..color = template.accent.withValues(alpha: 0.22)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final haloPaint = Paint()..color = template.accent.withValues(alpha: 0.08);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.2),
      size.shortestSide * 0.11,
      haloPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.72),
      size.shortestSide * 0.13,
      haloPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.14, floorY + 10),
      Offset(size.width * 0.86, floorY + 10),
      floorPaint,
    );
  }

  void _drawCartoonBubble(Canvas canvas, Size size, WorkoutDemoPhase phase) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width * 0.34, 24),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = template.accent.withValues(alpha: 0.18),
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(phase.icon.codePoint),
        style: TextStyle(
          fontSize: 13,
          color: template.accent,
          fontFamily: phase.icon.fontFamily,
          package: phase.icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textPainter = TextPainter(
      text: TextSpan(
        text: phase.label,
        style: TextStyle(
          color: template.accent,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.outerRect.width - 34);

    iconPainter.paint(canvas, Offset(rect.left + 8, rect.top + 5));

    textPainter.paint(canvas, Offset(rect.left + 24, rect.top + 6));
  }

  void _drawCartoonEquipment(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    _WorkoutMotionKind kind,
    double floorY,
  ) {
    switch (kind) {
      case _WorkoutMotionKind.fullBodyStrength:
      case _WorkoutMotionKind.lowerBodyCore:
        final center = Offset(
          (frame.leftHand.dx + frame.rightHand.dx) / 2,
          (frame.leftHand.dy + frame.rightHand.dy) / 2 + 5,
        );
        final bodyRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 28, height: 20),
          const Radius.circular(8),
        );
        canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF334155));
        canvas.drawCircle(
          center + const Offset(-18, 0),
          7,
          Paint()..color = const Color(0xFF0F172A),
        );
        canvas.drawCircle(
          center + const Offset(18, 0),
          7,
          Paint()..color = const Color(0xFF0F172A),
        );
        break;
      case _WorkoutMotionKind.upperBodyStrength:
        canvas.drawLine(
          frame.leftHand,
          frame.rightHand,
          Paint()
            ..color = const Color(0xFF334155)
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          frame.leftHand,
          7,
          Paint()..color = const Color(0xFF0F172A),
        );
        canvas.drawCircle(
          frame.rightHand,
          7,
          Paint()..color = const Color(0xFF0F172A),
        );
        break;
      case _WorkoutMotionKind.hiit:
        final boxPaint = Paint()
          ..color = template.accent.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.66,
              floorY - 42,
              size.width * 0.14,
              24,
            ),
            const Radius.circular(12),
          ),
          boxPaint,
        );
        break;
      case _WorkoutMotionKind.zone2:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.16, floorY - 4, size.width * 0.56, 14),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF334155),
        );
        canvas.drawLine(
          Offset(size.width * 0.68, floorY - 4),
          Offset(size.width * 0.76, floorY - 36),
          Paint()
            ..color = const Color(0xFF334155)
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.72, floorY - 48, 22, 16),
            const Radius.circular(8),
          ),
          Paint()..color = template.accent.withValues(alpha: 0.7),
        );
        break;
      case _WorkoutMotionKind.mobility:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.18, floorY - 2, size.width * 0.52, 10),
            const Radius.circular(999),
          ),
          Paint()..color = template.accent.withValues(alpha: 0.22),
        );
        break;
    }
  }

  void _drawCartoonShadow(
    Canvas canvas,
    _WorkoutFigureFrame frame,
    double floorY,
  ) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          (frame.leftFoot.dx + frame.rightFoot.dx) / 2,
          floorY + 8,
        ),
        width: 70,
        height: 18,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  void _drawCartoonFigure(Canvas canvas, Size size, _WorkoutFigureFrame frame) {
    const skin = Color(0xFFFFD7B5);
    final shirt = template.accent;
    const shorts = Color(0xFF0F172A);
    const shoe = Color(0xFF334155);
    const outline = Color(0xFF0F172A);

    final torso = _torsoPath(frame);
    canvas.drawShadow(torso, Colors.black.withValues(alpha: 0.12), 6, false);
    canvas.drawPath(torso, Paint()..color = shirt);
    canvas.drawPath(
      torso,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = outline.withValues(alpha: 0.18),
    );

    final shortsPath = Path()
      ..moveTo(frame.leftHip.dx, frame.leftHip.dy - 2)
      ..lineTo(frame.rightHip.dx, frame.rightHip.dy - 2)
      ..lineTo(frame.rightHip.dx + 10, frame.rightHip.dy + 14)
      ..lineTo(frame.leftHip.dx - 10, frame.leftHip.dy + 14)
      ..close();
    canvas.drawPath(shortsPath, Paint()..color = shorts);

    for (final segment in [
      (frame.leftShoulder, frame.leftElbow, 11.0),
      (frame.leftElbow, frame.leftHand, 10.0),
      (frame.rightShoulder, frame.rightElbow, 11.0),
      (frame.rightElbow, frame.rightHand, 10.0),
      (frame.leftHip, frame.leftKnee, 12.0),
      (frame.leftKnee, frame.leftFoot, 11.0),
      (frame.rightHip, frame.rightKnee, 12.0),
      (frame.rightKnee, frame.rightFoot, 11.0),
    ]) {
      _drawCartoonLimb(
        canvas,
        segment.$1,
        segment.$2,
        width: segment.$3,
        fill: skin,
        outline: outline,
      );
    }

    canvas.drawCircle(frame.leftHand, 5, Paint()..color = skin);
    canvas.drawCircle(frame.rightHand, 5, Paint()..color = skin);
    canvas.drawCircle(
      frame.leftKnee,
      4,
      Paint()..color = outline.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      frame.rightKnee,
      4,
      Paint()..color = outline.withValues(alpha: 0.16),
    );

    _drawCartoonHead(canvas, size, frame, skin, outline);
    _drawCartoonShoe(canvas, frame.leftFoot, shoe);
    _drawCartoonShoe(canvas, frame.rightFoot, shoe);
  }

  void _drawCartoonLimb(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double width,
    required Color fill,
    required Color outline,
  }) {
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = outline.withValues(alpha: 0.18)
        ..strokeWidth = width + 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = fill
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCartoonHead(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    Color skin,
    Color outline,
  ) {
    canvas.drawCircle(
      frame.headCenter,
      frame.headRadius,
      Paint()..color = skin,
    );
    canvas.drawCircle(
      frame.headCenter + Offset(-frame.headRadius * 0.28, -2),
      1.3,
      Paint()..color = outline,
    );
    canvas.drawCircle(
      frame.headCenter + Offset(frame.headRadius * 0.12, -2),
      1.3,
      Paint()..color = outline,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: frame.headCenter + const Offset(0, 3),
        width: frame.headRadius * 1.1,
        height: frame.headRadius * 0.75,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: frame.headCenter, radius: frame.headRadius),
      math.pi,
      math.pi,
      true,
      Paint()..color = outline.withValues(alpha: 0.16),
    );
  }

  void _drawCartoonShoe(Canvas canvas, Offset foot, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: foot + const Offset(4, 4),
          width: 18,
          height: 8,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = color,
    );
  }

  void _drawCartoonCueArrow(Canvas canvas, Size size, WorkoutDemoPhase phase) {
    final center = Offset(size.width * 0.84, size.height * 0.28);
    final paint = Paint()
      ..color = template.accent.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (phase.icon == Icons.south_rounded) {
      canvas.drawLine(
        center + const Offset(0, -16),
        center + const Offset(0, 10),
        paint,
      );
      final path = Path()
        ..moveTo(center.dx - 8, center.dy + 2)
        ..lineTo(center.dx, center.dy + 10)
        ..lineTo(center.dx + 8, center.dy + 2);
      canvas.drawPath(path, paint);
    } else if (phase.icon == Icons.north_rounded) {
      canvas.drawLine(
        center + const Offset(0, 16),
        center + const Offset(0, -10),
        paint,
      );
      final path = Path()
        ..moveTo(center.dx - 8, center.dy - 2)
        ..lineTo(center.dx, center.dy - 10)
        ..lineTo(center.dx + 8, center.dy - 2);
      canvas.drawPath(path, paint);
    } else {
      canvas.drawCircle(
        center,
        10,
        Paint()..color = template.accent.withValues(alpha: 0.14),
      );
      canvas.drawCircle(center, 3, Paint()..color = template.accent);
    }
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    final accentGlow = Paint()
      ..color = template.accent.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    final softGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.22),
      size.shortestSide * 0.18,
      accentGlow,
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.76),
      size.shortestSide * 0.14,
      softGlow,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.26),
          ],
          stops: const [0.58, 0.84, 1],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawPerspectiveFloor(Canvas canvas, Size size, double floorY) {
    final topLeft = Offset(size.width * 0.2, floorY - size.height * 0.03);
    final topRight = Offset(size.width * 0.82, floorY - size.height * 0.04);
    final bottomRight = Offset(size.width * 0.96, size.height * 0.94);
    final bottomLeft = Offset(size.width * 0.06, size.height * 0.94);
    final floorPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    final floorBounds = floorPath.getBounds();
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2;

    canvas.drawShadow(
      floorPath,
      Colors.black.withValues(alpha: 0.42),
      16,
      false,
    );
    canvas.drawPath(
      floorPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.14),
            template.accent.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(floorBounds),
    );
    canvas.drawPath(
      floorPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.14),
    );

    for (var index = 1; index <= 4; index++) {
      final t = index / 5;
      canvas.drawLine(
        Offset.lerp(topLeft, topRight, t)!,
        Offset.lerp(bottomLeft, bottomRight, t)!,
        gridPaint,
      );
    }
    for (var index = 1; index <= 3; index++) {
      final t = index / 4;
      canvas.drawLine(
        Offset.lerp(topLeft, bottomLeft, t)!,
        Offset.lerp(topRight, bottomRight, t)!,
        gridPaint,
      );
    }
  }

  void _drawEquipmentBackdrop(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    _WorkoutMotionKind kind,
    double floorY,
  ) {
    switch (kind) {
      case _WorkoutMotionKind.fullBodyStrength:
        _drawRackBackdrop(canvas, size, floorY, showBox: false);
        break;
      case _WorkoutMotionKind.upperBodyStrength:
        _drawUpperBodyMachineBackdrop(canvas, size, floorY);
        break;
      case _WorkoutMotionKind.lowerBodyCore:
        _drawRackBackdrop(canvas, size, floorY, showBox: true);
        break;
      case _WorkoutMotionKind.hiit:
        _drawCardioMachineBackdrop(canvas, size, floorY, intense: true);
        break;
      case _WorkoutMotionKind.zone2:
        _drawCardioMachineBackdrop(canvas, size, floorY, intense: false);
        break;
      case _WorkoutMotionKind.mobility:
        _drawMobilityBackdrop(canvas, size, floorY);
        break;
    }
  }

  void _drawEquipmentOverlay(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    _WorkoutMotionKind kind,
    double floorY,
  ) {
    switch (kind) {
      case _WorkoutMotionKind.fullBodyStrength:
      case _WorkoutMotionKind.lowerBodyCore:
        _drawGobletLoad(canvas, frame);
        break;
      case _WorkoutMotionKind.upperBodyStrength:
        _drawUpperBodyHandles(canvas, size, frame, floorY);
        break;
      case _WorkoutMotionKind.hiit:
        _drawCardioOverlay(canvas, size, frame, floorY, intense: true);
        break;
      case _WorkoutMotionKind.zone2:
        _drawCardioOverlay(canvas, size, frame, floorY, intense: false);
        break;
      case _WorkoutMotionKind.mobility:
        _drawMobilityOverlay(canvas, size, frame);
        break;
    }
  }

  void _drawRackBackdrop(
    Canvas canvas,
    Size size,
    double floorY, {
    required bool showBox,
  }) {
    final leftX = size.width * 0.24;
    final rightX = size.width * 0.78;
    final topY = size.height * 0.16;

    _drawBeam(canvas, Offset(leftX, topY), Offset(leftX, floorY), width: 11);
    _drawBeam(
      canvas,
      Offset(rightX, topY + 12),
      Offset(rightX, floorY),
      width: 11,
    );
    _drawBeam(
      canvas,
      Offset(leftX, topY),
      Offset(rightX, topY + 8),
      width: 10,
      alpha: 0.82,
    );
    _drawBeam(
      canvas,
      Offset(leftX + 8, floorY - size.height * 0.24),
      Offset(rightX - 14, floorY - size.height * 0.22),
      width: 8,
      alpha: 0.4,
    );
    _drawBeam(
      canvas,
      Offset(leftX - 12, floorY + 8),
      Offset(rightX + 12, floorY + 8),
      width: 12,
      alpha: 0.58,
    );

    for (var index = 0; index < 5; index++) {
      final holeY = topY + 28 + (index * 24);
      canvas.drawCircle(
        Offset(leftX, holeY),
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        Offset(rightX, holeY + 8),
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }

    if (showBox) {
      _drawPanel(
        canvas,
        Rect.fromLTWH(size.width * 0.58, floorY - 22, size.width * 0.16, 18),
        radius: 12,
        alpha: 0.92,
      );
    } else {
      final platePaint = Paint()
        ..color = template.accent.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(Offset(size.width * 0.19, floorY - 26), 12, platePaint);
      canvas.drawCircle(Offset(size.width * 0.84, floorY - 32), 10, platePaint);
    }
  }

  void _drawUpperBodyMachineBackdrop(Canvas canvas, Size size, double floorY) {
    _drawPanel(
      canvas,
      Rect.fromLTWH(size.width * 0.33, floorY - 22, size.width * 0.22, 12),
      radius: 12,
      alpha: 0.94,
    );
    _drawPanel(
      canvas,
      Rect.fromLTWH(
        size.width * 0.27,
        floorY - size.height * 0.28,
        size.width * 0.12,
        size.height * 0.19,
      ),
      radius: 16,
      alpha: 0.9,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.38, floorY - 8),
      Offset(size.width * 0.38, floorY - size.height * 0.22),
      width: 12,
      alpha: 0.82,
    );
    _drawPanel(
      canvas,
      Rect.fromLTWH(
        size.width * 0.74,
        floorY - size.height * 0.42,
        size.width * 0.08,
        size.height * 0.38,
      ),
      radius: 18,
      alpha: 0.84,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.52, floorY - size.height * 0.2),
      Offset(size.width * 0.74, floorY - size.height * 0.28),
      width: 10,
      alpha: 0.8,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.53, floorY - size.height * 0.28),
      Offset(size.width * 0.74, floorY - size.height * 0.18),
      width: 8,
      alpha: 0.64,
    );
    _drawPanel(
      canvas,
      Rect.fromLTWH(
        size.width * 0.72,
        floorY - size.height * 0.37,
        size.width * 0.12,
        size.height * 0.1,
      ),
      radius: 14,
      alpha: 0.6,
      tint: const Color(0xFF60A5FA),
    );
    final consolePath = Path()
      ..moveTo(size.width * 0.745, floorY - size.height * 0.315)
      ..lineTo(size.width * 0.765, floorY - size.height * 0.33)
      ..lineTo(size.width * 0.782, floorY - size.height * 0.29)
      ..lineTo(size.width * 0.81, floorY - size.height * 0.34);
    canvas.drawPath(
      consolePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCardioMachineBackdrop(
    Canvas canvas,
    Size size,
    double floorY, {
    required bool intense,
  }) {
    final tint = intense ? const Color(0xFF38BDF8) : template.accent;

    _drawPanel(
      canvas,
      Rect.fromLTWH(size.width * 0.18, floorY - 10, size.width * 0.52, 18),
      radius: 14,
      alpha: 0.9,
      tint: tint,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.66, floorY - 2),
      Offset(size.width * 0.74, floorY - size.height * 0.2),
      width: 9,
      alpha: 0.84,
      tint: tint,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.74, floorY - size.height * 0.2),
      Offset(size.width * 0.78, floorY - size.height * 0.34),
      width: 8,
      alpha: 0.84,
      tint: tint,
    );
    _drawBeam(
      canvas,
      Offset(size.width * 0.58, floorY - size.height * 0.16),
      Offset(size.width * 0.79, floorY - size.height * 0.22),
      width: 7,
      alpha: 0.58,
      tint: tint,
    );
    _drawPanel(
      canvas,
      Rect.fromLTWH(
        size.width * 0.72,
        floorY - size.height * 0.36,
        size.width * 0.12,
        size.height * 0.11,
      ),
      radius: 14,
      alpha: 0.58,
      tint: tint,
    );

    for (var index = 0; index < 3; index++) {
      final lineY = floorY - 5 + (index * 4);
      canvas.drawLine(
        Offset(size.width * 0.22, lineY),
        Offset(size.width * 0.66, lineY),
        Paint()
          ..color = Colors.white.withValues(alpha: intense ? 0.18 : 0.12)
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawMobilityBackdrop(Canvas canvas, Size size, double floorY) {
    _drawPanel(
      canvas,
      Rect.fromLTWH(size.width * 0.18, floorY - 18, size.width * 0.56, 16),
      radius: 18,
      alpha: 0.58,
    );
    final ladderX = size.width * 0.8;
    final topY = size.height * 0.18;
    _drawBeam(
      canvas,
      Offset(ladderX - 18, topY),
      Offset(ladderX - 18, floorY - 8),
      width: 8,
      alpha: 0.72,
    );
    _drawBeam(
      canvas,
      Offset(ladderX + 18, topY + 4),
      Offset(ladderX + 18, floorY - 8),
      width: 8,
      alpha: 0.72,
    );
    for (var index = 0; index < 4; index++) {
      final y = topY + 24 + (index * 26);
      _drawBeam(
        canvas,
        Offset(ladderX - 18, y),
        Offset(ladderX + 18, y + 2),
        width: 6,
        alpha: 0.5,
      );
    }
    _drawPanel(
      canvas,
      Rect.fromLTWH(size.width * 0.14, floorY - 30, 20, 12),
      radius: 8,
      alpha: 0.62,
      tint: const Color(0xFFF59E0B),
    );
  }

  void _drawGobletLoad(Canvas canvas, _WorkoutFigureFrame frame) {
    final loadCenter = Offset(
      (frame.leftHand.dx + frame.rightHand.dx) / 2,
      (frame.leftHand.dy + frame.rightHand.dy) / 2 + 6,
    );

    _drawPanel(
      canvas,
      Rect.fromCenter(
        center: loadCenter + const Offset(0, 8),
        width: 26,
        height: 28,
      ),
      radius: 10,
      alpha: 0.96,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: loadCenter - const Offset(0, 2),
        width: 22,
        height: 16,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawUpperBodyHandles(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    double floorY,
  ) {
    final topAnchor = Offset(size.width * 0.74, floorY - size.height * 0.28);
    final bottomAnchor = Offset(size.width * 0.74, floorY - size.height * 0.2);
    final cablePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(topAnchor, frame.leftHand, cablePaint);
    canvas.drawLine(bottomAnchor, frame.rightHand, cablePaint);

    _drawPanel(
      canvas,
      Rect.fromCenter(center: frame.leftHand, width: 14, height: 8),
      radius: 8,
      alpha: 0.9,
      tint: const Color(0xFF60A5FA),
    );
    _drawPanel(
      canvas,
      Rect.fromCenter(center: frame.rightHand, width: 14, height: 8),
      radius: 8,
      alpha: 0.9,
      tint: const Color(0xFF60A5FA),
    );
  }

  void _drawCardioOverlay(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
    double floorY, {
    required bool intense,
  }) {
    final tint = intense ? const Color(0xFF38BDF8) : template.accent;
    final overlayPaint = Paint()
      ..color = tint.withValues(alpha: intense ? 0.4 : 0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (intense) {
      for (var index = 0; index < 3; index++) {
        final offset = 14.0 * index;
        canvas.drawLine(
          frame.hipCenter + Offset(-26 - offset, 8 - offset * 0.2),
          frame.hipCenter + Offset(-6 - offset, 8 - offset * 0.2),
          overlayPaint,
        );
      }
    } else {
      final pulse = Path()
        ..moveTo(size.width * 0.22, floorY - 46)
        ..lineTo(size.width * 0.28, floorY - 46)
        ..lineTo(size.width * 0.31, floorY - 60)
        ..lineTo(size.width * 0.35, floorY - 32)
        ..lineTo(size.width * 0.39, floorY - 46)
        ..lineTo(size.width * 0.46, floorY - 46);
      canvas.drawPath(pulse, overlayPaint);
    }
  }

  void _drawMobilityOverlay(
    Canvas canvas,
    Size size,
    _WorkoutFigureFrame frame,
  ) {
    final stretchPaint = Paint()
      ..color = template.accent.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final stretchPath = Path()
      ..moveTo(frame.leftHand.dx, frame.leftHand.dy)
      ..quadraticBezierTo(
        frame.headCenter.dx,
        frame.headCenter.dy - size.height * 0.12,
        frame.rightHand.dx,
        frame.rightHand.dy,
      );
    canvas.drawPath(stretchPath, stretchPaint);
  }

  void _drawBeam(
    Canvas canvas,
    Offset start,
    Offset end, {
    double width = 10,
    double alpha = 1,
    Color? tint,
  }) {
    final beamRect = Rect.fromPoints(start, end).inflate(width + 4);
    canvas.drawLine(
      start + const Offset(3, 5),
      end + const Offset(3, 5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18 * alpha)
        ..strokeWidth = width + 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.26 * alpha),
            (tint ?? template.accent).withValues(alpha: 0.26 * alpha),
            Colors.black.withValues(alpha: 0.12 * alpha),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(beamRect)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start + const Offset(-1.5, -2),
      end + const Offset(-1.5, -2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14 * alpha)
        ..strokeWidth = math.max(2, width * 0.22)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawPanel(
    Canvas canvas,
    Rect rect, {
    double radius = 16,
    double alpha = 1,
    Color? tint,
  }) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.32), 10, false);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.24 * alpha),
            (tint ?? template.accent).withValues(alpha: 0.22 * alpha),
            Colors.black.withValues(alpha: 0.12 * alpha),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.12 * alpha),
    );
  }

  void _drawFigureShadow(
    Canvas canvas,
    _WorkoutFigureFrame frame,
    double floorY,
  ) {
    final center = Offset(
      (frame.leftFoot.dx + frame.rightFoot.dx) / 2 + 10,
      floorY + 10,
    );
    final shadowRect = Rect.fromCenter(
      center: center,
      width: 96 + (frame.leftFoot.dx - frame.rightFoot.dx).abs() * 0.8,
      height: 24,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  void _drawGhostFigure(Canvas canvas, _WorkoutFigureFrame frame, Color color) {
    final outlinePaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final torsoPath = _torsoPath(frame);

    canvas.drawPath(torsoPath, Paint()..color = color.withValues(alpha: 0.06));
    canvas.drawPath(
      torsoPath,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    for (final segment in [
      (frame.rightShoulder, frame.rightElbow),
      (frame.rightElbow, frame.rightHand),
      (frame.leftShoulder, frame.leftElbow),
      (frame.leftElbow, frame.leftHand),
      (frame.rightHip, frame.rightKnee),
      (frame.rightKnee, frame.rightFoot),
      (frame.leftHip, frame.leftKnee),
      (frame.leftKnee, frame.leftFoot),
    ]) {
      canvas.drawLine(segment.$1, segment.$2, outlinePaint);
    }
    canvas.drawCircle(
      frame.headCenter,
      frame.headRadius * 0.92,
      Paint()..color = color.withValues(alpha: 0.2),
    );
  }

  void _drawFigure(Canvas canvas, Size size, _WorkoutFigureFrame frame) {
    final accentLight = Color.lerp(Colors.white, template.accent, 0.18)!;
    final accentMid = Color.lerp(
      const Color(0xFFE2E8F0),
      template.accent,
      0.3,
    )!;
    final torsoPath = _torsoPath(frame);
    final torsoBounds = torsoPath.getBounds().inflate(12);

    canvas.drawCircle(
      frame.coreCenter,
      size.shortestSide * (0.1 + (frame.coreGlow * 0.09)),
      Paint()
        ..color = template.accent.withValues(alpha: frame.coreGlow * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawShadow(
      torsoPath,
      Colors.black.withValues(alpha: 0.38),
      14,
      false,
    );
    canvas.drawPath(
      torsoPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white,
            Color.lerp(Colors.white, template.accent, 0.32)!,
            Color.lerp(template.accent, const Color(0xFF0F172A), 0.24)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(torsoBounds),
    );
    canvas.drawPath(
      torsoPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    _drawLimb(
      canvas,
      frame.rightShoulder,
      frame.rightElbow,
      width: 14,
      fillColor: accentMid,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.rightElbow,
      frame.rightHand,
      width: 12,
      fillColor: accentMid,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.rightHip,
      frame.rightKnee,
      width: 16,
      fillColor: accentMid,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.rightKnee,
      frame.rightFoot,
      width: 14,
      fillColor: accentMid,
      highlightColor: Colors.white,
    );

    _drawHead(canvas, frame);

    _drawLimb(
      canvas,
      frame.leftShoulder,
      frame.leftElbow,
      width: 14,
      fillColor: accentLight,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.leftElbow,
      frame.leftHand,
      width: 12,
      fillColor: accentLight,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.leftHip,
      frame.leftKnee,
      width: 16,
      fillColor: accentLight,
      highlightColor: Colors.white,
    );
    _drawLimb(
      canvas,
      frame.leftKnee,
      frame.leftFoot,
      width: 14,
      fillColor: accentLight,
      highlightColor: Colors.white,
    );

    _drawFoot(canvas, frame.leftFoot, accentLight);
    _drawFoot(canvas, frame.rightFoot, accentMid);

    for (final point in [
      frame.leftShoulder,
      frame.rightShoulder,
      frame.leftHip,
      frame.rightHip,
      frame.leftKnee,
      frame.rightKnee,
    ]) {
      canvas.drawCircle(
        point,
        2.4,
        Paint()..color = template.accent.withValues(alpha: 0.46),
      );
    }
  }

  void _drawLimb(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double width,
    required Color fillColor,
    required Color highlightColor,
  }) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = width + 4
      ..strokeCap = StrokeCap.round;
    final basePaint = Paint()
      ..color = fillColor
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.54)
      ..strokeWidth = math.max(2, width * 0.28)
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      start + const Offset(3, 5),
      end + const Offset(3, 5),
      shadowPaint,
    );
    canvas.drawLine(start, end, basePaint);
    canvas.drawLine(
      start + Offset(-width * 0.08, -width * 0.12),
      end + Offset(-width * 0.08, -width * 0.12),
      highlightPaint,
    );
    canvas.drawCircle(start, width / 2.1, basePaint);
    canvas.drawCircle(end, width / 2.1, basePaint);
  }

  void _drawHead(Canvas canvas, _WorkoutFigureFrame frame) {
    canvas.drawCircle(
      frame.headCenter + const Offset(4, 6),
      frame.headRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      frame.headCenter,
      frame.headRadius,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white,
                const Color(0xFFE2E8F0),
                Color.lerp(template.accent, Colors.white, 0.4)!,
              ],
              stops: const [0, 0.72, 1],
            ).createShader(
              Rect.fromCircle(
                center: frame.headCenter,
                radius: frame.headRadius,
              ),
            ),
    );
    canvas.drawArc(
      Rect.fromCircle(center: frame.headCenter, radius: frame.headRadius),
      _degreesToRadians(212),
      _degreesToRadians(108),
      false,
      Paint()
        ..color = template.accent.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawFoot(Canvas canvas, Offset foot, Color color) {
    _drawLimb(
      canvas,
      foot + const Offset(-8, 3),
      foot + const Offset(12, 3),
      width: 7,
      fillColor: color,
      highlightColor: Colors.white,
    );
  }

  Path _torsoPath(_WorkoutFigureFrame frame) {
    return Path()
      ..moveTo(frame.leftShoulder.dx, frame.leftShoulder.dy)
      ..quadraticBezierTo(
        frame.shoulderCenter.dx,
        frame.shoulderCenter.dy - 8,
        frame.rightShoulder.dx,
        frame.rightShoulder.dy,
      )
      ..quadraticBezierTo(
        frame.rightHip.dx + 10,
        (frame.rightShoulder.dy + frame.rightHip.dy) / 2,
        frame.rightHip.dx,
        frame.rightHip.dy,
      )
      ..quadraticBezierTo(
        frame.hipCenter.dx,
        frame.hipCenter.dy + 8,
        frame.leftHip.dx,
        frame.leftHip.dy,
      )
      ..quadraticBezierTo(
        frame.leftHip.dx - 10,
        (frame.leftShoulder.dy + frame.leftHip.dy) / 2,
        frame.leftShoulder.dx,
        frame.leftShoulder.dy,
      )
      ..close();
  }

  _WorkoutFigureFrame _frameForPose(
    Size size,
    _WorkoutTechniquePose pose,
    double floorY,
  ) {
    final kind = _motionKindForTemplate(template);
    final center = Offset(size.width * 0.48, floorY - size.height * 0.28);
    final hipCenter = center + pose.hipOffset;
    final torsoLength = size.height * 0.21;
    final headGap = size.height * 0.07;
    final headRadius = size.shortestSide * 0.048;
    final shoulderSpread = size.width * 0.066;
    final hipSpread = size.width * 0.05;
    final upperArm = size.height * 0.11;
    final lowerArm = size.height * 0.105;
    final upperLeg = size.height * 0.145;
    final lowerLeg = size.height * 0.145;

    final shoulderCenter =
        hipCenter + _vectorFromAngle(pose.torsoAngle, torsoLength);
    final torsoPerp = Offset(
      -math.sin(pose.torsoAngle),
      math.cos(pose.torsoAngle),
    );
    final leftShoulder =
        shoulderCenter + _scaleOffset(torsoPerp, shoulderSpread);
    final rightShoulder =
        shoulderCenter - _scaleOffset(torsoPerp, shoulderSpread);
    final leftHip = hipCenter + _scaleOffset(torsoPerp, hipSpread);
    final rightHip = hipCenter - _scaleOffset(torsoPerp, hipSpread);
    Offset leftElbow =
        leftShoulder + _vectorFromAngle(pose.leftUpperArmAngle, upperArm);
    Offset rightElbow =
        rightShoulder + _vectorFromAngle(pose.rightUpperArmAngle, upperArm);
    Offset leftHand =
        leftElbow + _vectorFromAngle(pose.leftLowerArmAngle, lowerArm);
    Offset rightHand =
        rightElbow + _vectorFromAngle(pose.rightLowerArmAngle, lowerArm);
    final leftKnee =
        leftHip + _vectorFromAngle(pose.leftUpperLegAngle, upperLeg);
    final rightKnee =
        rightHip + _vectorFromAngle(pose.rightUpperLegAngle, upperLeg);
    final leftFoot =
        leftKnee + _vectorFromAngle(pose.leftLowerLegAngle, lowerLeg);
    final rightFoot =
        rightKnee + _vectorFromAngle(pose.rightLowerLegAngle, lowerLeg);
    final headCenter =
        shoulderCenter + _vectorFromAngle(pose.torsoAngle, headGap);

    switch (kind) {
      case _WorkoutMotionKind.fullBodyStrength:
      case _WorkoutMotionKind.lowerBodyCore:
        final loadCenter = Offset(
          shoulderCenter.dx + size.width * 0.01,
          shoulderCenter.dy + size.height * 0.055,
        );
        leftHand = loadCenter + Offset(size.width * 0.042, size.height * 0.008);
        rightHand =
            loadCenter - Offset(size.width * 0.042, size.height * 0.008);
        leftElbow =
            Offset.lerp(leftShoulder, leftHand, 0.55)! +
            Offset(-size.width * 0.015, size.height * 0.03);
        rightElbow =
            Offset.lerp(rightShoulder, rightHand, 0.55)! +
            Offset(size.width * 0.015, size.height * 0.03);
        break;
      case _WorkoutMotionKind.upperBodyStrength:
        final pressDrive = pose.coreGlow * 1.8;
        leftHand = Offset(
          shoulderCenter.dx + size.width * (0.08 + (pressDrive * 0.08)),
          shoulderCenter.dy - size.height * 0.01,
        );
        rightHand = Offset(
          shoulderCenter.dx + size.width * (0.04 + (pressDrive * 0.08)),
          shoulderCenter.dy + size.height * 0.045,
        );
        leftElbow =
            Offset.lerp(leftShoulder, leftHand, 0.48)! +
            Offset(size.width * 0.01, size.height * 0.02);
        rightElbow =
            Offset.lerp(rightShoulder, rightHand, 0.52)! +
            Offset(size.width * 0.012, size.height * 0.026);
        break;
      case _WorkoutMotionKind.mobility:
        leftHand = leftHand + Offset(-size.width * 0.01, -size.height * 0.008);
        rightHand = rightHand + Offset(size.width * 0.012, -size.height * 0.01);
        break;
      case _WorkoutMotionKind.hiit:
      case _WorkoutMotionKind.zone2:
        break;
    }

    final coreCenter = Offset(
      (shoulderCenter.dx + hipCenter.dx) / 2,
      (shoulderCenter.dy + hipCenter.dy) / 2,
    );

    return _WorkoutFigureFrame(
      hipCenter: hipCenter,
      shoulderCenter: shoulderCenter,
      headCenter: headCenter,
      coreCenter: coreCenter,
      leftShoulder: leftShoulder,
      rightShoulder: rightShoulder,
      leftElbow: leftElbow,
      rightElbow: rightElbow,
      leftHand: leftHand,
      rightHand: rightHand,
      leftHip: leftHip,
      rightHip: rightHip,
      leftKnee: leftKnee,
      rightKnee: rightKnee,
      leftFoot: leftFoot,
      rightFoot: rightFoot,
      headRadius: headRadius,
      coreGlow: pose.coreGlow,
    );
  }

  _WorkoutTechniquePose _poseForTemplate(double value) {
    final normalized = _wrapTechniqueProgress(value);
    switch (_motionKindForTemplate(template)) {
      case _WorkoutMotionKind.fullBodyStrength:
        final bend = 0.5 - (0.5 * math.cos(normalized * math.pi * 2));
        return _WorkoutTechniquePose(
          hipOffset: Offset(-4 * bend, 22 * bend),
          torsoAngle: _degreesToRadians(-92 + (bend * 28)),
          leftUpperArmAngle: _degreesToRadians(-18 + (bend * 18)),
          rightUpperArmAngle: _degreesToRadians(-30 + (bend * 18)),
          leftLowerArmAngle: _degreesToRadians(10 + (bend * 12)),
          rightLowerArmAngle: _degreesToRadians(0 + (bend * 8)),
          leftUpperLegAngle: _degreesToRadians(92 - (bend * 30)),
          rightUpperLegAngle: _degreesToRadians(88 - (bend * 26)),
          leftLowerLegAngle: _degreesToRadians(92 + (bend * 20)),
          rightLowerLegAngle: _degreesToRadians(88 + (bend * 18)),
          coreGlow: 0.12 + (bend * 0.18),
        );
      case _WorkoutMotionKind.upperBodyStrength:
        final drive = 0.5 - (0.5 * math.cos(normalized * math.pi * 2));
        return _WorkoutTechniquePose(
          hipOffset: Offset(0, 4 * math.sin(normalized * math.pi * 2)),
          torsoAngle: _degreesToRadians(-90),
          leftUpperArmAngle: _degreesToRadians(-28 - (drive * 52)),
          rightUpperArmAngle: _degreesToRadians(-42 - (drive * 52)),
          leftLowerArmAngle: _degreesToRadians(-6 - (drive * 70)),
          rightLowerArmAngle: _degreesToRadians(-18 - (drive * 70)),
          leftUpperLegAngle: _degreesToRadians(92),
          rightUpperLegAngle: _degreesToRadians(88),
          leftLowerLegAngle: _degreesToRadians(92),
          rightLowerLegAngle: _degreesToRadians(88),
          coreGlow: 0.12 + (drive * 0.1),
        );
      case _WorkoutMotionKind.lowerBodyCore:
        final squat = 0.5 - (0.5 * math.cos(normalized * math.pi * 2));
        return _WorkoutTechniquePose(
          hipOffset: Offset(-2 * squat, 26 * squat),
          torsoAngle: _degreesToRadians(-92 + (squat * 16)),
          leftUpperArmAngle: _degreesToRadians(-28 + (squat * 26)),
          rightUpperArmAngle: _degreesToRadians(-38 + (squat * 24)),
          leftLowerArmAngle: _degreesToRadians(2 + (squat * 18)),
          rightLowerArmAngle: _degreesToRadians(-6 + (squat * 14)),
          leftUpperLegAngle: _degreesToRadians(95 - (squat * 34)),
          rightUpperLegAngle: _degreesToRadians(90 - (squat * 30)),
          leftLowerLegAngle: _degreesToRadians(95 + (squat * 20)),
          rightLowerLegAngle: _degreesToRadians(90 + (squat * 18)),
          coreGlow: 0.18 + (squat * 0.22),
        );
      case _WorkoutMotionKind.hiit:
        final stride = math.sin(normalized * math.pi * 2);
        final rebound = 0.5 - (0.5 * math.cos(normalized * math.pi * 4));
        return _WorkoutTechniquePose(
          hipOffset: Offset(0, -6 + (rebound * 10)),
          torsoAngle: _degreesToRadians(-84 + (stride * 4)),
          leftUpperArmAngle: _degreesToRadians(-40 - (stride * 34)),
          rightUpperArmAngle: _degreesToRadians(20 - (stride * 34)),
          leftLowerArmAngle: _degreesToRadians(-10 - (stride * 42)),
          rightLowerArmAngle: _degreesToRadians(48 - (stride * 42)),
          leftUpperLegAngle: _degreesToRadians(70 + (stride * 26)),
          rightUpperLegAngle: _degreesToRadians(104 + (stride * 26)),
          leftLowerLegAngle: _degreesToRadians(118 + (stride * 20)),
          rightLowerLegAngle: _degreesToRadians(78 + (stride * 20)),
          coreGlow: 0.12 + (rebound * 0.12),
        );
      case _WorkoutMotionKind.zone2:
        final stride = math.sin(normalized * math.pi * 2);
        return _WorkoutTechniquePose(
          hipOffset: Offset(0, 4 * math.sin(normalized * math.pi * 4)),
          torsoAngle: _degreesToRadians(-90 + (stride * 2)),
          leftUpperArmAngle: _degreesToRadians(-48 - (stride * 18)),
          rightUpperArmAngle: _degreesToRadians(8 - (stride * 18)),
          leftLowerArmAngle: _degreesToRadians(-20 - (stride * 22)),
          rightLowerArmAngle: _degreesToRadians(34 - (stride * 22)),
          leftUpperLegAngle: _degreesToRadians(82 + (stride * 16)),
          rightUpperLegAngle: _degreesToRadians(98 + (stride * 16)),
          leftLowerLegAngle: _degreesToRadians(102 + (stride * 14)),
          rightLowerLegAngle: _degreesToRadians(80 + (stride * 14)),
          coreGlow: 0.08,
        );
      case _WorkoutMotionKind.mobility:
        final reach = 0.5 - (0.5 * math.cos(normalized * math.pi * 2));
        return _WorkoutTechniquePose(
          hipOffset: Offset(0, 6 * math.sin(normalized * math.pi * 2)),
          torsoAngle: _degreesToRadians(-96 + (reach * 12)),
          leftUpperArmAngle: _degreesToRadians(-122 + (reach * 24)),
          rightUpperArmAngle: _degreesToRadians(-78 - (reach * 18)),
          leftLowerArmAngle: _degreesToRadians(-138 + (reach * 26)),
          rightLowerArmAngle: _degreesToRadians(-104 - (reach * 12)),
          leftUpperLegAngle: _degreesToRadians(92),
          rightUpperLegAngle: _degreesToRadians(88),
          leftLowerLegAngle: _degreesToRadians(92),
          rightLowerLegAngle: _degreesToRadians(88),
          coreGlow: 0.1 + (reach * 0.08),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutTechniquePainter oldDelegate) {
    return oldDelegate.template != template ||
        oldDelegate.progress != progress ||
        oldDelegate.showMotionEchoes != showMotionEchoes ||
        oldDelegate.showBackdrop != showBackdrop;
  }
}

class _WorkoutFigureFrame {
  const _WorkoutFigureFrame({
    required this.hipCenter,
    required this.shoulderCenter,
    required this.headCenter,
    required this.coreCenter,
    required this.leftShoulder,
    required this.rightShoulder,
    required this.leftElbow,
    required this.rightElbow,
    required this.leftHand,
    required this.rightHand,
    required this.leftHip,
    required this.rightHip,
    required this.leftKnee,
    required this.rightKnee,
    required this.leftFoot,
    required this.rightFoot,
    required this.headRadius,
    required this.coreGlow,
  });

  final Offset hipCenter;
  final Offset shoulderCenter;
  final Offset headCenter;
  final Offset coreCenter;
  final Offset leftShoulder;
  final Offset rightShoulder;
  final Offset leftElbow;
  final Offset rightElbow;
  final Offset leftHand;
  final Offset rightHand;
  final Offset leftHip;
  final Offset rightHip;
  final Offset leftKnee;
  final Offset rightKnee;
  final Offset leftFoot;
  final Offset rightFoot;
  final double headRadius;
  final double coreGlow;
}

class _WorkoutTechniquePose {
  const _WorkoutTechniquePose({
    required this.hipOffset,
    required this.torsoAngle,
    required this.leftUpperArmAngle,
    required this.rightUpperArmAngle,
    required this.leftLowerArmAngle,
    required this.rightLowerArmAngle,
    required this.leftUpperLegAngle,
    required this.rightUpperLegAngle,
    required this.leftLowerLegAngle,
    required this.rightLowerLegAngle,
    required this.coreGlow,
  });

  final Offset hipOffset;
  final double torsoAngle;
  final double leftUpperArmAngle;
  final double rightUpperArmAngle;
  final double leftLowerArmAngle;
  final double rightLowerArmAngle;
  final double leftUpperLegAngle;
  final double rightUpperLegAngle;
  final double leftLowerLegAngle;
  final double rightLowerLegAngle;
  final double coreGlow;
}

enum _WorkoutMotionKind {
  fullBodyStrength,
  upperBodyStrength,
  lowerBodyCore,
  hiit,
  zone2,
  mobility,
}

_WorkoutMotionKind _motionKindForTemplate(WorkoutTemplate template) {
  switch (template.id) {
    case 'upper-body-strength':
      return _WorkoutMotionKind.upperBodyStrength;
    case 'lower-body-core':
      return _WorkoutMotionKind.lowerBodyCore;
    case 'hiit-conditioning':
      return _WorkoutMotionKind.hiit;
    case 'zone-2-cardio':
      return _WorkoutMotionKind.zone2;
    case 'mobility-recovery':
      return _WorkoutMotionKind.mobility;
    default:
      return _WorkoutMotionKind.fullBodyStrength;
  }
}

double _wrapTechniqueProgress(double value) {
  final normalized = value % 1;
  return normalized < 0 ? normalized + 1 : normalized;
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180;

Offset _vectorFromAngle(double angle, double length) {
  return Offset(math.cos(angle) * length, math.sin(angle) * length);
}

Offset _scaleOffset(Offset value, double factor) {
  return Offset(value.dx * factor, value.dy * factor);
}

// ignore: unused_element
class _WorkoutStageBadge extends StatelessWidget {
  const _WorkoutStageBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
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
}

class _WorkoutTemplateVisual extends StatelessWidget {
  const _WorkoutTemplateVisual({
    required this.template,
    this.headline = 'Resumen del entrenamiento',
    this.supportingText =
        'Revisa los puntos clave del ejercicio antes de registrar la sesion.',
    this.showDefaultBadges = true,
    this.animatePreview = true,
    this.showPreview = true,
  });

  final WorkoutTemplate template;
  final String headline;
  final String supportingText;
  final bool showDefaultBadges;
  final bool animatePreview;
  final bool showPreview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final previewSize = compact ? 124.0 : 152.0;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                template.accent,
                template.accent.withValues(alpha: 0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showPreview) ...[
                _WorkoutVisualHeader(
                  template: template,
                  headline: headline,
                  supportingText: supportingText,
                ),
              ] else if (compact) ...[
                _WorkoutVisualHeader(
                  template: template,
                  headline: headline,
                  supportingText: supportingText,
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: previewSize,
                    height: previewSize,
                    child: animatePreview
                        ? _AnimatedWorkoutPreview(template: template)
                        : _StaticWorkoutPreview(template: template),
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _WorkoutVisualHeader(
                        template: template,
                        headline: headline,
                        supportingText: supportingText,
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: previewSize,
                      height: previewSize,
                      child: animatePreview
                          ? _AnimatedWorkoutPreview(template: template)
                          : _StaticWorkoutPreview(template: template),
                    ),
                  ],
                ),
              if (showDefaultBadges) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WorkoutVisualBadge(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Vista animada',
                    ),
                    ...template.targetZones
                        .take(2)
                        .map(
                          (zone) => _WorkoutVisualBadge(
                            icon: Icons.my_location_outlined,
                            label: zone,
                          ),
                        ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WorkoutVisualHeader extends StatelessWidget {
  const _WorkoutVisualHeader({
    required this.template,
    required this.headline,
    this.supportingText,
  });

  final WorkoutTemplate template;
  final String headline;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final isCompact = supportingText == null || supportingText!.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 34 : 42,
          height: isCompact ? 34 : 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            template.icon,
            color: Colors.white,
            size: isCompact ? 18 : 24,
          ),
        ),
        SizedBox(height: isCompact ? 6 : 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 11 : 13,
              ),
            ),
            SizedBox(height: isCompact ? 2 : 4),
            Text(
              headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: isCompact ? 16 : 18,
                height: isCompact ? 1.0 : 1.08,
              ),
            ),
            if (supportingText != null && supportingText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                supportingText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AnimatedWorkoutPreview extends StatefulWidget {
  const _AnimatedWorkoutPreview({required this.template});

  final WorkoutTemplate template;

  @override
  State<_AnimatedWorkoutPreview> createState() =>
      _AnimatedWorkoutPreviewState();
}

class _AnimatedWorkoutPreviewState extends State<_AnimatedWorkoutPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final wave = math.sin(_controller.value * math.pi * 2);
        final lift = math.sin(_controller.value * math.pi).abs();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              ..._buildPreviewAccents(wave, lift),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPreviewAccents(double wave, double lift) {
    final accent = widget.template.accent;
    switch (widget.template.id) {
      case 'hiit-conditioning':
        return [
          Transform.translate(
            offset: Offset(wave * 18, 0),
            child: const Icon(
              Icons.directions_run_rounded,
              size: 78,
              color: Colors.white,
            ),
          ),
          Transform.translate(
            offset: Offset(32, -28 + (wave * 6)),
            child: Icon(Icons.bolt_rounded, color: accent, size: 34),
          ),
          Positioned(
            bottom: 24,
            child: Container(
              width: 84,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
      case 'zone-2-cardio':
        return [
          Transform.translate(
            offset: Offset(wave * 14, 0),
            child: const Icon(
              Icons.directions_walk_rounded,
              size: 74,
              color: Colors.white,
            ),
          ),
          Transform.scale(
            scale: 0.9 + (lift * 0.18),
            child: Icon(Icons.favorite_rounded, color: accent, size: 30),
          ),
          Positioned(
            bottom: 18,
            child: Container(
              width: 92,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
      case 'mobility-recovery':
        return [
          Transform.rotate(
            angle: wave * 0.18,
            child: const Icon(
              Icons.self_improvement_rounded,
              size: 82,
              color: Colors.white,
            ),
          ),
          Transform.translate(
            offset: Offset(0, 38 - (lift * 10)),
            child: Container(
              width: 76,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
      case 'lower-body-core':
        return [
          Transform.translate(
            offset: Offset(0, wave * 12),
            child: const Icon(
              Icons.accessibility_new_rounded,
              size: 84,
              color: Colors.white,
            ),
          ),
          Transform.translate(
            offset: Offset(0, 42 - (lift * 8)),
            child: Container(
              width: 86,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
      default:
        return [
          Transform.translate(
            offset: Offset(0, -lift * 14),
            child: const Icon(
              Icons.accessibility_new_rounded,
              size: 84,
              color: Colors.white,
            ),
          ),
          Transform.translate(
            offset: Offset(0, -22 - (lift * 10)),
            child: Container(
              width: 82,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            child: Container(
              width: 92,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
    }
  }
}

class _StaticWorkoutPreview extends StatelessWidget {
  const _StaticWorkoutPreview({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(template.icon, size: 56, color: Colors.white),
              const SizedBox(height: 10),
              Container(
                width: 86,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                template.demoExercise,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutVisualBadge extends StatelessWidget {
  const _WorkoutVisualBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
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
}

class _TemplateSection extends StatelessWidget {
  const _TemplateSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DisposeControllersOnUnmount extends StatefulWidget {
  const _DisposeControllersOnUnmount({
    required this.controllers,
    required this.child,
  });

  final List<TextEditingController> controllers;
  final Widget child;

  @override
  State<_DisposeControllersOnUnmount> createState() =>
      _DisposeControllersOnUnmountState();
}

class _DisposeControllersOnUnmountState
    extends State<_DisposeControllersOnUnmount> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Modal para crear un entrenamiento.
Future<void> showWorkoutSheet(
  BuildContext context,
  FitnessStore store, {
  String? presetName,
  String? presetCategory,
  int? presetDurationMinutes,
  int? presetCaloriesBurned,
  WorkoutIntensity? presetIntensity,
  DateTime? presetDate,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: presetName ?? '');
  final categoryController = TextEditingController(
    text: presetCategory ?? 'General',
  );
  final durationController = TextEditingController(
    text: (presetDurationMinutes ?? 30).toString(),
  );
  final caloriesController = TextEditingController(
    text: (presetCaloriesBurned ?? 250).toString(),
  );
  var selectedDateTime = presetDate ?? DateTime.now();
  var intensity = presetIntensity ?? WorkoutIntensity.medium;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _DisposeControllersOnUnmount(
        controllers: [
          nameController,
          categoryController,
          durationController,
          caloriesController,
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
                        'Nuevo entrenamiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Duración (min)',
                              ),
                              validator: _positiveIntValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WorkoutIntensity>(
                        initialValue: intensity,
                        decoration: const InputDecoration(
                          labelText: 'Intensidad',
                        ),
                        items: WorkoutIntensity.values
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
                            intensity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
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

                            store.addWorkout(
                              name: nameController.text.trim(),
                              category: categoryController.text.trim(),
                              durationMinutes: int.parse(
                                durationController.text.trim(),
                              ),
                              caloriesBurned: int.parse(
                                caloriesController.text.trim(),
                              ),
                              date: selectedDateTime,
                              intensity: intensity,
                            );

                            FocusScope.of(sheetContext).unfocus();
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Guardar entrenamiento'),
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
