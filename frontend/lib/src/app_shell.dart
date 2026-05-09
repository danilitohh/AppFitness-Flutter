part of '../main.dart';

/// Widget raiz: configura tema global, inicializa datos y monta el flujo principal.
class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  late final FitnessStore _store;
  late final AuthStore _authStore;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _store = FitnessStore();
    _authStore = AuthStore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeAppSafely());
    });
  }

  @override
  void dispose() {
    _store.dispose();
    _authStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppFitness',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _appPrimary,
          primary: _appPrimary,
          secondary: _appAccent,
          surface: _appSurface,
        ),
        scaffoldBackgroundColor: _appBackground,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: const Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        ),
        cardTheme: CardThemeData(
          color: _appSurface,
          elevation: 0,
          shadowColor: _appShadow,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _appOutline),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _appSurface,
          indicatorColor: _appPrimary.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? _appPrimary
                  : _appMuted,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? _appPrimary
                  : _appMuted,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _appPrimary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _appPrimaryDark,
            side: const BorderSide(color: _appOutline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _appOutline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _appOutline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _appPrimary, width: 1.6),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _appPrimary.withValues(alpha: 0.12)
                  : _appSurface,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _appPrimaryDark
                  : _appMuted,
            ),
            side: WidgetStateProperty.resolveWith(
              (_) => const BorderSide(color: _appOutline),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1F5F9),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: _appOutline),
          ),
        ),
        dividerTheme: const DividerThemeData(color: _appOutline, thickness: 1),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _appPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: _isInitialized
          ? AuthAppScope(
              notifier: _authStore,
              child: _AppGate(store: _store),
            )
          : const _LoadingScreen(),
    );
  }

  Future<void> _initializeAppSafely() async {
    try {
      await _initializeApp();
    } catch (error, stackTrace) {
      debugPrint('App initialization failed: $error\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _initializeApp() async {
    // Pinta la primera pantalla antes de ejecutar inicializacion pesada.
    await _runStartupStep(
      'date formatting',
      () => initializeDateFormatting('es_ES'),
    );
    await _runStartupStep('auth store', _authStore.initialize);
    await _runStartupStep('fitness store', _store.initialize);
  }

  Future<void> _runStartupStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action().timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      debugPrint('Startup step "$label" failed: $error\n$stackTrace');
    }
  }
}

/// Pantalla temporal mientras se inicializa la app.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Define si se muestra autenticacion o la app principal.
class _AppGate extends StatelessWidget {
  const _AppGate({required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    final authStore = AuthAppScope.of(context);
    if (!authStore.isAuthenticated) {
      return const AuthShell();
    }

    return _AuthenticatedHomeGate(
      store: store,
      authStore: authStore,
      user: authStore.currentUser!,
    );
  }
}

class _AuthenticatedHomeGate extends StatefulWidget {
  const _AuthenticatedHomeGate({
    required this.store,
    required this.authStore,
    required this.user,
  });

  final FitnessStore store;
  final AuthStore authStore;
  final AuthUser user;

  @override
  State<_AuthenticatedHomeGate> createState() => _AuthenticatedHomeGateState();
}

class _AuthenticatedHomeGateState extends State<_AuthenticatedHomeGate> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadUserState();
  }

  @override
  void didUpdateWidget(covariant _AuthenticatedHomeGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      _loadFuture = _loadUserState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }

        return FitnessAppScope(
          notifier: widget.store,
          child: AnimatedBuilder(
            animation: widget.store,
            builder: (context, _) {
              if (widget.store.needsOnboarding) {
                return GuidedOnboardingSurveyScreen(
                  store: widget.store,
                  authStore: widget.authStore,
                  user: widget.user,
                );
              }
              return const HomeShell();
            },
          ),
        );
      },
    );
  }

  Future<void> _loadUserState() async {
    try {
      await widget.store
          .loadForUser(
            widget.user.id,
            allowLegacyMigration:
                !widget.authStore.currentSessionStartedFromRegistration,
          )
          .timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      debugPrint('User state loading failed: $error\n$stackTrace');
    }
  }
}

/// Scope para exponer [FitnessStore] a todo el arbol de widgets.
class FitnessAppScope extends InheritedNotifier<FitnessStore> {
  const FitnessAppScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static FitnessStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FitnessAppScope>();
    assert(scope != null, 'FitnessAppScope not found in context');
    return scope!.notifier!;
  }
}

/// Scope para exponer [AuthStore] globalmente.
class AuthAppScope extends InheritedNotifier<AuthStore> {
  const AuthAppScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AuthStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthAppScope>();
    assert(scope != null, 'AuthAppScope not found in context');
    return scope!.notifier!;
  }
}
