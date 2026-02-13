import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

// Punto de entrada de la aplicacion.
void main() {
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
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _store = FitnessStore();
    _authStore = AuthStore();
    _initFuture = _initializeApp();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF6F9F8),
      ),
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingScreen();
          }

          return AuthAppScope(
            notifier: _authStore,
            child: _AppGate(store: _store),
          );
        },
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Prepara localizacion de fechas y carga estado persistido.
    await initializeDateFormatting();
    await Future.wait([_store.initialize(), _authStore.initialize()]);
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

    return FitnessAppScope(notifier: store, child: const HomeShell());
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
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'Usuario';
    }
    return parts.first;
  }

  AuthUser copyWith({String? name, String? email, String? passwordHash}) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
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
                .where(
                  (user) =>
                      user.email.isNotEmpty && user.passwordHash.isNotEmpty,
                ),
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

    _users.add(user);
    _currentUserId = user.id;
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
    await _persistSession();
    notifyListeners();

    return const AuthResult(success: true, message: 'Sesion iniciada.');
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _persistSession();
    notifyListeners();
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
      message: 'Contraseña actualizada. Ya puedes iniciar sesion.',
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
            colors: [Color(0xFF042F2E), Color(0xFF0F766E), Color(0xFF34D399)],
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
                    const _AuthHeader(),
                    const SizedBox(height: 18),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      color: Colors.white.withValues(alpha: 0.98),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              child: _buildForm(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tus credenciales se guardan en este dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'AppFitness',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inicia sesion para llevar el control de tu progreso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Ingresa con tu correo y contraseña.'),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Correo',
              icon: Icons.alternate_email,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar sesion'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onSwitchToForgotPassword,
              child: const Text('Olvide mi contraseña'),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('¿No tienes cuenta?'),
              TextButton(
                onPressed: widget.onSwitchToRegister,
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crea tu cuenta',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Empezaras a registrar entrenamientos y comidas.'),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Nombre',
              icon: Icons.person,
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _authInputDecoration(
              label: 'Correo',
              icon: Icons.alternate_email,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cuenta'),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta?'),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: const Text('Inicia sesion'),
              ),
            ],
          ),
        ],
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _authInputDecoration(
              label: 'Correo de la cuenta',
              icon: Icons.mail_outline,
            ),
            validator: _emailFieldValidator,
          ),
          const SizedBox(height: 10),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 14),
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
          const SizedBox(height: 8),
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
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.6),
    ),
  );
}

/// Nivel de intensidad para un entrenamiento.
enum WorkoutIntensity { low, medium, high }

extension WorkoutIntensityX on WorkoutIntensity {
  String get label {
    switch (this) {
      case WorkoutIntensity.low:
        return 'Baja';
      case WorkoutIntensity.medium:
        return 'Media';
      case WorkoutIntensity.high:
        return 'Alta';
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
        return 'Comida';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
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
  static const String _workoutsKey = 'fitness_workouts';
  static const String _mealsKey = 'fitness_meals';
  static const String _weightsKey = 'fitness_weights';
  static const String _waterKey = 'fitness_water';
  static const String _goalsKey = 'fitness_goals';
  static const String _seedKey = 'fitness_seeded';

  final List<WorkoutEntry> _workouts = [];
  final List<MealEntry> _meals = [];
  final List<WeightEntry> _weights = [];
  final Map<String, int> _waterByDay = {};
  FitnessGoals _goals = const FitnessGoals(
    calorieGoal: 2200,
    waterGoalMl: 2500,
    workoutGoalMinutes: 45,
    targetWeightKg: 70,
  );

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

  Future<void> initialize() async {
    // Restaura datos persistidos y aplica seed inicial en primera ejecucion.
    final prefs = await SharedPreferences.getInstance();

    final workoutsRaw = prefs.getString(_workoutsKey);
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

    final mealsRaw = prefs.getString(_mealsKey);
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

    final weightsRaw = prefs.getString(_weightsKey);
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

    final waterRaw = prefs.getString(_waterKey);
    if (waterRaw != null && waterRaw.isNotEmpty) {
      final decoded = jsonDecode(waterRaw) as Map<String, dynamic>;
      _waterByDay
        ..clear()
        ..addAll(decoded.map((key, value) => MapEntry(key, _toInt(value))));
    }

    final goalsRaw = prefs.getString(_goalsKey);
    if (goalsRaw != null && goalsRaw.isNotEmpty) {
      _goals = FitnessGoals.fromJson(
        jsonDecode(goalsRaw) as Map<String, dynamic>,
      );
    }

    final hasSeed = prefs.getBool(_seedKey) == true;
    if (!hasSeed) {
      _seedData();
      await prefs.setBool(_seedKey, true);
      await _persist();
    }

    notifyListeners();
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

  void _seedData() {
    // Datos demo para que la app tenga contenido inicial.
    final now = DateTime.now();

    _workouts.addAll([
      WorkoutEntry(
        id: _newId(),
        name: 'Full Body',
        category: 'Fuerza',
        durationMinutes: 45,
        caloriesBurned: 320,
        date: now.subtract(const Duration(days: 1)),
        intensity: WorkoutIntensity.high,
        completed: true,
      ),
      WorkoutEntry(
        id: _newId(),
        name: 'Cardio HIIT',
        category: 'Cardio',
        durationMinutes: 30,
        caloriesBurned: 280,
        date: now,
        intensity: WorkoutIntensity.high,
        completed: true,
      ),
      WorkoutEntry(
        id: _newId(),
        name: 'Movilidad',
        category: 'Recuperacion',
        durationMinutes: 20,
        caloriesBurned: 90,
        date: now,
        intensity: WorkoutIntensity.low,
        completed: false,
      ),
    ]);

    _meals.addAll([
      MealEntry(
        id: _newId(),
        type: MealType.breakfast,
        name: 'Avena con fruta',
        calories: 420,
        protein: 18,
        carbs: 62,
        fats: 11,
        date: now,
      ),
      MealEntry(
        id: _newId(),
        type: MealType.lunch,
        name: 'Pollo con arroz',
        calories: 650,
        protein: 44,
        carbs: 68,
        fats: 19,
        date: now,
      ),
    ]);

    _weights.addAll([
      WeightEntry(
        id: _newId(),
        weightKg: 74.5,
        date: now.subtract(const Duration(days: 6)),
      ),
      WeightEntry(
        id: _newId(),
        weightKg: 74.0,
        date: now.subtract(const Duration(days: 3)),
      ),
      WeightEntry(id: _newId(), weightKg: 73.7, date: now),
    ]);

    _waterByDay[_dayKey(now)] = 1200;
  }

  void _persistAndNotify() {
    // Notifica cambios en UI y persiste en background.
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _workoutsKey,
      jsonEncode(_workouts.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _mealsKey,
      jsonEncode(_meals.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _weightsKey,
      jsonEncode(_weights.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(_waterKey, jsonEncode(_waterByDay));
    await prefs.setString(_goalsKey, jsonEncode(_goals.toJson()));
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _dayKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(normalized);
  }
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
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  currentUser.firstName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
      body: SafeArea(child: pages[_currentIndex]),
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
    // Combina FAB contextual por pantalla + boton de chatbot.
    final primaryFab = _buildPrimaryFab(context, store);
    final chatFab = _buildChatFab(context, store, userFirstName);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (primaryFab != null) ...[primaryFab, const SizedBox(height: 10)],
        chatFab,
      ],
    );
  }

  Widget _buildChatFab(
    BuildContext context,
    FitnessStore store,
    String? userFirstName,
  ) {
    // En Dashboard se muestra expandido para mayor visibilidad.
    if (_currentIndex == 0) {
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

    return FloatingActionButton.small(
      heroTag: 'chatbot_bubble',
      onPressed: () => _openChatbot(context, store, userFirstName),
      tooltip: 'Chatbot',
      backgroundColor: const Color(0xFF0F766E),
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat_bubble_outline),
    );
  }

  Widget? _buildPrimaryFab(BuildContext context, FitnessStore store) {
    // Accion contextual segun la pestaña activa.
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton.extended(
          heroTag: 'workout_fab',
          onPressed: () => showWorkoutSheet(context, store),
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

/// Mensaje individual dentro del historial de chat.
class _ChatbotMessage {
  const _ChatbotMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
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

    if (_containsAny(question, [
      'salir',
      'adios',
      'hasta luego',
      'nos vemos',
    ])) {
      return 'Gracias por conversar conmigo. Exitos con tus metas fitness.';
    }

    if (_containsAny(question, ['gracias', 'muchas gracias'])) {
      return 'De nada. Si quieres, te ayudo a ajustar entreno, comida o progreso.';
    }

    if (_containsAny(question, ['hola', 'buenas', 'hey'])) {
      return _buildWelcomeMessage();
    }

    if (_containsAny(question, ['ayuda', 'que puedes', 'que haces'])) {
      return _buildHelpMessage();
    }

    if (_containsAny(question, ['resumen de hoy', 'como voy', 'estado hoy'])) {
      return _buildDailySummary();
    }

    if (_containsAny(question, ['falta', 'pendiente', 'resta', 'me falta'])) {
      return _buildPendingMessage();
    }

    if (_containsAny(question, ['dashboard', 'inicio', 'pantalla principal'])) {
      return _buildDailySummary();
    }

    if (_containsAny(question, ['objetivo del proyecto'])) {
      return 'El objetivo de esta app es ayudarte a registrar tus habitos y progreso para mejorar tu salud y rendimiento.';
    }

    if (_containsAny(question, ['tecnologia', 'tecnologias'])) {
      return 'La app esta desarrollada en Flutter y Dart para funcionar en movil de forma rapida y consistente.';
    }

    if (_containsAny(question, ['integracion'])) {
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
      return 'Para registrar comida: entra a Comidas y toca el boton de Comida. Intenta registrar porciones reales para que las calorias sean utiles.';
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
      return 'Para registrar entreno: entra a Entreno y toca el boton Entreno. Registra duracion e intensidad para medir tu constancia.';
    }

    if (_containsAny(question, ['agua', 'hidratacion', 'hidratar'])) {
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
      return _buildMacroProgressMessage();
    }

    if (_containsAny(question, [
      'caloria',
      'calorias',
      'kcal',
      'deficit',
      'superavit',
    ])) {
      return _buildNutritionProgressMessage();
    }

    if (_containsAny(question, [
      'nutricion',
      'dieta',
      'comer',
      'alimentacion',
    ])) {
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
      return _buildWorkoutProgressMessage();
    }

    if (_containsAny(question, [
      'calentamiento',
      'estiramiento',
      'movilidad',
    ])) {
      return 'Haz 5-10 min de calentamiento antes de entrenar (movilidad + activacion). Al final, baja pulsaciones y estira suave para recuperarte mejor.';
    }

    if (_containsAny(question, [
      'descanso',
      'recuperacion',
      'dolor muscular',
    ])) {
      return 'Incluye al menos 1-2 dias de descanso por semana. Tu racha actual es de ${widget.store.workoutStreak} dias; recuperarte bien tambien es parte del progreso.';
    }

    if (_containsAny(question, ['lesion', 'dolor fuerte', 'mareo', 'pecho'])) {
      return 'Si tienes dolor fuerte, mareo o sintomas preocupantes, detente y consulta a un profesional de salud. Este chat no reemplaza evaluacion medica.';
    }

    if (_containsAny(question, ['sueno', 'dormir', 'insomnio'])) {
      return 'Apunta a 7-9 horas de sueno. Mantener horario regular mejora recuperacion, hambre y rendimiento en entrenamiento.';
    }

    if (_containsAny(question, [
      'estancado',
      'no avanzo',
      'plateau',
      'progreso',
    ])) {
      return _buildProgressMessage();
    }

    if (_containsAny(question, ['peso', 'bajar de peso', 'subir de peso'])) {
      return _buildWeightProgressMessage();
    }

    if (_containsAny(question, ['meta', 'metas', 'objetivo', 'objetivos'])) {
      return _buildGoalsMessage();
    }

    if (_containsAny(question, [
      'motivacion',
      'constancia',
      'disciplina',
      'habito',
    ])) {
      return _buildMotivationMessage();
    }

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
        ? const Color(0xFFD1E7FF)
        : const Color(0xFFE9ECEF);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (authUser != null)
                Text(
                  'Hola, ${authUser.firstName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (authUser != null) const SizedBox(height: 4),
              const Text(
                'Tu resumen de hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _capitalize(todayLabel),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                'Racha activa: ${store.workoutStreak} dias',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
                    FilledButton.icon(
                      onPressed: () => store.addWater(250),
                      icon: const Icon(Icons.local_drink),
                      label: const Text('+250 ml'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showWorkoutSheet(context, store),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Nuevo entreno'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showMealSheet(context, store),
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Nueva comida'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showWeightSheet(context, store),
                      icon: const Icon(Icons.monitor_weight_outlined),
                      label: const Text('Registrar peso'),
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
                            '${DateFormat('d MMM').format(item.date)} - ${item.category} - ${item.durationMinutes} min',
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('Sin entrenamientos para mostrar.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries[index];
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
                        subtitle: Text(
                          '${item.category} - ${item.durationMinutes} min - ${item.caloriesBurned} kcal\n${DateFormat('d MMM yyyy').format(item.date)}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: item.completed,
                              onChanged: (value) => widget.store
                                  .setWorkoutCompleted(item.id, value ?? false),
                            ),
                            IconButton(
                              onPressed: () =>
                                  widget.store.deleteWorkout(item.id),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
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
                  '${item.type.label} - ${item.calories} kcal\nP ${item.protein}g / C ${item.carbs}g / G ${item.fats}g',
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.16),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
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

/// Modal para crear un entrenamiento.
Future<void> showWorkoutSheet(BuildContext context, FitnessStore store) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final categoryController = TextEditingController(text: 'General');
  final durationController = TextEditingController(text: '30');
  final caloriesController = TextEditingController(text: '250');
  var selectedDate = DateTime.now();
  var intensity = WorkoutIntensity.medium;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
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
                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      validator: _requiredValidator,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duracion (min)',
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
                              labelText: 'Calorias',
                            ),
                            validator: _positiveIntValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 6),
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
                            date: selectedDate,
                            intensity: intensity,
                          );

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
      );
    },
  );

  nameController.dispose();
  categoryController.dispose();
  durationController.dispose();
  caloriesController.dispose();
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
  var selectedDate = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
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
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del plato',
                      ),
                      validator: _requiredValidator,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Calorias',
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
                              labelText: 'Proteina (g)',
                            ),
                            validator: _positiveIntValidator,
                          ),
                        ),
                      ],
                    ),
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
                    const SizedBox(height: 6),
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
                            calories: int.parse(caloriesController.text.trim()),
                            protein: int.parse(proteinController.text.trim()),
                            carbs: int.parse(carbsController.text.trim()),
                            fats: int.parse(fatsController.text.trim()),
                            date: selectedDate,
                          );

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
      );
    },
  );

  nameController.dispose();
  caloriesController.dispose();
  proteinController.dispose();
  carbsController.dispose();
  fatsController.dispose();
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
      return StatefulBuilder(
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
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                      validator: _positiveDecimalValidator,
                    ),
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
                    const SizedBox(height: 6),
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
      );
    },
  );

  weightController.dispose();
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
      return Padding(
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
                TextFormField(
                  controller: waterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Agua diaria (ml)',
                  ),
                  validator: _positiveIntValidator,
                ),
                TextFormField(
                  controller: workoutController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Entreno diario (min)',
                  ),
                  validator: _positiveIntValidator,
                ),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      store.updateGoals(
                        store.goals.copyWith(
                          calorieGoal: int.parse(calorieController.text.trim()),
                          waterGoalMl: int.parse(waterController.text.trim()),
                          workoutGoalMinutes: int.parse(
                            workoutController.text.trim(),
                          ),
                          targetWeightKg: double.parse(
                            targetWeightController.text.trim(),
                          ),
                        ),
                      );

                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Guardar objetivos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  calorieController.dispose();
  waterController.dispose();
  workoutController.dispose();
  targetWeightController.dispose();
}

/// Valida que el campo no venga vacio.
String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obligatorio';
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
  final parsed = double.tryParse(value?.trim() ?? '');
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

/// Generador simple de id unico local.
String _newId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
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
