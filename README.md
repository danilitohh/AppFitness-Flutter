# AppFitness

Proyecto movil para seguimiento fitness, entrenamientos, nutricion,
hidratacion, peso y progreso, con API PHP/MySQL para autenticacion.

## Estructura

```text
backend/
  database/        Esquema MySQL/MariaDB.
  php_api/         Endpoints PHP de autenticacion.

frontend/
  lib/main.dart    Punto de entrada Flutter.
  lib/src/         Modulos Dart por dominio y pantalla.
  android/ ios/    Proyectos nativos.
  assets/ test/    Recursos y pruebas Flutter.
  scripts/         Scripts de build, branding e instalacion.
```

La raiz queda como punto de coordinacion y documentacion; el codigo de backend
y frontend esta separado en carpetas independientes.

## Backend con MySQL (XAMPP)

1. Crear esquema:

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root < backend/database/appfitness_schema.sql
```

2. Publicar API en Apache de XAMPP:

```bash
mkdir -p /Applications/XAMPP/xamppfiles/htdocs/appfitness_api
cp backend/php_api/*.php /Applications/XAMPP/xamppfiles/htdocs/appfitness_api/
```

3. Verificar API:

`http://localhost/appfitness_api/index.php`

## Frontend Flutter

Ejecuta los comandos desde `frontend/`:

```bash
cd frontend
flutter pub get
flutter run -d emulator-5554
```

Android emulador usa `http://10.0.2.2/appfitness_api` por defecto. Para otro
host:

```bash
flutter run --dart-define=API_BASE_URL=http://TU_HOST/appfitness_api
```

## Arranque estable en Windows

Desde la raiz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\frontend\scripts\open_android_stable.ps1
```

Tambien hay una tarea de VS Code llamada `Abrir App Android (estable)`.
