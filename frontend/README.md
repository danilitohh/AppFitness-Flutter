# AppFitness Frontend

Aplicacion Flutter de AppFitness. Esta carpeta contiene todo lo necesario para
ejecutar, probar y compilar el cliente movil.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Para apuntar a una API distinta:

```bash
flutter run --dart-define=API_BASE_URL=http://TU_HOST/appfitness_api
```

## Organizacion del codigo

```text
lib/main.dart                 Punto de entrada y composicion de la libreria.
lib/src/app_shell.dart        Tema, scopes y compuerta de autenticacion.
lib/src/auth_domain.dart      Modelos y estado de autenticacion.
lib/src/auth_ui.dart          Formularios de login, registro y recuperacion.
lib/src/fitness_domain.dart   Modelos del dominio fitness.
lib/src/fitness_store.dart    Persistencia local y calculos de negocio.
lib/src/onboarding_*.dart     Flujo inicial del usuario.
lib/src/home_*.dart           Navegacion y pantallas principales.
lib/src/workout_catalog.dart  Catalogo visual de rutinas.
lib/src/entry_sheets.dart     Modales de captura y edicion.
lib/src/app_utils.dart        Validacion, formato y conversiones compartidas.
```
