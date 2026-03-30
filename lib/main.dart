import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

const _appPrimary = Color(0xFF0F766E);
const _appPrimaryDark = Color(0xFF0B5F57);
const _appAccent = Color(0xFF34D399);
const _appBackground = Color(0xFFF4F7F6);
const _appSurface = Color(0xFFFFFFFF);
const _appOutline = Color(0xFFE2E8F0);
const _appMuted = Color(0xFF64748B);
const _appText = Color(0xFF0F172A);
const _appShadow = Color(0x14000000);
const double _appFormFieldGap = 12;
const double _appFormSectionGap = 14;

const _appHeroGradient = LinearGradient(
  colors: [Color(0xFF0F766E), Color(0xFF059669), Color(0xFF34D399)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _surveyDarkBackground = Color(0xFF050505);
const _surveyCard = Color(0xFF171717);
const _surveyCardSoft = Color(0xFF0F0F0F);
const _surveyStroke = Color(0xFF333333);
const _surveyAccent = Color(0xFFFFC629);
const _onboardingSurveyAssetPaths = <String>[
  'assets/onboarding_examples/survey_ref_01.jpeg',
  'assets/onboarding_examples/survey_ref_02.jpeg',
  'assets/onboarding_examples/survey_ref_03.jpeg',
  'assets/onboarding_examples/survey_ref_04.jpeg',
  'assets/onboarding_examples/survey_ref_05.jpeg',
  'assets/onboarding_examples/survey_ref_06.jpeg',
  'assets/onboarding_examples/survey_ref_07.jpeg',
  'assets/onboarding_examples/survey_ref_08.jpeg',
  'assets/onboarding_examples/survey_ref_09.jpeg',
  'assets/onboarding_examples/survey_ref_10.jpeg',
  'assets/onboarding_examples/survey_ref_11.jpeg',
  'assets/onboarding_examples/survey_ref_12.jpeg',
  'assets/onboarding_examples/survey_ref_13.jpeg',
  'assets/onboarding_examples/survey_ref_14.jpeg',
  'assets/onboarding_examples/survey_ref_15.jpeg',
];

// Punto de entrada de la aplicacion.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  runApp(const FitnessApp());
}

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

/// Modelo de usuario autenticado.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.age,
    this.heightCm,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final int? age;
  final double? heightCm;

  bool get hasPassword => passwordHash.isNotEmpty;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'Usuario';
    }
    return parts.first;
  }

  AuthUser copyWith({
    String? name,
    String? email,
    String? passwordHash,
    int? age,
    double? heightCm,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'age': age,
      'heightCm': heightCm,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? _newId(),
      name: json['name']?.toString() ?? 'Usuario',
      email: _normalizeEmail(json['email']?.toString() ?? ''),
      passwordHash: json['passwordHash']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      age: json['age'] == null ? null : _toInt(json['age']),
      heightCm: json['heightCm'] == null ? null : _toDouble(json['heightCm']),
    );
  }
}

/// Resultado estandar para operaciones de autenticacion.
class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.resetCode,
  });

  final bool success;
  final String message;
  final String? resetCode;
}

/// Ticket temporal para recuperacion de contraseña.
class _PasswordResetTicket {
  const _PasswordResetTicket({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() {
    return {'code': code, 'expiresAt': expiresAt.toIso8601String()};
  }

  factory _PasswordResetTicket.fromJson(Map<String, dynamic> json) {
    return _PasswordResetTicket(
      code: json['code']?.toString() ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Store de autenticacion: maneja registro, login, logout y recuperacion.
class AuthStore extends ChangeNotifier {
  static const String _usersKey = 'auth_users_v1';
  static const String _currentUserIdKey = 'auth_current_user_id_v1';
  static const String _passwordResetKey = 'auth_password_reset_v1';

  final List<AuthUser> _users = [];
  final Map<String, _PasswordResetTicket> _passwordResetTickets = {};
  String? _currentUserId;
  bool _currentSessionStartedFromRegistration = false;

  AuthUser? get currentUser {
    if (_currentUserId == null) {
      return null;
    }
    for (final user in _users) {
      if (user.id == _currentUserId) {
        return user;
      }
    }
    return null;
  }

  bool get isAuthenticated => currentUser != null;
  bool get currentSessionStartedFromRegistration =>
      _currentSessionStartedFromRegistration;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final usersRaw = prefs.getString(_usersKey);
    if (usersRaw != null && usersRaw.isNotEmpty) {
      final decoded = jsonDecode(usersRaw);
      if (decoded is List) {
        _users
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(AuthUser.fromJson)
                .where((user) => user.email.isNotEmpty && user.hasPassword),
          );
      }
    }

    final passwordResetRaw = prefs.getString(_passwordResetKey);
    if (passwordResetRaw != null && passwordResetRaw.isNotEmpty) {
      final decoded = jsonDecode(passwordResetRaw);
      if (decoded is Map) {
        _passwordResetTickets
          ..clear()
          ..addAll(
            decoded.map<String, _PasswordResetTicket>((key, value) {
              final ticket = value is Map<String, dynamic>
                  ? _PasswordResetTicket.fromJson(value)
                  : _PasswordResetTicket.fromJson(
                      Map<String, dynamic>.from(value as Map),
                    );
              return MapEntry(_normalizeEmail(key.toString()), ticket);
            }),
          );
      }
    }

    _cleanupExpiredPasswordResetTickets();

    _currentUserId = prefs.getString(_currentUserIdKey);
    if (currentUser == null) {
      _currentUserId = null;
      await prefs.remove(_currentUserIdKey);
    }
    _currentSessionStartedFromRegistration = false;

    notifyListeners();
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Ingresa tu nombre para crear la cuenta.',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult(
        success: false,
        message: 'Ingresa un correo valido.',
      );
    }

    if (_passwordError(password) != null) {
      return const AuthResult(
        success: false,
        message: 'La contraseña no cumple los requisitos minimos.',
      );
    }

    final alreadyExists = _userByEmail(normalizedEmail) != null;
    if (alreadyExists) {
      return const AuthResult(
        success: false,
        message: 'Ya existe una cuenta con ese correo.',
      );
    }

    final user = AuthUser(
      id: _newId(),
      name: normalizedName,
      email: normalizedEmail,
      passwordHash: _hashPassword(normalizedEmail, password),
      createdAt: DateTime.now(),
    );

    _storeUser(user);
    _currentUserId = user.id;
    _currentSessionStartedFromRegistration = true;
    await _persist();
    notifyListeners();

    return const AuthResult(
      success: true,
      message: 'Cuenta creada. Bienvenido.',
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final user = _userByEmail(normalizedEmail);
    if (user == null) {
      return const AuthResult(
        success: false,
        message: 'No encontramos una cuenta con ese correo.',
      );
    }

    final inputHash = _hashPassword(normalizedEmail, password);
    if (user.passwordHash != inputHash) {
      return const AuthResult(
        success: false,
        message: 'La contraseña es incorrecta.',
      );
    }

    _currentUserId = user.id;
    _currentSessionStartedFromRegistration = false;
    await _persistSession();
    notifyListeners();

    return const AuthResult(success: true, message: 'Sesion iniciada.');
  }

  Future<void> logout() async {
    _currentUserId = null;
    _currentSessionStartedFromRegistration = false;
    await _persistSession();
    notifyListeners();
  }

  Future<AuthResult> updateCurrentUserProfile({
    required String name,
    int? age,
    double? heightCm,
  }) async {
    final user = currentUser;
    if (user == null) {
      return const AuthResult(
        success: false,
        message: 'No hay una sesion activa para actualizar.',
      );
    }

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Ingresa un nombre valido.',
      );
    }

    if (age != null && (age < 10 || age > 120)) {
      return const AuthResult(
        success: false,
        message: 'La edad debe estar entre 10 y 120 años.',
      );
    }

    if (heightCm != null && (heightCm < 80 || heightCm > 250)) {
      return const AuthResult(
        success: false,
        message: 'La estatura debe estar entre 80 y 250 cm.',
      );
    }

    final index = _users.indexWhere((item) => item.id == user.id);
    if (index < 0) {
      return const AuthResult(
        success: false,
        message: 'No encontramos tu cuenta para actualizarla.',
      );
    }

    _users[index] = user.copyWith(
      name: normalizedName,
      age: age,
      heightCm: heightCm,
    );

    await _persist();
    notifyListeners();

    return const AuthResult(
      success: true,
      message: 'Perfil actualizado correctamente.',
    );
  }

  Future<AuthResult> requestPasswordReset({required String email}) async {
    final normalizedEmail = _normalizeEmail(email);
    final user = _userByEmail(normalizedEmail);
    if (user == null) {
      return const AuthResult(
        success: false,
        message: 'No existe una cuenta con ese correo.',
      );
    }

    final code = _generateResetCode();
    _passwordResetTickets[normalizedEmail] = _PasswordResetTicket(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
    await _persist();

    return AuthResult(
      success: true,
      message: 'Codigo de verificacion generado.',
      resetCode: code,
    );
  }

  Future<AuthResult> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final user = _userByEmail(normalizedEmail);
    if (user == null) {
      return const AuthResult(
        success: false,
        message: 'No existe una cuenta con ese correo.',
      );
    }

    final passwordError = _passwordError(newPassword);
    if (passwordError != null) {
      return AuthResult(success: false, message: passwordError);
    }

    _cleanupExpiredPasswordResetTickets();
    final ticket = _passwordResetTickets[normalizedEmail];
    if (ticket == null) {
      return const AuthResult(
        success: false,
        message: 'Primero solicita un codigo de recuperacion.',
      );
    }

    if (ticket.code != code.trim()) {
      return const AuthResult(success: false, message: 'Codigo incorrecto.');
    }

    final index = _users.indexWhere((item) => item.id == user.id);
    if (index < 0) {
      return const AuthResult(
        success: false,
        message: 'No se pudo actualizar la contraseña.',
      );
    }

    _users[index] = _users[index].copyWith(
      passwordHash: _hashPassword(normalizedEmail, newPassword),
    );
    _passwordResetTickets.remove(normalizedEmail);
    await _persist();
    notifyListeners();

    return const AuthResult(
      success: true,
      message: 'Contraseña actualizada. Ya puedes iniciar sesión.',
    );
  }

  AuthUser? _userByEmail(String normalizedEmail) {
    for (final user in _users) {
      if (user.email == normalizedEmail) {
        return user;
      }
    }
    return null;
  }

  void _storeUser(AuthUser user) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      _users[index] = user;
      return;
    }
    _users.add(user);
  }

  void _cleanupExpiredPasswordResetTickets() {
    final now = DateTime.now();
    _passwordResetTickets.removeWhere(
      (_, ticket) => ticket.expiresAt.isBefore(now),
    );
  }

  String _generateResetCode() {
    final random = math.Random.secure();
    final value = 100000 + random.nextInt(900000);
    return value.toString();
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      await prefs.remove(_currentUserIdKey);
      return;
    }
    await prefs.setString(_currentUserIdKey, _currentUserId!);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(_users.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _passwordResetKey,
      jsonEncode(
        _passwordResetTickets.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      ),
    );
    await _persistSession();
  }
}

/// Vistas posibles dentro del flujo de autenticacion.
enum AuthView { login, register, forgotPassword }

/// Contenedor visual del modulo de autenticacion.
class AuthShell extends StatefulWidget {
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  AuthView _view = AuthView.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFB), Color(0xFFEAF2EF), Color(0xFFF4F9F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _appOutline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _AuthHeader(),
                          const SizedBox(height: 18),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            child: _buildForm(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tu sesion se guarda en este dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    // Cambia entre formularios sin salir de la pantalla.
    switch (_view) {
      case AuthView.login:
        return _AuthLoginForm(
          key: const ValueKey(AuthView.login),
          onSwitchToRegister: () {
            setState(() {
              _view = AuthView.register;
            });
          },
          onSwitchToForgotPassword: () {
            setState(() {
              _view = AuthView.forgotPassword;
            });
          },
        );
      case AuthView.register:
        return _AuthRegisterForm(
          key: const ValueKey(AuthView.register),
          onSwitchToLogin: () {
            setState(() {
              _view = AuthView.login;
            });
          },
        );
      case AuthView.forgotPassword:
        return _AuthForgotPasswordForm(
          key: const ValueKey(AuthView.forgotPassword),
          onSwitchToLogin: () {
            setState(() {
              _view = AuthView.login;
            });
          },
        );
    }
  }
}

/// Cabecera decorativa de la pantalla de autenticacion.
class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _AuthLogo(),
        SizedBox(height: 14),
        Text(
          'AppFitness',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    const size = 86.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0x220F766E),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.favorite, color: Colors.white, size: 44),
          Positioned(
            bottom: 20,
            child: Icon(Icons.show_chart, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

/// Formulario para iniciar sesion.
class _AuthLoginForm extends StatefulWidget {
  const _AuthLoginForm({
    super.key,
    required this.onSwitchToRegister,
    required this.onSwitchToForgotPassword,
  });

  final VoidCallback onSwitchToRegister;
  final VoidCallback onSwitchToForgotPassword;

  @override
  State<_AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<_AuthLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Correo',
              icon: Icons.mail_outline,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: _appFormFieldGap),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: _authInputDecoration(
              label: 'Contraseña',
              icon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: _requiredValidator,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: _appFormFieldGap),
          Center(
            child: TextButton(
              onPressed: widget.onSwitchToForgotPassword,
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 6),
          _authGradientButton(
            label: 'Iniciar sesión',
            loading: _loading,
            onTap: _loading ? null : _submit,
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('¿No tienes una cuenta?'),
                TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _authGradientButton({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _appHeroGradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Ejecuta login y muestra feedback al usuario.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final authStore = AuthAppScope.of(context);
    final result = await authStore.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
    _showAuthSnackBar(context, result.message, success: result.success);
  }
}

/// Formulario para crear una cuenta nueva.
class _AuthRegisterForm extends StatefulWidget {
  const _AuthRegisterForm({super.key, required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  State<_AuthRegisterForm> createState() => _AuthRegisterFormState();
}

class _AuthRegisterFormState extends State<_AuthRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Crea tu cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Completa tu registro y tu evaluación inicial para personalizar tu plan.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _appFormSectionGap),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Nombre',
              icon: Icons.person,
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: _appFormFieldGap),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Correo',
              icon: Icons.mail_outline,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: _appFormFieldGap),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Contraseña',
              icon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: _passwordFieldValidator,
          ),
          const SizedBox(height: _appFormFieldGap),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: _authInputDecoration(
              label: 'Confirmar contraseña',
              icon: Icons.lock_person_outlined,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              final requiredError = _requiredValidator(value);
              if (requiredError != null) {
                return requiredError;
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: _appFormSectionGap),
          _authGradientButton(
            label: 'Crear cuenta',
            loading: _loading,
            onTap: _loading ? null : _submit,
          ),
          const SizedBox(height: _appFormFieldGap),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('¿Ya tienes cuenta?'),
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  child: const Text('Inicia sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _authGradientButton({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _appHeroGradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Ejecuta registro y deja la sesion iniciada si es exitoso.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final authStore = AuthAppScope.of(context);
    final result = await authStore.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
    _showAuthSnackBar(context, result.message, success: result.success);
  }
}

/// Formulario para solicitar codigo y restablecer contraseña.
class _AuthForgotPasswordForm extends StatefulWidget {
  const _AuthForgotPasswordForm({super.key, required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  State<_AuthForgotPasswordForm> createState() =>
      _AuthForgotPasswordFormState();
}

class _AuthForgotPasswordFormState extends State<_AuthForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _loadingRequestCode = false;
  bool _loadingReset = false;
  bool _codeWasRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recuperar contraseña',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Te enviaremos un codigo temporal para restablecerla.'),
          const SizedBox(height: _appFormSectionGap),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _authInputDecoration(
              label: 'Correo de la cuenta',
              icon: Icons.mail_outline,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: _appFormFieldGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadingRequestCode ? null : _requestCode,
              icon: _loadingRequestCode
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.mark_email_read_outlined),
              label: const Text('Solicitar codigo'),
            ),
          ),
          if (_codeWasRequested) ...[
            const SizedBox(height: _appFormSectionGap),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: _authInputDecoration(
                label: 'Codigo de verificacion',
                icon: Icons.pin_outlined,
              ),
              validator: (value) {
                final requiredError = _requiredValidator(value);
                if (requiredError != null) {
                  return requiredError;
                }
                if ((value?.trim().length ?? 0) != 6) {
                  return 'El codigo debe tener 6 digitos.';
                }
                return null;
              },
            ),
            const SizedBox(height: _appFormFieldGap),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: _authInputDecoration(
                label: 'Nueva contraseña',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
              validator: _passwordFieldValidator,
            ),
            const SizedBox(height: _appFormFieldGap),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _authInputDecoration(
                label: 'Confirmar nueva contraseña',
                icon: Icons.lock_person_outlined,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) {
                final requiredError = _requiredValidator(value);
                if (requiredError != null) {
                  return requiredError;
                }
                if (value != _newPasswordController.text) {
                  return 'Las contraseñas no coinciden.';
                }
                return null;
              },
            ),
            const SizedBox(height: _appFormSectionGap),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loadingReset ? null : _confirmReset,
                child: _loadingReset
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cambiar contraseña'),
              ),
            ),
          ],
          const SizedBox(height: _appFormFieldGap),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('¿Recordaste tu contraseña?'),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: const Text('Volver a iniciar sesion'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestCode() async {
    // Pide codigo temporal de recuperacion.
    final emailError = _emailFieldValidator(_emailController.text);
    if (emailError != null) {
      _showAuthSnackBar(context, emailError, success: false);
      return;
    }

    setState(() {
      _loadingRequestCode = true;
    });

    final authStore = AuthAppScope.of(context);
    final result = await authStore.requestPasswordReset(
      email: _emailController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingRequestCode = false;
    });
    _showAuthSnackBar(context, result.message, success: result.success);

    if (!result.success || result.resetCode == null) {
      return;
    }

    setState(() {
      _codeWasRequested = true;
    });

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Codigo generado'),
          content: Text(
            'Modo demo: tu codigo es ${result.resetCode}. Vence en 15 minutos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmReset() async {
    // Confirma codigo + nueva contraseña.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loadingReset = true;
    });

    final authStore = AuthAppScope.of(context);
    final result = await authStore.confirmPasswordReset(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingReset = false;
    });
    _showAuthSnackBar(context, result.message, success: result.success);

    if (!result.success) {
      return;
    }

    _codeController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    widget.onSwitchToLogin();
  }
}

/// Estilo base reutilizable para campos de autenticacion.
InputDecoration _authInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: label,
    prefixIcon: Icon(icon, color: _appPrimary),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _appOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _appOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _appPrimary, width: 1.6),
    ),
  );
}

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

class _WorkoutPlanSuggestion {
  const _WorkoutPlanSuggestion({
    required this.template,
    required this.frequencyLabel,
    required this.cadenceLabel,
    required this.executionHint,
    required this.exerciseNames,
  });

  final WorkoutTemplate template;
  final String frequencyLabel;
  final String cadenceLabel;
  final String executionHint;
  final List<String> exerciseNames;
}

class _MealPlanSuggestion {
  const _MealPlanSuggestion({
    required this.slotLabel,
    required this.icon,
    required this.title,
    required this.frequencyLabel,
    required this.timingLabel,
    required this.ingredients,
    required this.portionSummary,
  });

  final String slotLabel;
  final IconData icon;
  final String title;
  final String frequencyLabel;
  final String timingLabel;
  final List<_MealIngredientLine> ingredients;
  final String portionSummary;
}

class _MealIngredientLine {
  const _MealIngredientLine({required this.amount, required this.name});

  final String amount;
  final String name;
}

class _MealSlotDefinition {
  const _MealSlotDefinition({
    required this.slotLabel,
    required this.icon,
    required this.timingLabel,
    required this.isMainMeal,
    required this.isSnack,
  });

  final String slotLabel;
  final IconData icon;
  final String timingLabel;
  final bool isMainMeal;
  final bool isSnack;
}

class _NutritionContextFlags {
  const _NutritionContextFlags({
    required this.isLactoseFree,
    required this.isGlutenFree,
    required this.isVegan,
    required this.isVegetarian,
    required this.avoidsNuts,
  });

  final bool isLactoseFree;
  final bool isGlutenFree;
  final bool isVegan;
  final bool isVegetarian;
  final bool avoidsNuts;
}

int _proteinTargetForGoal(FitnessGoalType goal, double weightKg) {
  final factor = switch (goal) {
    FitnessGoalType.gainMuscle => 1.8,
    FitnessGoalType.loseFat => 1.6,
    FitnessGoalType.performance => 1.6,
    FitnessGoalType.maintain => 1.2,
  };
  return (weightKg * factor).round();
}

WorkoutTemplate _workoutTemplateById(String id) {
  return _workoutTemplates.firstWhere(
    (template) => template.id == id,
    orElse: () => _workoutTemplates.first,
  );
}

List<_WorkoutPlanSuggestion> _buildWorkoutPlanSuggestions({
  required CoachProfile profile,
}) {
  final resolvedIds = _weeklyWorkoutPlanIds(
    profile,
  ).map((id) => _normalizeWorkoutTemplateIdForProfile(id, profile)).toList();
  final orderedIds = <String>[];
  final counts = <String, int>{};

  for (final id in resolvedIds) {
    if (!counts.containsKey(id)) {
      orderedIds.add(id);
    }
    counts[id] = (counts[id] ?? 0) + 1;
  }

  return orderedIds.map((id) {
    final template = _workoutTemplateById(id);
    final frequency = counts[id] ?? 1;
    return _WorkoutPlanSuggestion(
      template: template,
      frequencyLabel: _workoutFrequencyLabel(frequency),
      cadenceLabel: _workoutCadenceLabel(frequency),
      executionHint: _workoutExecutionHint(template, profile),
      exerciseNames: template.exampleExercises.take(4).toList(),
    );
  }).toList();
}

List<String> _weeklyWorkoutPlanIds(CoachProfile profile) {
  final days = _clampInt(profile.daysPerWeek, 1, 7);

  switch (profile.goal) {
    case FitnessGoalType.gainMuscle:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['upper-body-strength', 'lower-body-core'];
      }
      if (days == 3) {
        return ['upper-body-strength', 'lower-body-core', 'full-body-strength'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'upper-body-strength',
          'lower-body-core',
        ];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'full-body-strength',
        'upper-body-strength',
        'lower-body-core',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.loseFat:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['full-body-strength', 'zone-2-cardio', 'hiit-conditioning'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'zone-2-cardio',
          'hiit-conditioning',
        ];
      }
      return [
        'full-body-strength',
        'upper-body-strength',
        'lower-body-core',
        'zone-2-cardio',
        'hiit-conditioning',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.performance:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['upper-body-strength', 'lower-body-core', 'zone-2-cardio'];
      }
      if (days == 4) {
        return [
          'upper-body-strength',
          'lower-body-core',
          'zone-2-cardio',
          'hiit-conditioning',
        ];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'full-body-strength',
        'zone-2-cardio',
        'hiit-conditioning',
        'mobility-recovery',
      ].take(days).toList();
    case FitnessGoalType.maintain:
      if (days <= 1) {
        return ['full-body-strength'];
      }
      if (days == 2) {
        return ['full-body-strength', 'zone-2-cardio'];
      }
      if (days == 3) {
        return ['full-body-strength', 'zone-2-cardio', 'mobility-recovery'];
      }
      return [
        'upper-body-strength',
        'lower-body-core',
        'zone-2-cardio',
        'mobility-recovery',
        'full-body-strength',
      ].take(days).toList();
  }
}

String _normalizeWorkoutTemplateIdForProfile(
  String templateId,
  CoachProfile profile,
) {
  if (profile.equipment == EquipmentAccess.home &&
      (templateId == 'upper-body-strength' ||
          templateId == 'lower-body-core')) {
    return 'full-body-strength';
  }
  return templateId;
}

String _workoutFrequencyLabel(int timesPerWeek) {
  if (timesPerWeek <= 1) {
    return '1 vez por semana';
  }
  return '$timesPerWeek veces por semana';
}

String _workoutCadenceLabel(int timesPerWeek) {
  if (timesPerWeek <= 1) {
    return 'repite cada 7 dias';
  }
  if (timesPerWeek == 2) {
    return 'repite cada 3-4 dias';
  }
  if (timesPerWeek == 3) {
    return 'trabajalo en dias alternos';
  }
  return 'distribuyelo a lo largo de la semana';
}

String _workoutExecutionHint(WorkoutTemplate template, CoachProfile profile) {
  if (template.category == 'Cardio') {
    final duration =
        template.defaultDurationMinutes +
        (profile.goal == FitnessGoalType.performance ? 5 : 0);
    final cardioMode = template.id == 'hiit-conditioning'
        ? 'Haz 6-10 bloques de 20-40 s con pausas cortas.'
        : 'Mantente a un ritmo continuo donde aun puedas hablar en frases cortas.';
    return '${template.exampleExercises.take(3).join(', ')}. Trabaja $duration min. $cardioMode';
  }

  if (template.category == 'Movilidad') {
    final rounds = profile.experience == TrainingExperience.beginner ? 2 : 3;
    return '${template.exampleExercises.take(3).join(', ')}. Haz $rounds rondas de 30-45 s por lado y usa esta sesion para recuperar.';
  }

  final series = switch (profile.experience) {
    TrainingExperience.beginner => 2,
    TrainingExperience.intermediate => 3,
    TrainingExperience.advanced => 4,
  };
  final repRange = switch (profile.goal) {
    FitnessGoalType.gainMuscle => '8-12 repeticiones',
    FitnessGoalType.loseFat => '10-15 repeticiones',
    FitnessGoalType.performance => '6-10 repeticiones',
    FitnessGoalType.maintain => '8-12 repeticiones',
  };
  return '${template.exampleExercises.take(3).join(', ')}. Haz $series series por ejercicio con $repRange.';
}

List<_MealPlanSuggestion> _buildMealPlanSuggestions({
  required CoachProfile profile,
  required FitnessGoals goals,
  required double referenceWeight,
}) {
  final flags = _nutritionFlagsFromProfile(profile);
  final proteinTarget = _proteinTargetForGoal(profile.goal, referenceWeight);
  final proteinPerMeal = math.max(
    20,
    (proteinTarget / profile.mealsPerDay).round(),
  );
  final cadenceLabel = _mealCadenceLabel(profile.mealsPerDay);

  return _mealSlotsForProfile(profile).map((slot) {
    return _buildMealPlanSuggestionForSlot(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }).toList();
}

_NutritionContextFlags _nutritionFlagsFromProfile(CoachProfile profile) {
  final normalized = '${profile.allergies}; ${profile.notes}'.toLowerCase();
  final isVegan =
      normalized.contains('vegano') || normalized.contains('vegana');
  final isVegetarian = isVegan || normalized.contains('vegetar');

  return _NutritionContextFlags(
    isLactoseFree:
        normalized.contains('sin lactosa') || normalized.contains('lactosa'),
    isGlutenFree:
        normalized.contains('sin gluten') || normalized.contains('celia'),
    isVegan: isVegan,
    isVegetarian: isVegetarian,
    avoidsNuts:
        normalized.contains('frutos secos') ||
        normalized.contains('mani') ||
        normalized.contains('nuez'),
  );
}

List<_MealSlotDefinition> _mealSlotsForProfile(CoachProfile profile) {
  final mainMealTiming = profile.mealWindow.label;

  switch (profile.mealsPerDay) {
    case 2:
      return [
        _MealSlotDefinition(
          slotLabel: 'Comida 1',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Comida principal',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
      ];
    case 3:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '3-4 horas despues de la comida principal',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    case 4:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion',
          icon: Icons.apple,
          timingLabel: 'entre comidas',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '3-4 horas despues del almuerzo',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    case 5:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion AM',
          icon: Icons.apple,
          timingLabel: 'media manana',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion PM',
          icon: Icons.cookie_outlined,
          timingLabel: 'media tarde',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: '2-3 horas despues de la colacion',
          isMainMeal: false,
          isSnack: false,
        ),
      ];
    default:
      return [
        _MealSlotDefinition(
          slotLabel: 'Desayuno',
          icon: Icons.free_breakfast,
          timingLabel: 'al iniciar el dia',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion AM',
          icon: Icons.apple,
          timingLabel: 'media manana',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Almuerzo',
          icon: Icons.restaurant,
          timingLabel: mainMealTiming,
          isMainMeal: true,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Colacion PM',
          icon: Icons.cookie_outlined,
          timingLabel: 'media tarde',
          isMainMeal: false,
          isSnack: true,
        ),
        _MealSlotDefinition(
          slotLabel: 'Cena',
          icon: Icons.dinner_dining,
          timingLabel: 'noche',
          isMainMeal: false,
          isSnack: false,
        ),
        _MealSlotDefinition(
          slotLabel: 'Snack ligero',
          icon: Icons.local_drink_outlined,
          timingLabel: 'si aun te faltan calorias',
          isMainMeal: false,
          isSnack: true,
        ),
      ];
  }
}

String _mealCadenceLabel(int mealsPerDay) {
  if (mealsPerDay <= 2) {
    return 'cada 5-6 horas';
  }
  if (mealsPerDay == 3) {
    return 'cada 4-5 horas';
  }
  if (mealsPerDay == 4) {
    return 'cada 3-4 horas';
  }
  return 'cada 2-3 horas';
}

String _mealPortionSummary({
  required _MealSlotDefinition slot,
  required int proteinPerMeal,
}) {
  if (slot.isSnack) {
    return 'Usa esta colacion para completar energia y acercarte a ~$proteinPerMeal g de proteina diarios por toma.';
  }
  if (slot.isMainMeal) {
    return 'Haz de esta tu comida mas completa del dia y apunta a ~$proteinPerMeal g de proteina.';
  }
  return 'Porcion sugerida para acercarte a ~$proteinPerMeal g de proteina en esta comida.';
}

_MealPlanSuggestion _buildMealPlanSuggestionForSlot({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  if (slot.isSnack) {
    return _buildSnackMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  if (slot.isMainMeal) {
    return _buildMainMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  if (slot.slotLabel.toLowerCase().contains('cena')) {
    return _buildDinnerMealSuggestion(
      profile: profile,
      slot: slot,
      cadenceLabel: cadenceLabel,
      proteinPerMeal: proteinPerMeal,
      flags: flags,
    );
  }

  return _buildBreakfastMealSuggestion(
    profile: profile,
    slot: slot,
    cadenceLabel: cadenceLabel,
    proteinPerMeal: proteinPerMeal,
    flags: flags,
  );
}

_MealPlanSuggestion _buildBreakfastMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu revuelto con avena y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Huevos con avena y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('2 unidades', 'huevos'),
            _ingredient('200 g', 'claras'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido con bebida vegetal y avena',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina en polvo'),
            _ingredient('300 ml', 'bebida vegetal'),
            _ingredient('50 g', 'avena'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Omelette proteico con avena',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('2 unidades', 'huevos'),
          _ingredient('200 g', 'claras'),
          _ingredient('50 g', 'avena'),
          _ingredient('1 porcion', 'fruta'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con aguacate y verduras'
            : 'Huevos con aguacate y vegetales',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'tofu'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('1-2 tazas', 'verduras salteadas'),
              ]
            : [
                _ingredient('2-3 unidades', 'huevos'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('1-2 tazas', 'vegetales'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Avena con chia y bebida vegetal'
            : flags.isLactoseFree
            ? 'Huevos con fruta y avena'
            : 'Yogur con avena y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('60 g', 'avena'),
                _ingredient('250 ml', 'bebida vegetal'),
                _ingredient('15 g', 'chia'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : flags.isLactoseFree
            ? [
                _ingredient('2 unidades', 'huevos'),
                _ingredient('50 g', 'avena'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : [
                _ingredient('200 g', 'yogur'),
                _ingredient('50 g', 'avena'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Avena con bebida vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('60 g', 'avena'),
            _ingredient('250 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('10 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Avena con bebida vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('60 g', 'avena'),
            _ingredient('250 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('15 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Avena con yogur y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.avoidsNuts
            ? [
                _ingredient('60 g', 'avena'),
                _ingredient('200 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
                _ingredient('15 g', 'semillas'),
              ]
            : [
                _ingredient('60 g', 'avena'),
                _ingredient('200 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
                _ingredient('15 g', 'frutos secos'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildMainMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tempeh con arroz y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180-220 g', 'tempeh'),
            _ingredient('130 g', 'arroz cocido'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Huevos o tofu con arroz y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('3 unidades o 180 g', 'huevos o tofu'),
            _ingredient('130 g', 'arroz cocido'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pollo con arroz y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('170-200 g', 'pollo'),
          _ingredient('130 g', 'arroz cocido'),
          _ingredient('1-2 tazas', 'verduras'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con ensalada grande y aguacate'
            : 'Ensalada grande con pollo y aguacate',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180-220 g', 'tofu'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('2 tazas', 'verduras libres'),
              ]
            : [
                _ingredient('160-180 g', 'pollo o atun'),
                _ingredient('1/2 unidad', 'aguacate'),
                _ingredient('2 tazas', 'verduras libres'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Lentejas con quinoa y verduras'
            : 'Lentejas o tofu con quinoa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 taza', 'lentejas'),
                _ingredient('120 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ]
            : [
                _ingredient('1 taza o 180 g', 'lentejas o tofu'),
                _ingredient('120 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu con arroz y ensalada',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('140 g', 'arroz cocido'),
            _ingredient('1 plato', 'ensalada'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isVegetarian) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Lentejas con arroz y ensalada',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 taza', 'lentejas'),
            _ingredient('120-140 g', 'arroz cocido'),
            _ingredient('1 plato', 'ensalada'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pollo con arroz y ensalada',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('160-180 g', 'pollo'),
          _ingredient('140 g', 'arroz cocido'),
          _ingredient('1 plato', 'ensalada'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildDinnerMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Tofu con papa y verduras',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('180 g', 'tofu'),
            _ingredient('180 g', 'papa cocida'),
            _ingredient('1-2 tazas', 'verduras al vapor'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Pavo o atun con papa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('160-180 g', 'pavo o atun'),
          _ingredient('180 g', 'papa'),
          _ingredient('1-2 tazas', 'verduras cocidas'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Tofu con verduras salteadas'
            : 'Pescado o huevos con verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'tofu'),
                _ingredient('2 tazas', 'verduras'),
                _ingredient('1 cda', 'aceite de oliva'),
              ]
            : [
                _ingredient('160 g o 3 unidades', 'pescado o huevos'),
                _ingredient('2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Garbanzos con quinoa y verduras'
            : 'Tortilla o tofu con verduras y quinoa',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 taza', 'garbanzos'),
                _ingredient('100 g', 'quinoa cocida'),
                _ingredient('1-2 tazas', 'verduras'),
              ]
            : [
                _ingredient('2 huevos + 150 g claras o 180 g', 'tofu'),
                _ingredient('100 g', 'quinoa'),
                _ingredient('1-2 tazas', 'verduras'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Garbanzos con verduras y quinoa',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 taza', 'garbanzos'),
            _ingredient('100 g', 'quinoa cocida'),
            _ingredient('1-2 tazas', 'verduras'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Huevos o pescado con papa y verduras',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('2-3 huevos o 160 g', 'pescado'),
          _ingredient('160 g', 'papa'),
          _ingredient('1-2 tazas', 'verduras'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

_MealPlanSuggestion _buildSnackMealSuggestion({
  required CoachProfile profile,
  required _MealSlotDefinition slot,
  required String cadenceLabel,
  required int proteinPerMeal,
  required _NutritionContextFlags flags,
}) {
  switch (profile.dietStyle) {
    case DietStyle.highProtein:
      if (flags.isVegan) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido vegetal y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina vegetal'),
            _ingredient('1 porcion', 'fruta'),
            _ingredient('10 g', 'semillas'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      if (flags.isLactoseFree) {
        return _MealPlanSuggestion(
          slotLabel: slot.slotLabel,
          icon: slot.icon,
          title: 'Batido sin lactosa y fruta',
          frequencyLabel: cadenceLabel,
          timingLabel: slot.timingLabel,
          ingredients: [
            _ingredient('1 scoop', 'proteina en polvo'),
            _ingredient('300 ml', 'bebida vegetal'),
            _ingredient('1 porcion', 'fruta'),
          ],
          portionSummary: _mealPortionSummary(
            slot: slot,
            proteinPerMeal: proteinPerMeal,
          ),
        );
      }
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: 'Yogur alto en proteina y fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: [
          _ingredient('200 g', 'yogur alto en proteina'),
          _ingredient('1 porcion', 'fruta'),
        ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.lowCarb:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Hummus con pepino'
            : 'Rollitos de pavo con pepino',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('80 g', 'hummus'),
                _ingredient('1 porcion', 'pepino o zanahoria'),
              ]
            : [
                _ingredient('80-100 g', 'pavo'),
                _ingredient('1 porcion', 'pepino o zanahoria'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.vegetarian:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Yogur vegetal con semillas'
            : 'Yogur o queso cottage con fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('180 g', 'yogur vegetal'),
                _ingredient('10-15 g', 'semillas'),
                _ingredient('1 porcion', 'fruta'),
              ]
            : [
                _ingredient('180 g', 'yogur o queso cottage'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
    case DietStyle.balanced:
      return _MealPlanSuggestion(
        slotLabel: slot.slotLabel,
        icon: slot.icon,
        title: flags.isVegan
            ? 'Fruta con bebida vegetal'
            : flags.isLactoseFree
            ? 'Fruta con bebida vegetal y semillas'
            : 'Yogur con fruta',
        frequencyLabel: cadenceLabel,
        timingLabel: slot.timingLabel,
        ingredients: flags.isVegan
            ? [
                _ingredient('1 porcion', 'fruta'),
                _ingredient('250 ml', 'bebida vegetal'),
              ]
            : flags.isLactoseFree
            ? [
                _ingredient('1 porcion', 'fruta'),
                _ingredient('250 ml', 'bebida vegetal'),
                _ingredient('10 g', 'semillas'),
              ]
            : [
                _ingredient('180 g', 'yogur'),
                _ingredient('1 porcion', 'fruta'),
              ],
        portionSummary: _mealPortionSummary(
          slot: slot,
          proteinPerMeal: proteinPerMeal,
        ),
      );
  }
}

String _joinNaturalList(Iterable<String> items) {
  final values = items.where((item) => item.trim().isNotEmpty).toList();
  if (values.isEmpty) {
    return '';
  }
  if (values.length == 1) {
    return values.first;
  }
  if (values.length == 2) {
    return '${values.first} y ${values.last}';
  }
  return '${values.sublist(0, values.length - 1).join(', ')} y ${values.last}';
}

_MealIngredientLine _ingredient(String amount, String name) {
  return _MealIngredientLine(amount: amount, name: name);
}

String _workoutExercisePreview(WorkoutTemplate template, {int limit = 3}) {
  return _joinNaturalList(template.exampleExercises.take(limit));
}

bool get _showLegacyOnboardingRecommendations => false;

List<String> _buildOnboardingRecommendations({
  required CoachProfile profile,
  required FitnessGoals goals,
  double? currentWeightKg,
  double? targetWeightKg,
}) {
  final referenceWeight =
      currentWeightKg ?? targetWeightKg ?? goals.targetWeightKg;
  final workoutPlan = _buildWorkoutPlanSuggestions(profile: profile);
  final mealPlan = _buildMealPlanSuggestions(
    profile: profile,
    goals: goals,
    referenceWeight: referenceWeight,
  );
  final focus = switch (profile.goal) {
    FitnessGoalType.loseFat => 'deficit moderado y constancia',
    FitnessGoalType.gainMuscle => 'progresion de fuerza y proteina alta',
    FitnessGoalType.performance => 'cardio progresivo y recuperacion',
    FitnessGoalType.maintain => 'equilibrio y habitos sostenibles',
  };

  final trainingPlace = switch (profile.equipment) {
    EquipmentAccess.home => 'casa',
    EquipmentAccess.gym => 'gimnasio',
    EquipmentAccess.mixed => 'casa y gimnasio',
  };
  final workoutHistory = switch (profile.trainingHistory) {
    TrainingHistory.none => 'sin historial reciente de entrenamiento',
    TrainingHistory.onceWeekly => 'con una base ligera de entrenamiento',
    TrainingHistory.twoToThreeWeekly => 'con una base intermedia reciente',
    TrainingHistory.fourPlusWeekly =>
      'con una base consistente de entrenamiento',
  };
  final contextNotes = [
    profile.allergies.trim(),
    profile.notes.trim(),
  ].where((item) => item.isNotEmpty).join('; ');

  final weightLine = currentWeightKg != null && targetWeightKg != null
      ? 'Tu referencia inicial va de ${currentWeightKg.toStringAsFixed(1)} kg a ${targetWeightKg.toStringAsFixed(1)} kg.'
      : currentWeightKg != null
      ? 'Tu peso base sera ${currentWeightKg.toStringAsFixed(1)} kg y lo iremos afinando con tus registros.'
      : 'Registra tu primer peso esta semana para que las recomendaciones sean cada vez mas precisas.';

  final workoutLine =
      'Rutinas sugeridas: ${workoutPlan.take(2).map((item) => '${item.template.title} (${item.frequencyLabel})').join(' y ')}. Empieza con ${_workoutExercisePreview(workoutPlan.first.template)} y manten el foco en $focus.';

  final mealLine = mealPlan.isEmpty
      ? 'Empezaremos con ${profile.mealsPerDay} comidas al dia, estilo ${profile.dietStyle.label.toLowerCase()}, comida principal ${profile.mealWindow.label.toLowerCase()} y una meta de ${goals.calorieGoal} kcal.'
      : 'Comidas sugeridas: ${mealPlan.take(2).map((item) => '${item.slotLabel}: ${item.title}').join(' | ')}. Repite ${mealPlan.first.frequencyLabel} y sigue las porciones indicadas.';

  return [
    workoutLine,
    'El punto de partida quedara ajustado $workoutHistory, con preferencia horaria ${profile.workoutWindow.label.toLowerCase()}.',
    mealLine,
    'Tus sugerencias se adaptaran para entrenar en $trainingPlace y con una meta de hidratacion de ${goals.waterGoalMl} ml.',
    if (contextNotes.isNotEmpty)
      'Tendremos en cuenta estas consideraciones desde el inicio: ${_summarizeCoachNote(contextNotes)}.',
    weightLine,
    if (_showLegacyOnboardingRecommendations) ...[
      'Te recomendaré ${profile.daysPerWeek} días de entreno por semana, sesiones de ${goals.workoutGoalMinutes} minutos y foco en $focus.',
      'El punto de partida quedará ajustado $workoutHistory, con preferencia horaria ${profile.workoutWindow.label.toLowerCase()}.',
      'Empezaremos con ${profile.mealsPerDay} comidas al día, estilo ${profile.dietStyle.label.toLowerCase()}, comida principal ${profile.mealWindow.label.toLowerCase()} y una meta de ${goals.calorieGoal} kcal.',
      'Tus sugerencias se adaptarán para entrenar en $trainingPlace y con una meta de hidratación de ${goals.waterGoalMl} ml.',
      if (contextNotes.isNotEmpty)
        'Tendremos en cuenta estas consideraciones desde el inicio: ${_summarizeCoachNote(contextNotes)}.',
      weightLine,
    ],
  ];
}

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

/// Mensaje individual dentro del historial de chat.
class _ChatbotMessage {
  const _ChatbotMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
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
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final List<_ChatbotMessage> _messages;
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

  @override
  void initState() {
    super.initState();
    // Primer mensaje contextual del asistente.
    _messages = [_ChatbotMessage(text: _buildWelcomeMessage(), isUser: false)];
  }

  @override
  void dispose() {
    _inputController.dispose();
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
                  return _ChatBubble(
                    text: message.text,
                    isUser: message.isUser,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sendMessage,
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    // Agrega mensaje del usuario y responde con un pequeno delay.
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) {
      return;
    }

    setState(() {
      _messages.add(_ChatbotMessage(text: text, isUser: true));
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_ChatbotMessage(text: _botResponse(text), isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    });
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

/// Tarjeta reutilizable para mostrar una metrica con barra de progreso.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget compacto para visualizar macros del dia.
class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Chip compacto para mostrar preferencias del Coach IA.
class _CoachChip extends StatelessWidget {
  const _CoachChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _appOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _appPrimaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Linea de recomendacion en los bloques del Coach IA.
class _CoachSuggestionLine extends StatelessWidget {
  const _CoachSuggestionLine({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _appPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _WorkoutPlanSuggestionCard extends StatelessWidget {
  const _WorkoutPlanSuggestionCard({
    required this.suggestion,
    required this.onOpen,
  });

  final _WorkoutPlanSuggestion suggestion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final template = suggestion.template;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: template.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: template.accent.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: template.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      template.icon,
                      color: template.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      template.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _appText,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: template.accent),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CoachChip(
                    icon: Icons.calendar_today_outlined,
                    label: suggestion.frequencyLabel,
                  ),
                  _CoachChip(
                    icon: Icons.schedule_outlined,
                    label: suggestion.cadenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Ejercicios recomendados',
                style: TextStyle(fontWeight: FontWeight.w700, color: _appText),
              ),
              const SizedBox(height: 8),
              ...suggestion.exerciseNames.map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 16,
                        color: template.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exercise,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _appText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion.executionHint,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black.withValues(alpha: 0.66),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPlanSuggestionCard extends StatelessWidget {
  const _MealPlanSuggestionCard({required this.suggestion});

  final _MealPlanSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _appOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _appPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(suggestion.icon, color: _appPrimaryDark, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.slotLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _appText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CoachChip(
                icon: Icons.repeat_rounded,
                label: suggestion.frequencyLabel,
              ),
              _CoachChip(
                icon: Icons.schedule_outlined,
                label: suggestion.timingLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ingredientes y cantidades',
            style: TextStyle(fontWeight: FontWeight.w700, color: _appText),
          ),
          const SizedBox(height: 8),
          ...suggestion.ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.kitchen_outlined,
                    size: 16,
                    color: _appPrimaryDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.black.withValues(alpha: 0.72),
                        ),
                        children: [
                          TextSpan(
                            text: '${item.amount} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _appText,
                            ),
                          ),
                          TextSpan(text: item.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion.portionSummary,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper del grafico de peso.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const Center(
        child: Text('Registra al menos 2 pesos para ver la tendencia.'),
      );
    }

    return CustomPaint(
      painter: WeightChartPainter(entries),
      child: const SizedBox.expand(),
    );
  }
}

/// Painter custom para dibujar la linea de tendencia de peso.
class WeightChartPainter extends CustomPainter {
  WeightChartPainter(this.entries);

  final List<WeightEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..style = PaintingStyle.fill;

    const left = 22.0;
    const right = 10.0;
    const top = 8.0;
    const bottom = 24.0;

    canvas.drawLine(
      Offset(left, size.height - bottom),
      Offset(size.width - right, size.height - bottom),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(left, top),
      Offset(left, size.height - bottom),
      axisPaint,
    );

    final weights = entries.map((e) => e.weightKg).toList();
    var minWeight = weights.reduce(math.min);
    var maxWeight = weights.reduce(math.max);
    if ((maxWeight - minWeight).abs() < 0.2) {
      minWeight -= 0.2;
      maxWeight += 0.2;
    }

    final availableWidth = size.width - left - right;
    final availableHeight = size.height - top - bottom;
    final count = entries.length;
    final path = Path();

    for (var i = 0; i < count; i++) {
      final x = count == 1 ? left : left + (availableWidth * i / (count - 1));
      final normalized =
          (entries[i].weightKg - minWeight) / (maxWeight - minWeight);
      final y = top + (1 - normalized) * availableHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);
    }

    canvas.drawPath(path, linePaint);

    final labelStyle = const TextStyle(color: Color(0xFF4B5563), fontSize: 11);
    _drawText(
      canvas,
      '${maxWeight.toStringAsFixed(1)} kg',
      const Offset(0, 0),
      labelStyle,
    );
    _drawText(
      canvas,
      '${minWeight.toStringAsFixed(1)} kg',
      Offset(0, size.height - bottom - 8),
      labelStyle,
    );

    _drawText(
      canvas,
      DateFormat('d MMM').format(entries.first.date),
      Offset(left, size.height - 18),
      labelStyle,
    );

    final endLabel = DateFormat('d MMM').format(entries.last.date);
    final painter = TextPainter(
      text: TextSpan(text: endLabel, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(size.width - painter.width - right, size.height - 18),
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

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

/// Regex simple para validar correo.
bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

/// Normaliza email para comparaciones consistentes.
String _normalizeEmail(String value) {
  return value.trim().toLowerCase();
}

/// Hash SHA-256 para no almacenar contraseña en texto plano.
String _hashPassword(String email, String password) {
  final payload = '$email::$password::appfitness';
  return sha256.convert(utf8.encode(payload)).toString();
}

/// Muestra feedback visual en auth (exito/error).
void _showAuthSnackBar(
  BuildContext context,
  String message, {
  required bool success,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success
          ? const Color(0xFF047857)
          : const Color(0xFFB91C1C),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Convierte valor/meta a progreso [0..1].
double _safeProgress(int value, int goal) {
  if (goal <= 0) {
    return 0;
  }
  return (value / goal).clamp(0, 1);
}

/// Estima cercania al peso objetivo para la barra de progreso.
double _weightProgress(double currentWeight, double targetWeight) {
  final distance = (currentWeight - targetWeight).abs();
  final normalized = (1 - (distance / 15)).clamp(0.05, 1.0);
  return normalized;
}

/// Color visual segun intensidad del entrenamiento.
Color _intensityColor(WorkoutIntensity intensity) {
  switch (intensity) {
    case WorkoutIntensity.low:
      return const Color(0xFF0284C7);
    case WorkoutIntensity.medium:
      return const Color(0xFFF59E0B);
    case WorkoutIntensity.high:
      return const Color(0xFFDC2626);
  }
}

/// Capitaliza la primera letra de una cadena.
String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}

String _formatEntryDateTime(DateTime value, {bool includeYear = true}) {
  final pattern = includeYear ? 'd MMM yyyy • HH:mm' : 'd MMM • HH:mm';
  return DateFormat(pattern).format(value);
}

String _formatTimeOfDayLabel(TimeOfDay value) {
  final sample = DateTime(2000, 1, 1, value.hour, value.minute);
  return DateFormat('HH:mm').format(sample);
}

String _summarizeCoachNote(String notes) {
  final compact = notes.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (compact.length <= 72) {
    return compact;
  }
  return '${compact.substring(0, 69).trim()}...';
}

/// Generador simple de id unico local.
String _newId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

/// Limita un entero a un rango seguro.
int _clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

/// Conversor seguro a int para parseo de JSON.
int _toInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

/// Conversor seguro a double para parseo de JSON.
double _toDouble(Object? value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}
