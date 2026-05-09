part of '../main.dart';

// -----------------------------------------------------------------------------
// Dominio de autenticacion.
// Modelos, tickets temporales y store para login, registro y recuperacion.
// -----------------------------------------------------------------------------
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
