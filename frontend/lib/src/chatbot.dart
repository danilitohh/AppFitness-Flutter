part of '../main.dart';

// -----------------------------------------------------------------------------
// Chatbot guiado.
// Mantiene el historial de mensajes y navega por opciones seleccionables.
// -----------------------------------------------------------------------------
/// Mensaje individual dentro del historial de chat.
class _ChatbotMessage {
  const _ChatbotMessage({
    required this.text,
    required this.isUser,
    this.options = const <_ChatbotOptionNode>[],
    this.showBack = false,
    this.showHome = false,
  });

  final String text;
  final bool isUser;
  final List<_ChatbotOptionNode> options;
  final bool showBack;
  final bool showHome;

  bool get hasOptions => options.isNotEmpty || showBack || showHome;
}

class _ChatbotOptionNode {
  const _ChatbotOptionNode({
    required this.label,
    this.prompt,
    this.children = const <_ChatbotOptionNode>[],
  });

  final String label;
  final String? prompt;
  final List<_ChatbotOptionNode> children;

  bool get hasChildren => children.isNotEmpty;
}

enum _ChatTopic {
  none,
  summary,
  pending,
  habits,
  recommendations,
  water,
  nutrition,
  macros,
  workout,
  weight,
  goals,
  motivation,
  appHelp,
}

class _DayStats {
  const _DayStats({
    required this.date,
    required this.calories,
    required this.waterMl,
    required this.workoutMinutes,
    required this.mealsLogged,
  });

  final DateTime date;
  final int calories;
  final int waterMl;
  final int workoutMinutes;
  final int mealsLogged;
}

class _HabitSnapshot {
  const _HabitSnapshot({
    required this.days,
    required this.waterGoalHitDays,
    required this.workoutDays,
    required this.mealLogDays,
    required this.calorieBalancedDays,
    required this.totalWorkoutMinutes,
    required this.averageWaterMl,
    required this.hydrationLabel,
    required this.workoutLabel,
    required this.calorieBalanceLabel,
    required this.isCalorieOffTrack,
    required this.weeklyWeightDelta,
  });

  final int days;
  final int waterGoalHitDays;
  final int workoutDays;
  final int mealLogDays;
  final int calorieBalancedDays;
  final int totalWorkoutMinutes;
  final int averageWaterMl;
  final String hydrationLabel;
  final String workoutLabel;
  final String calorieBalanceLabel;
  final bool isCalorieOffTrack;
  final double weeklyWeightDelta;
}

/// Modal del chatbot fitness.
class _SimpleChatbotSheet extends StatefulWidget {
  const _SimpleChatbotSheet({required this.store, this.userFirstName});

  final FitnessStore store;
  final String? userFirstName;

  @override
  State<_SimpleChatbotSheet> createState() => _SimpleChatbotSheetState();
}

class _SimpleChatbotSheetState extends State<_SimpleChatbotSheet> {
  final ScrollController _scrollController = ScrollController();
  final List<_ChatbotOptionNode> _optionPath = <_ChatbotOptionNode>[];
  late final List<_ChatbotMessage> _messages;
  late List<_ChatbotOptionNode> _activeQuestionOptions;
  bool _isTyping = false;
  _ChatTopic _lastTopic = _ChatTopic.none;

  static const List<String> _domainKeywords = [
    'resumen',
    'agua',
    'hidratacion',
    'caloria',
    'calorias',
    'kcal',
    'macro',
    'macros',
    'proteina',
    'carbo',
    'carbos',
    'grasa',
    'grasas',
    'entreno',
    'entrenamiento',
    'ejercicio',
    'rutina',
    'cardio',
    'fuerza',
    'peso',
    'meta',
    'metas',
    'objetivo',
    'objetivos',
    'comida',
    'alimento',
    'nutricion',
    'dieta',
    'habito',
    'habitos',
    'tendencia',
    'tendencias',
    'recomendacion',
    'recomendaciones',
    'consejo',
    'consejos',
    'progreso',
  ];

  static const List<_ChatbotOptionNode> _guidedQuestionOptions = [
    _ChatbotOptionNode(
      label: 'Progreso diario',
      children: [
        _ChatbotOptionNode(
          label: 'Resumen general',
          children: [
            _ChatbotOptionNode(
              label: 'Resumen de hoy',
              prompt: 'resumen de hoy',
            ),
            _ChatbotOptionNode(
              label: 'Que me falta hoy',
              prompt: 'me falta hoy',
            ),
          ],
        ),
        _ChatbotOptionNode(
          label: 'Nutricion',
          children: [
            _ChatbotOptionNode(
              label: 'Como voy de agua',
              prompt: 'como voy de agua',
            ),
            _ChatbotOptionNode(
              label: 'Como voy de calorias',
              prompt: 'como voy de calorias',
            ),
            _ChatbotOptionNode(
              label: 'Como voy de macros',
              prompt: 'como voy de macros',
            ),
          ],
        ),
        _ChatbotOptionNode(
          label: 'Entreno y peso',
          children: [
            _ChatbotOptionNode(
              label: 'Entreno de hoy',
              prompt: 'entreno de hoy',
            ),
            _ChatbotOptionNode(
              label: 'Progreso de peso',
              prompt: 'progreso de peso',
            ),
            _ChatbotOptionNode(label: 'Mis metas', prompt: 'mis metas'),
          ],
        ),
      ],
    ),
    _ChatbotOptionNode(
      label: 'Habitos y mejoras',
      children: [
        _ChatbotOptionNode(
          label: 'Habitos semanales',
          prompt: 'habitos semanales',
        ),
        _ChatbotOptionNode(label: 'Recomendaciones', prompt: 'recomendaciones'),
        _ChatbotOptionNode(label: 'Estoy estancado', prompt: 'estoy estancado'),
        _ChatbotOptionNode(label: 'Motivacion', prompt: 'motivacion'),
      ],
    ),
    _ChatbotOptionNode(
      label: 'Registrar en la app',
      children: [
        _ChatbotOptionNode(
          label: 'Registrar peso',
          prompt: 'donde registrar peso',
        ),
        _ChatbotOptionNode(
          label: 'Registrar comida',
          prompt: 'donde registrar comida',
        ),
        _ChatbotOptionNode(
          label: 'Registrar entreno',
          prompt: 'donde registrar entreno',
        ),
      ],
    ),
    _ChatbotOptionNode(
      label: 'Bienestar',
      children: [
        _ChatbotOptionNode(
          label: 'Recuperacion',
          children: [
            _ChatbotOptionNode(
              label: 'Calentamiento y movilidad',
              prompt: 'calentamiento',
            ),
            _ChatbotOptionNode(
              label: 'Descanso y recuperacion',
              prompt: 'descanso',
            ),
            _ChatbotOptionNode(label: 'Sueno', prompt: 'como dormir mejor'),
          ],
        ),
        _ChatbotOptionNode(
          label: 'Sensaciones',
          children: [
            _ChatbotOptionNode(label: 'Tengo hambre', prompt: 'tengo hambre'),
            _ChatbotOptionNode(label: 'Tengo sed', prompt: 'tengo sed'),
            _ChatbotOptionNode(label: 'Estoy cansado', prompt: 'estoy cansado'),
            _ChatbotOptionNode(
              label: 'Me siento estresado',
              prompt: 'estoy estresado',
            ),
          ],
        ),
        _ChatbotOptionNode(
          label: 'Alertas',
          children: [
            _ChatbotOptionNode(
              label: 'Dolor fuerte o lesion',
              prompt: 'tengo una lesion',
            ),
          ],
        ),
      ],
    ),
    _ChatbotOptionNode(
      label: 'Sobre la app',
      children: [
        _ChatbotOptionNode(label: 'Que puedes hacer', prompt: 'ayuda'),
        _ChatbotOptionNode(
          label: 'Objetivo del proyecto',
          prompt: 'objetivo del proyecto',
        ),
        _ChatbotOptionNode(label: 'Tecnologia', prompt: 'tecnologia'),
        _ChatbotOptionNode(label: 'Integracion', prompt: 'integracion'),
      ],
    ),
    _ChatbotOptionNode(
      label: 'Conversacion',
      children: [
        _ChatbotOptionNode(label: 'Hola', prompt: 'hola'),
        _ChatbotOptionNode(label: 'Como estas', prompt: 'como estas'),
        _ChatbotOptionNode(label: 'Quien eres', prompt: 'quien eres'),
        _ChatbotOptionNode(label: 'Gracias', prompt: 'gracias'),
        _ChatbotOptionNode(label: 'Adios', prompt: 'adios'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Primer mensaje contextual del asistente.
    _messages = [_ChatbotMessage(text: _buildWelcomeMessage(), isUser: false)];
    _activeQuestionOptions = _guidedQuestionOptions;
    _messages.add(_buildQuestionOptionsMessage());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.78;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: maxHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Asistente fitness',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const _ChatBubble(
                      text: 'Escribiendo...',
                      isUser: false,
                    );
                  }

                  final message = _messages[index];
                  if (message.hasOptions && !message.isUser) {
                    return _ChatOptionsBubble(
                      message: message,
                      onOptionTap: _isTyping ? null : _handleQuestionOption,
                      onBackTap: _isTyping ? null : _goToPreviousQuestionLevel,
                      onHomeTap: _isTyping ? null : _resetQuestionOptions,
                    );
                  }
                  return _ChatBubble(
                    text: message.text,
                    isUser: message.isUser,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuestionOption(_ChatbotOptionNode node) {
    if (node.hasChildren) {
      setState(() {
        _removeTrailingOptionsMessage();
        _messages.add(_ChatbotMessage(text: node.label, isUser: true));
        _optionPath.add(node);
        _activeQuestionOptions = node.children;
        _messages.add(_buildQuestionOptionsMessage());
      });
      _scrollToBottom();
      return;
    }

    final prompt = node.prompt ?? node.label;
    _submitMessage(userText: node.label, responseInput: prompt);
  }

  void _goToPreviousQuestionLevel() {
    if (_optionPath.isEmpty) {
      return;
    }

    setState(() {
      _removeTrailingOptionsMessage();
      _optionPath.removeLast();
      _activeQuestionOptions = _optionPath.isEmpty
          ? _guidedQuestionOptions
          : _optionPath.last.children;
      _messages.add(_buildQuestionOptionsMessage());
    });
    _scrollToBottom();
  }

  void _resetQuestionOptions() {
    setState(() {
      _removeTrailingOptionsMessage();
      _resetQuestionOptionsState();
      _messages.add(_buildQuestionOptionsMessage());
    });
    _scrollToBottom();
  }

  void _submitMessage({
    required String userText,
    required String responseInput,
  }) {
    // Agrega mensaje del usuario y responde con un pequeno delay.
    setState(() {
      _removeTrailingOptionsMessage();
      _messages.add(_ChatbotMessage(text: userText, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatbotMessage(text: _botResponse(responseInput), isUser: false),
        );
        _messages.add(_buildQuestionOptionsMessage());
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  _ChatbotMessage _buildQuestionOptionsMessage() {
    final atRoot = _optionPath.isEmpty;
    final text = atRoot
        ? 'Selecciona una categoria para continuar.'
        : 'Elige una opcion de ${_optionPath.map((node) => node.label).join(' / ')}.';

    return _ChatbotMessage(
      text: text,
      isUser: false,
      options: List<_ChatbotOptionNode>.from(_activeQuestionOptions),
      showBack: !atRoot,
      showHome: !atRoot,
    );
  }

  void _removeTrailingOptionsMessage() {
    if (_messages.isEmpty) {
      return;
    }
    final lastMessage = _messages.last;
    if (!lastMessage.isUser && lastMessage.hasOptions) {
      _messages.removeLast();
    }
  }

  void _resetQuestionOptionsState() {
    _optionPath.clear();
    _activeQuestionOptions = _guidedQuestionOptions;
  }

  String _botResponse(String input) {
    // Motor de reglas por palabras clave para respuestas fitness.
    final question = _normalizeText(input);
    final hasDomainKeywords = _containsAny(question, _domainKeywords);

    if (_containsAny(question, [
      'salir',
      'adios',
      'hasta luego',
      'nos vemos',
    ])) {
      _lastTopic = _ChatTopic.none;
      return 'Gracias por conversar conmigo. Exitos con tus metas fitness.';
    }

    if (_containsAny(question, ['gracias', 'muchas gracias'])) {
      _lastTopic = _ChatTopic.none;
      return 'De nada. Si quieres, te ayudo a ajustar entreno, comida o progreso.';
    }

    if (_containsAny(question, [
          'hola',
          'buenas',
          'hey',
          'buenos dias',
          'buenas tardes',
          'buenas noches',
        ]) &&
        !hasDomainKeywords) {
      _lastTopic = _ChatTopic.none;
      return _buildWelcomeMessage();
    }

    if (_containsAny(question, ['ayuda', 'que puedes', 'que haces'])) {
      _lastTopic = _ChatTopic.appHelp;
      return _buildHelpMessage();
    }

    if (_containsAny(question, [
      'habito',
      'habitos',
      'tendencia',
      'tendencias',
      'patron',
      'patrones',
      'semanal',
      'semana',
    ])) {
      _lastTopic = _ChatTopic.habits;
      return _buildHabitsSummary();
    }

    if (_containsAny(question, [
      'recomendacion',
      'recomendaciones',
      'consejo',
      'consejos',
      'sugerencia',
      'sugerencias',
      'que mejorar',
      'priorizar',
    ])) {
      _lastTopic = _ChatTopic.recommendations;
      return _buildRecommendations();
    }

    if (_containsAny(question, ['resumen de hoy', 'como voy', 'estado hoy'])) {
      _lastTopic = _ChatTopic.summary;
      return _buildDailySummary();
    }

    if (_containsAny(question, ['falta', 'pendiente', 'resta', 'me falta'])) {
      _lastTopic = _ChatTopic.pending;
      return _buildPendingMessage();
    }

    if (_containsAny(question, ['dashboard', 'inicio', 'pantalla principal'])) {
      _lastTopic = _ChatTopic.summary;
      return _buildDailySummary();
    }

    if (_containsAny(question, ['objetivo del proyecto'])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'El objetivo de esta app es ayudarte a registrar tus habitos y progreso para mejorar tu salud y rendimiento.';
    }

    if (_containsAny(question, ['tecnologia', 'tecnologias'])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'La app esta desarrollada en Flutter y Dart para funcionar en movil de forma rapida y consistente.';
    }

    if (_containsAny(question, ['integracion'])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'La integracion del chatbot conecta tus dudas frecuentes con recomendaciones practicas dentro de la app.';
    }

    if (_containsAny(question, ['peso']) &&
        _containsAny(question, [
          'registrar',
          'agregar',
          'guardar',
          'donde',
          'anotar',
        ])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'Para registrar peso: entra a Progreso y toca el boton de Peso. Idealmente pesate siempre a la misma hora para comparar mejor.';
    }

    if (_containsAny(question, ['comida', 'alimento', 'meal']) &&
        _containsAny(question, [
          'registrar',
          'agregar',
          'guardar',
          'donde',
          'anotar',
        ])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'Para registrar comida: entra a Comidas y toca el boton de Comida. Puedes guardar calorias, macros y la hora real para que el seguimiento sea mas preciso.';
    }

    if (_containsAny(question, [
          'entreno',
          'entrenamiento',
          'ejercicio',
          'rutina',
        ]) &&
        _containsAny(question, [
          'registrar',
          'agregar',
          'guardar',
          'donde',
          'anotar',
          'nuevo',
        ])) {
      _lastTopic = _ChatTopic.appHelp;
      return 'Para registrar entreno: entra a Entreno y toca el boton Entreno. Se abrira la biblioteca de rutinas para elegir un tipo de sesion, revisar como se hace y guardar tambien la hora.';
    }

    if (_containsAny(question, ['agua', 'hidratacion', 'hidratar'])) {
      _lastTopic = _ChatTopic.water;
      return _buildWaterProgressMessage();
    }

    if (_containsAny(question, [
      'proteina',
      'proteinas',
      'macro',
      'macros',
      'carbo',
      'carbos',
      'grasa',
      'grasas',
    ])) {
      _lastTopic = _ChatTopic.macros;
      return _buildMacroProgressMessage();
    }

    if (_containsAny(question, [
      'caloria',
      'calorias',
      'kcal',
      'deficit',
      'superavit',
    ])) {
      _lastTopic = _ChatTopic.nutrition;
      return _buildNutritionProgressMessage();
    }

    if (_containsAny(question, [
      'nutricion',
      'dieta',
      'comer',
      'alimentacion',
    ])) {
      _lastTopic = _ChatTopic.nutrition;
      return _buildNutritionProgressMessage();
    }

    if (_containsAny(question, [
      'entreno',
      'entrenamiento',
      'ejercicio',
      'rutina',
      'cardio',
      'fuerza',
      'musculo',
    ])) {
      _lastTopic = _ChatTopic.workout;
      return _buildWorkoutProgressMessage();
    }

    if (_containsAny(question, [
      'calentamiento',
      'estiramiento',
      'movilidad',
    ])) {
      _lastTopic = _ChatTopic.workout;
      return 'Haz 5-10 min de calentamiento antes de entrenar (movilidad + activacion). Al final, baja pulsaciones y estira suave para recuperarte mejor.';
    }

    if (_containsAny(question, [
      'descanso',
      'recuperacion',
      'dolor muscular',
    ])) {
      _lastTopic = _ChatTopic.workout;
      return 'Incluye al menos 1-2 dias de descanso por semana. Tu racha actual es de ${widget.store.workoutStreak} dias; recuperarte bien tambien es parte del progreso.';
    }

    if (_containsAny(question, ['lesion', 'dolor fuerte', 'mareo', 'pecho'])) {
      _lastTopic = _ChatTopic.workout;
      return 'Si tienes dolor fuerte, mareo o sintomas preocupantes, detente y consulta a un profesional de salud. Este chat no reemplaza evaluacion medica.';
    }

    if (_containsAny(question, ['sueno', 'dormir', 'insomnio'])) {
      _lastTopic = _ChatTopic.motivation;
      return 'Apunta a 7-9 horas de sueno. Mantener horario regular mejora recuperacion, hambre y rendimiento en entrenamiento.';
    }

    if (_containsAny(question, [
      'estancado',
      'no avanzo',
      'plateau',
      'progreso',
    ])) {
      _lastTopic = _ChatTopic.weight;
      return _buildProgressMessage();
    }

    if (_containsAny(question, ['peso', 'bajar de peso', 'subir de peso'])) {
      _lastTopic = _ChatTopic.weight;
      return _buildWeightProgressMessage();
    }

    if (_containsAny(question, ['meta', 'metas', 'objetivo', 'objetivos'])) {
      _lastTopic = _ChatTopic.goals;
      return _buildGoalsMessage();
    }

    if (_containsAny(question, [
      'motivacion',
      'constancia',
      'disciplina',
      'habito',
    ])) {
      _lastTopic = _ChatTopic.motivation;
      return _buildMotivationMessage();
    }

    final smallTalk = _buildSmallTalkResponse(question);
    if (smallTalk != null) {
      return smallTalk;
    }

    if (_isFollowUp(question) && _lastTopic != _ChatTopic.none) {
      return _buildFollowUpResponse();
    }

    if (_looksLikeQuestion(question)) {
      _lastTopic = _ChatTopic.none;
      return _buildGenericQuestionResponse();
    }

    _lastTopic = _ChatTopic.none;
    return 'No tengo una respuesta exacta para eso aun. Prueba con: "resumen de hoy", "como voy de agua", "como voy de calorias", "entreno de hoy" o "progreso de peso".';
  }

  String _buildWelcomeMessage() {
    final name = widget.userFirstName?.trim();
    final greeting = name != null && name.isNotEmpty ? 'Hola, $name.' : 'Hola.';
    return '$greeting Soy tu asistente fitness. Puedes pedirme un resumen de hoy o preguntar por agua, calorias, macros, entreno y peso.';
  }

  String _buildHelpMessage() {
    return 'Te puedo ayudar con:\n- Resumen personalizado de hoy\n- Agua, calorias y macros\n- Entreno y constancia\n- Peso, metas y progreso\n- Como usar la app para registrar datos';
  }

  String _buildHabitsSummary() {
    final snapshot = _buildHabitSnapshot();
    final weightLine = _buildWeeklyWeightLine(snapshot.weeklyWeightDelta);

    return 'Habitos de los ultimos ${snapshot.days} dias:\n'
        '- Hidratacion: ${snapshot.waterGoalHitDays}/${snapshot.days} dias en meta '
        '(promedio ${snapshot.averageWaterMl} ml/dia). ${snapshot.hydrationLabel}\n'
        '- Entreno: ${snapshot.workoutDays}/${snapshot.days} dias, '
        '${snapshot.totalWorkoutMinutes} min totales. ${snapshot.workoutLabel}\n'
        '- Registro de comidas: ${snapshot.mealLogDays}/${snapshot.days} dias. '
        '${snapshot.calorieBalanceLabel}\n'
        '- $weightLine';
  }

  String _buildRecommendations() {
    final snapshot = _buildHabitSnapshot();
    final recommendations = <String>[];

    if (snapshot.waterGoalHitDays <= 2) {
      recommendations.add(
        'Sube la hidratacion: agrega 2-3 tomas de 250-300 ml distribuidas en el dia.',
      );
    }

    if (snapshot.workoutDays <= 2) {
      recommendations.add(
        'Programa 2-3 entrenos cortos (15-25 min) para recuperar constancia.',
      );
    }

    if (snapshot.mealLogDays <= 3) {
      recommendations.add(
        'Registra al menos 2 comidas diarias para afinar calorias y macros.',
      );
    }

    if (snapshot.isCalorieOffTrack) {
      recommendations.add(
        'Ajusta porciones: prioriza proteina y verduras para mejorar saciedad.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Vas muy bien. Manten tus rutinas y considera subir la intensidad gradualmente.',
      );
    }

    final intro = 'Recomendaciones personalizadas (on-device):';
    final list = recommendations.take(3).map((item) => '- $item').join('\n');
    return '$intro\n$list';
  }

  String _buildDailySummary() {
    // Resumen personalizado de progreso diario usando datos reales del store.
    final store = widget.store;
    final goals = store.goals;
    final waterPercent = _progressPercent(
      store.waterTodayMl,
      goals.waterGoalMl,
    );
    final caloriePercent = _progressPercent(
      store.caloriesToday,
      goals.calorieGoal,
    );
    final workoutPercent = _progressPercent(
      store.workoutMinutesToday,
      goals.workoutGoalMinutes,
    );

    final latestWeight = store.latestWeight;
    final weightLine = latestWeight == null
        ? 'Peso: aun no tienes registros.'
        : 'Peso: ${latestWeight.toStringAsFixed(1)} kg (objetivo ${goals.targetWeightKg.toStringAsFixed(1)} kg).';

    return 'Resumen de hoy:\n'
        '- Agua: ${store.waterTodayMl}/${goals.waterGoalMl} ml ($waterPercent%).\n'
        '- Calorias: ${store.caloriesToday}/${goals.calorieGoal} kcal ($caloriePercent%).\n'
        '- Entreno: ${store.workoutMinutesToday}/${goals.workoutGoalMinutes} min ($workoutPercent%), ${store.workoutsCompletedToday} sesiones.\n'
        '- Macros: P ${store.proteinToday} g | C ${store.carbsToday} g | G ${store.fatsToday} g.\n'
        '- $weightLine\n'
        '- Racha activa: ${store.workoutStreak} dias.\n'
        '${_buildPendingMessage(includeLabel: true)}';
  }

  String _buildPendingMessage({bool includeLabel = true}) {
    // Calcula lo que falta para cumplir metas principales del dia.
    final store = widget.store;
    final goals = store.goals;
    final waterMissing = math.max(goals.waterGoalMl - store.waterTodayMl, 0);
    final workoutMissing = math.max(
      goals.workoutGoalMinutes - store.workoutMinutesToday,
      0,
    );
    final caloriesMissing = math.max(
      goals.calorieGoal - store.caloriesToday,
      0,
    );

    final pending = <String>[];
    if (waterMissing > 0) {
      pending.add('$waterMissing ml de agua');
    }
    if (workoutMissing > 0) {
      pending.add('$workoutMissing min de entreno');
    }
    if (caloriesMissing > 0) {
      pending.add('$caloriesMissing kcal');
    }

    if (pending.isEmpty) {
      return 'Hoy ya cumpliste tus metas principales. Buen trabajo.';
    }

    final joined = pending.length == 1
        ? pending.first
        : '${pending.sublist(0, pending.length - 1).join(', ')} y ${pending.last}';
    final prefix = includeLabel ? 'Pendiente hoy: ' : '';
    return '$prefix$joined.';
  }

  String _buildWaterProgressMessage() {
    // Mensaje de hidratacion con porcentaje de avance.
    final store = widget.store;
    final goal = store.goals.waterGoalMl;
    final current = store.waterTodayMl;
    if (goal <= 0) {
      return 'Tu meta de agua no esta configurada. Puedes ajustarla en Progreso > Ajustar metas.';
    }

    final missing = math.max(goal - current, 0);
    final percent = _progressPercent(current, goal);
    if (missing == 0) {
      return 'Excelente: llevas $current ml de agua y ya cumpliste tu meta diaria de $goal ml.';
    }
    return 'Llevas $current ml de agua ($percent%). Te faltan $missing ml para tu meta de $goal ml. Consejo: toma 250-300 ml ahora y repite en 1-2 horas.';
  }

  String _buildNutritionProgressMessage() {
    // Mensaje de calorias consumidas versus meta.
    final store = widget.store;
    final goals = store.goals;
    final calories = store.caloriesToday;
    final goal = goals.calorieGoal;
    final percent = _progressPercent(calories, goal);
    final diff = goal - calories;

    String status;
    if (diff > 0) {
      status = 'Te faltan $diff kcal para tu meta de hoy.';
    } else if (diff < 0) {
      status = 'Vas ${diff.abs()} kcal por encima de tu meta.';
    } else {
      status = 'Ya cumpliste exactamente tu meta calorica.';
    }

    return 'Nutricion de hoy: $calories/$goal kcal ($percent%). $status Macros actuales: P ${store.proteinToday} g, C ${store.carbsToday} g, G ${store.fatsToday} g.';
  }

  String _buildMacroProgressMessage() {
    // Mensaje de macros actuales y rango sugerido de proteina.
    final store = widget.store;
    final latestWeight = store.latestWeight;
    final base =
        'Macros de hoy: P ${store.proteinToday} g, C ${store.carbsToday} g, G ${store.fatsToday} g.';

    if (latestWeight == null) {
      return '$base Registra tu peso para darte un rango de proteina mas personalizado.';
    }

    final minProtein = (latestWeight * 1.6).round();
    final maxProtein = (latestWeight * 2.2).round();
    return '$base Segun tu peso (${latestWeight.toStringAsFixed(1)} kg), una referencia util de proteina es entre $minProtein y $maxProtein g por dia.';
  }

  String _buildWorkoutProgressMessage() {
    // Mensaje de minutos entrenados y sesiones completadas.
    final store = widget.store;
    final goal = store.goals.workoutGoalMinutes;
    final minutes = store.workoutMinutesToday;
    final missing = math.max(goal - minutes, 0);
    final percent = _progressPercent(minutes, goal);

    if (missing == 0) {
      return 'Entreno de hoy: $minutes/$goal min ($percent%), ${store.workoutsCompletedToday} sesiones y ${store.caloriesBurnedToday} kcal quemadas. Muy bien.';
    }

    return 'Entreno de hoy: $minutes/$goal min ($percent%), ${store.workoutsCompletedToday} sesiones y ${store.caloriesBurnedToday} kcal quemadas. Te faltan $missing min para cumplir la meta.';
  }

  String _buildWeightProgressMessage() {
    // Mensaje de peso actual, meta y tendencia semanal.
    final store = widget.store;
    final latestWeight = store.latestWeight;
    final targetWeight = store.goals.targetWeightKg;
    final weeklyDelta = store.weeklyWeightDelta;

    if (latestWeight == null) {
      return 'Aun no hay peso registrado. Agrega uno en Progreso para darte seguimiento personalizado.';
    }

    final deltaToTarget = latestWeight - targetWeight;
    final targetStatus = deltaToTarget == 0
        ? 'Estas justo en tu peso objetivo.'
        : deltaToTarget > 0
        ? 'Estas ${deltaToTarget.toStringAsFixed(1)} kg por encima del objetivo.'
        : 'Estas ${deltaToTarget.abs().toStringAsFixed(1)} kg por debajo del objetivo.';

    String trendStatus;
    if (weeklyDelta == 0) {
      trendStatus = 'Sin cambios en la ultima semana.';
    } else if (weeklyDelta > 0) {
      trendStatus = 'En 7-8 dias subiste ${weeklyDelta.toStringAsFixed(1)} kg.';
    } else {
      trendStatus =
          'En 7-8 dias bajaste ${weeklyDelta.abs().toStringAsFixed(1)} kg.';
    }

    return 'Tu peso actual es ${latestWeight.toStringAsFixed(1)} kg (objetivo ${targetWeight.toStringAsFixed(1)} kg). $targetStatus $trendStatus';
  }

  String _buildProgressMessage() {
    return '${_buildWeightProgressMessage()} ${_buildPendingMessage(includeLabel: false)}';
  }

  String _buildGoalsMessage() {
    final goals = widget.store.goals;
    return 'Tus metas actuales son:\n'
        '- Calorias: ${goals.calorieGoal} kcal\n'
        '- Agua: ${goals.waterGoalMl} ml\n'
        '- Entreno: ${goals.workoutGoalMinutes} min\n'
        '- Peso objetivo: ${goals.targetWeightKg.toStringAsFixed(1)} kg\n'
        'Puedes cambiarlas en Progreso > Ajustar metas.';
  }

  String _buildMotivationMessage() {
    final store = widget.store;
    if (store.workoutStreak > 0) {
      return 'Ya llevas ${store.workoutStreak} dias de racha. Mantener hoy un pequeno paso te ayuda mas que buscar perfeccion. ${_buildPendingMessage(includeLabel: false)}';
    }
    return 'Empieza con algo pequeno hoy: 10-15 min de actividad y registrar tus comidas. La constancia gana.';
  }

  String? _buildSmallTalkResponse(String question) {
    if (_containsAny(question, [
      'como estas',
      'que tal',
      'como vas',
      'como te va',
      'todo bien',
    ])) {
      return 'Bien, gracias. Estoy aqui para ayudarte con tu progreso o dudas de la app.';
    }

    if (_containsAny(question, ['y tu', 'y usted'])) {
      return 'Todo bien por aqui. Cuentame en que te ayudo hoy.';
    }

    if (_containsAny(question, [
      'quien eres',
      'que eres',
      'eres un bot',
      'eres un robot',
      'tu nombre',
      'como te llamas',
    ])) {
      return 'Soy el asistente fitness de AppFitness. Respondo con tus datos locales y reglas simples.';
    }

    if (_containsAny(question, ['ok', 'vale', 'listo', 'perfecto', 'genial'])) {
      return 'Perfecto. Quieres un resumen de hoy o revisar agua, comida, entreno o peso?';
    }

    if (_containsAny(question, ['jaja', 'jeje', 'jiji', 'lol'])) {
      return 'Me alegra. En que te ayudo hoy?';
    }

    if (_containsAny(question, ['tengo hambre', 'hambre'])) {
      return 'Si tienes hambre, prueba un snack simple: yogurt con fruta o un sandwich integral con proteina. Quieres ideas segun tus calorias?';
    }

    if (_containsAny(question, ['tengo sed', 'sed'])) {
      _lastTopic = _ChatTopic.water;
      return _buildWaterProgressMessage();
    }

    if (_containsAny(question, ['cansado', 'agotado', 'sin energia'])) {
      return 'Suena a que necesitas descanso. Prioriza sueno, agua y una comida completa. Si quieres, ajusto tu plan de hoy.';
    }

    if (_containsAny(question, [
      'estresado',
      'ansioso',
      'ansiedad',
      'triste',
      'desanimado',
      'frustrado',
    ])) {
      return 'Lo siento, puede ser pesado. A veces ayuda una caminata corta, respirar lento 1-2 min y tomar agua. Si quieres, hacemos un plan simple para hoy.';
    }

    return null;
  }

  bool _isFollowUp(String question) {
    if (question.isEmpty) {
      return false;
    }
    if (question == 'y') {
      return true;
    }
    if (question.startsWith('y ')) {
      return true;
    }
    if (question.startsWith('entonces')) {
      return true;
    }
    if (question.startsWith('y entonces')) {
      return true;
    }
    if (question.startsWith('y ahora')) {
      return true;
    }
    if (question.startsWith('y despues')) {
      return true;
    }
    if (question.startsWith('y eso')) {
      return true;
    }
    if (question.startsWith('y cuanto')) {
      return true;
    }
    if (question.startsWith('y como')) {
      return true;
    }
    if (question.startsWith('y cual')) {
      return true;
    }
    if (question.startsWith('y que')) {
      return true;
    }
    return false;
  }

  bool _looksLikeQuestion(String question) {
    return question.startsWith('que ') ||
        question.startsWith('como ') ||
        question.startsWith('por que ') ||
        question.startsWith('para que ') ||
        question.startsWith('cual ') ||
        question.startsWith('cuanto ') ||
        question.startsWith('donde ') ||
        question.startsWith('cuando ');
  }

  String _buildGenericQuestionResponse() {
    return 'Puedo responder sobre tu progreso y sobre como usar la app (agua, calorias, macros, entreno, peso). Si tu pregunta es de ese tema, dime cual.';
  }

  String _buildFollowUpResponse() {
    switch (_lastTopic) {
      case _ChatTopic.summary:
        return _buildDailySummary();
      case _ChatTopic.pending:
        return _buildPendingMessage();
      case _ChatTopic.habits:
        return _buildHabitsSummary();
      case _ChatTopic.recommendations:
        return _buildRecommendations();
      case _ChatTopic.water:
        return _buildWaterProgressMessage();
      case _ChatTopic.nutrition:
        return _buildNutritionProgressMessage();
      case _ChatTopic.macros:
        return _buildMacroProgressMessage();
      case _ChatTopic.workout:
        return _buildWorkoutProgressMessage();
      case _ChatTopic.weight:
        return _buildWeightProgressMessage();
      case _ChatTopic.goals:
        return _buildGoalsMessage();
      case _ChatTopic.motivation:
        return _buildMotivationMessage();
      case _ChatTopic.appHelp:
        return _buildHelpMessage();
      case _ChatTopic.none:
        return _buildGenericQuestionResponse();
    }
  }

  _HabitSnapshot _buildHabitSnapshot({int days = 7}) {
    final store = widget.store;
    final goals = store.goals;
    final stats = _recentStats(days: days);

    final waterGoal = goals.waterGoalMl;
    final calorieGoal = goals.calorieGoal;

    final waterGoalHitDays = stats
        .where((item) => item.waterMl >= (waterGoal * 0.9))
        .length;
    final workoutDays = stats.where((item) => item.workoutMinutes > 0).length;
    final mealLogDays = stats.where((item) => item.mealsLogged > 0).length;
    final totalWorkoutMinutes = stats.fold(
      0,
      (sum, item) => sum + item.workoutMinutes,
    );
    final totalWaterMl = stats.fold(0, (sum, item) => sum + item.waterMl);

    final calorieBalancedDays = stats.where((item) {
      if (item.mealsLogged == 0) {
        return false;
      }
      final min = (calorieGoal * 0.85).round();
      final max = (calorieGoal * 1.15).round();
      return item.calories >= min && item.calories <= max;
    }).length;

    final averageWaterMl = (totalWaterMl / days).round();
    final hydrationLabel = waterGoalHitDays >= 5
        ? 'Hidratacion fuerte.'
        : waterGoalHitDays >= 3
        ? 'Hidratacion media.'
        : 'Hidratacion baja.';

    final workoutLabel = workoutDays >= 4
        ? 'Muy buena constancia.'
        : workoutDays >= 2
        ? 'Constancia moderada.'
        : 'Constancia baja.';

    final calorieBalanceLabel = mealLogDays == 0
        ? 'Sin registros suficientes para evaluar balance.'
        : '$calorieBalancedDays/$mealLogDays dias dentro del rango calorico.';

    final isCalorieOffTrack =
        mealLogDays >= 3 && calorieBalancedDays <= (mealLogDays / 3).floor();

    return _HabitSnapshot(
      days: days,
      waterGoalHitDays: waterGoalHitDays,
      workoutDays: workoutDays,
      mealLogDays: mealLogDays,
      calorieBalancedDays: calorieBalancedDays,
      totalWorkoutMinutes: totalWorkoutMinutes,
      averageWaterMl: averageWaterMl,
      hydrationLabel: hydrationLabel,
      workoutLabel: workoutLabel,
      calorieBalanceLabel: calorieBalanceLabel,
      isCalorieOffTrack: isCalorieOffTrack,
      weeklyWeightDelta: store.weeklyWeightDelta,
    );
  }

  List<_DayStats> _recentStats({int days = 7}) {
    final store = widget.store;
    final today = DateTime.now();
    final stats = <_DayStats>[];

    for (var i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final meals = store.mealsForDate(date);
      final workouts = store.workoutsForDate(date);

      stats.add(
        _DayStats(
          date: date,
          calories: meals.fold(0, (sum, item) => sum + item.calories),
          waterMl: store.waterForDate(date),
          workoutMinutes: workouts
              .where((item) => item.completed)
              .fold(0, (sum, item) => sum + item.durationMinutes),
          mealsLogged: meals.length,
        ),
      );
    }

    return stats;
  }

  String _buildWeeklyWeightLine(double weeklyDelta) {
    if (weeklyDelta == 0) {
      return 'Peso: sin cambios relevantes en la ultima semana.';
    }
    if (weeklyDelta > 0) {
      return 'Peso: subiste ${weeklyDelta.toStringAsFixed(1)} kg en 7-8 dias.';
    }
    return 'Peso: bajaste ${weeklyDelta.abs().toStringAsFixed(1)} kg en 7-8 dias.';
  }

  int _progressPercent(int value, int goal) {
    if (goal <= 0) {
      return 0;
    }
    return ((value / goal) * 100).round().clamp(0, 100).toInt();
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  String _normalizeText(String value) {
    // Normaliza texto para hacer matching robusto (acentos/simbolos).
    var normalized = value.toLowerCase().trim();
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    replacements.forEach((key, replacement) {
      normalized = normalized.replaceAll(key, replacement);
    });
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  void _scrollToBottom() {
    // Mantiene visible el ultimo mensaje enviado/recibido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}

class _ChatOptionsBubble extends StatelessWidget {
  const _ChatOptionsBubble({
    required this.message,
    required this.onOptionTap,
    required this.onBackTap,
    required this.onHomeTap,
  });

  final _ChatbotMessage message;
  final ValueChanged<_ChatbotOptionNode>? onOptionTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: _appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _appOutline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            if (message.options.isNotEmpty ||
                message.showBack ||
                message.showHome) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (message.showBack)
                    ActionChip(
                      onPressed: onBackTap,
                      label: const Text('Volver'),
                    ),
                  if (message.showHome)
                    ActionChip(
                      onPressed: onHomeTap,
                      label: const Text('Inicio'),
                    ),
                  ...message.options.map((node) {
                    final label = node.hasChildren
                        ? '${node.label} >'
                        : node.label;
                    return ActionChip(
                      onPressed: onOptionTap == null
                          ? null
                          : () => onOptionTap!(node),
                      label: Text(label),
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Burbuja visual para mensajes del usuario y del bot.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? _appPrimary.withValues(alpha: 0.12)
        : _appSurface;
    final borderColor = isUser
        ? _appPrimary.withValues(alpha: 0.2)
        : _appOutline;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(text),
      ),
    );
  }
}
