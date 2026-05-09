part of '../main.dart';

// -----------------------------------------------------------------------------
// Utilidades transversales.
// Helpers puros para validacion, formato, hashing y conversiones seguras.
// -----------------------------------------------------------------------------
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
