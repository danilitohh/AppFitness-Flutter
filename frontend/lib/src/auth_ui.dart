part of '../main.dart';

// -----------------------------------------------------------------------------
// UI de autenticacion.
// Contenedores, formularios y widgets de apoyo del acceso a la aplicacion.
// -----------------------------------------------------------------------------
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
