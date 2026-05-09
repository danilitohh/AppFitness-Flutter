import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

part 'src/theme_constants.dart';
part 'src/app_shell.dart';
part 'src/auth_domain.dart';
part 'src/auth_ui.dart';
part 'src/fitness_domain.dart';
part 'src/fitness_store.dart';
part 'src/onboarding_base.dart';
part 'src/onboarding_guided.dart';
part 'src/recommendation_engines.dart';
part 'src/home_shell.dart';
part 'src/chatbot.dart';
part 'src/home_screens.dart';
part 'src/shared_widgets.dart';
part 'src/workout_catalog.dart';
part 'src/entry_sheets.dart';
part 'src/app_utils.dart';

// -----------------------------------------------------------------------------
// Punto de arranque y composicion raiz de la aplicacion.
// Configura locale, estado global y tema principal antes de mostrar pantallas.
// -----------------------------------------------------------------------------
// Punto de entrada de la aplicacion.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  runApp(const FitnessApp());
}
