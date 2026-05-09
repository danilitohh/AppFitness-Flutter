part of '../main.dart';

// -----------------------------------------------------------------------------
// Shell autenticado y navegacion principal.
// Tabs del home, acciones flotantes y configuracion contextual del usuario.
// -----------------------------------------------------------------------------
/// Shell principal autenticado: tabs + acciones globales.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Entrenamientos',
    'Nutricion',
    'Progreso',
  ];

  @override
  Widget build(BuildContext context) {
    final store = FitnessAppScope.of(context);
    final authStore = AuthAppScope.of(context);
    final currentUser = authStore.currentUser;
    final pages = [
      DashboardScreen(store: store),
      WorkoutsScreen(store: store),
      NutritionScreen(store: store),
      ProgressScreen(store: store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: false,
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Tooltip(
                  message: 'Configuracion de usuario',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _openUserSettings(context, authStore, store),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: _appPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _appPrimary.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: _appPrimaryDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentUser.firstName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _appPrimaryDark,
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
          IconButton(
            onPressed: () => _confirmLogout(context, authStore),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF4F7F6), Color(0xFFEFF5F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: pages[_currentIndex],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingButtons(
        context,
        store,
        currentUser?.firstName,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Entreno',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Comidas',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(
    BuildContext context,
    FitnessStore store,
    String? userFirstName,
  ) {
    // Muestra el chatbot solo en Dashboard y mantiene el FAB contextual.
    final primaryFab = _buildPrimaryFab(context, store);
    final chatFab = _currentIndex == 0
        ? _buildChatFab(context, store, userFirstName)
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (primaryFab != null) ...[primaryFab, const SizedBox(height: 10)],
        ?chatFab,
      ],
    );
  }

  Widget _buildChatFab(
    BuildContext context,
    FitnessStore store,
    String? userFirstName,
  ) {
    return FloatingActionButton.extended(
      heroTag: 'chatbot_bubble',
      onPressed: () => _openChatbot(context, store, userFirstName),
      tooltip: 'Chatbot',
      backgroundColor: const Color(0xFF0F766E),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('Chat'),
    );
  }

  Widget? _buildPrimaryFab(BuildContext context, FitnessStore store) {
    // Accion contextual segun la pestaña activa.
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton.extended(
          heroTag: 'workout_fab',
          onPressed: () => openWorkoutCatalog(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Entreno'),
        );
      case 2:
        return FloatingActionButton.extended(
          heroTag: 'meal_fab',
          onPressed: () => showMealSheet(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Comida'),
        );
      case 3:
        return FloatingActionButton.extended(
          heroTag: 'weight_fab',
          onPressed: () => showWeightSheet(context, store),
          icon: const Icon(Icons.monitor_weight_outlined),
          label: const Text('Peso'),
        );
      default:
        return null;
    }
  }

  Future<void> _openChatbot(
    BuildContext context,
    FitnessStore store,
    String? userFirstName,
  ) {
    // Abre el chatbot y le pasa acceso a datos reales del store.
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SimpleChatbotSheet(store: store, userFirstName: userFirstName),
    );
  }

  Future<void> _openUserSettings(
    BuildContext context,
    AuthStore authStore,
    FitnessStore store,
  ) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _UserSettingsScreen(authStore: authStore, store: store),
      ),
    );

    if (!context.mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuracion de usuario actualizada.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthStore authStore) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text('¿Quieres salir de tu cuenta actual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await authStore.logout();
    }
  }
}

class _UserSettingsScreen extends StatefulWidget {
  const _UserSettingsScreen({required this.authStore, required this.store});

  final AuthStore authStore;
  final FitnessStore store;

  @override
  State<_UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<_UserSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _currentWeightController;
  late final TextEditingController _targetWeightController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.authStore.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _heightController = TextEditingController(
      text: user?.heightCm?.round().toString() ?? '',
    );
    _currentWeightController = TextEditingController(
      text: widget.store.latestWeight?.toStringAsFixed(1) ?? '',
    );
    _targetWeightController = TextEditingController(
      text: widget.store.goals.targetWeightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authStore.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion de usuario')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _appPrimary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: _appPrimaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.name ?? 'Usuario',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentUser?.email ?? '',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos personales',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Actualiza la informacion base de tu perfil para personalizar mejor la experiencia.',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.62),
                          ),
                        ),
                        const SizedBox(height: _appFormSectionGap),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: _appFormFieldGap),
                        TextFormField(
                          initialValue: currentUser?.email ?? '',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                          ),
                        ),
                        const SizedBox(height: _appFormFieldGap),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Edad'),
                          validator: _optionalAgeValidator,
                        ),
                        const SizedBox(height: _appFormFieldGap),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Estatura (cm)',
                          ),
                          validator: _optionalHeightValidator,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuerpo y objetivo',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'El peso actual se guarda como un nuevo registro de hoy. El objetivo se refleja en Progreso.',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.62),
                          ),
                        ),
                        const SizedBox(height: _appFormSectionGap),
                        TextFormField(
                          controller: _currentWeightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Peso actual (kg)',
                          ),
                          validator: _optionalPositiveDecimalValidator,
                        ),
                        const SizedBox(height: _appFormFieldGap),
                        TextFormField(
                          controller: _targetWeightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Peso objetivo (kg)',
                          ),
                          validator: _positiveDecimalValidator,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => showGoalSheet(context, widget.store),
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Objetivos diarios'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              showCoachSheet(context, widget.store),
                          icon: const Icon(Icons.tune),
                          label: const Text('Coach IA'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: _appFormSectionGap),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _saveProfile,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final age = _parseOptionalInt(_ageController.text);
    final heightCm = _parseOptionalDouble(_heightController.text);
    final currentWeight = _parseOptionalDouble(_currentWeightController.text);
    final targetWeight = _parseOptionalDouble(_targetWeightController.text);

    setState(() {
      _saving = true;
    });

    final result = await widget.authStore.updateCurrentUserProfile(
      name: _nameController.text.trim(),
      age: age,
      heightCm: heightCm,
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

    final latestWeight = widget.store.latestWeight;
    if (currentWeight != null &&
        (latestWeight == null ||
            (latestWeight - currentWeight).abs() >= 0.05)) {
      widget.store.addWeight(currentWeight);
    }

    if (targetWeight != null &&
        (widget.store.goals.targetWeightKg - targetWeight).abs() >= 0.05) {
      widget.store.updateGoals(
        widget.store.goals.copyWith(targetWeightKg: targetWeight),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });
    Navigator.of(context).pop(true);
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
