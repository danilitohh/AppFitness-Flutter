# appfitness

Proyecto movil en Flutter para seguimiento fitness (entrenamientos, nutricion,
hidratacion, peso y progreso), con autenticacion local y chatbot de apoyo.

## Auth con MySQL (XAMPP)

El login/registro ahora consume una API PHP conectada a MySQL.

1. Crear esquema:

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root < database/appfitness_schema.sql
```

2. Publicar API en Apache de XAMPP:

```bash
mkdir -p /Applications/XAMPP/xamppfiles/htdocs/appfitness_api
cp backend/php_api/*.php /Applications/XAMPP/xamppfiles/htdocs/appfitness_api/
```

3. Verificar API:

`http://localhost/appfitness_api/index.php`

4. Ejecutar Flutter (Android emulador usa `10.0.2.2` por defecto):

```bash
flutter run -d emulator-5554
```

Si necesitas otro host, usa:

```bash
flutter run --dart-define=API_BASE_URL=http://TU_HOST/appfitness_api
```

## Arranque estable en Windows

Si el emulador se cierra de forma inesperada, usa el arranque estable del
proyecto. Este flujo inicia el AVD con renderizado por software y sin cargar
snapshots viejos.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\open_android_stable.ps1
```

Tambien deje una tarea de VS Code llamada `Abrir App Android (estable)` para
ejecutarlo desde el editor.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
