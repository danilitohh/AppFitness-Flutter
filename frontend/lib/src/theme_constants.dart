part of '../main.dart';

// -----------------------------------------------------------------------------
// Estilo global y recursos visuales compartidos.
// Colores, espaciados y assets base reutilizados en toda la aplicacion.
// -----------------------------------------------------------------------------
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
