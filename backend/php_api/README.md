# AppFitness Auth API (PHP + MySQL)

API minima para autenticacion de `AppFitness` sobre MySQL/MariaDB.

## Endpoints

- `POST /register.php`
- `POST /login.php`
- `POST /request_password_reset.php`
- `POST /confirm_password_reset.php`

## Configuracion

Por defecto usa:

- host: `127.0.0.1`
- port: `3306`
- db: `appfitness`
- user: `root`
- pass: ``

Puedes sobreescribir con variables de entorno:

- `APPFITNESS_DB_HOST`
- `APPFITNESS_DB_PORT`
- `APPFITNESS_DB_NAME`
- `APPFITNESS_DB_USER`
- `APPFITNESS_DB_PASS`

### Modo demo (recuperacion)

Por seguridad, el endpoint de recuperacion ya no devuelve el codigo. Si quieres
verlo en desarrollo local, activa:

- `APPFITNESS_RESET_DEBUG=1`

## Publicacion en XAMPP

1. Copiar esta carpeta a `htdocs`:

```bash
cp -R backend/php_api /Applications/XAMPP/xamppfiles/htdocs/appfitness_api
```

2. Verificar en navegador:

`http://localhost/appfitness_api/index.php`

## Flutter

La app usa por defecto:

- Android emulador: `http://10.0.2.2/appfitness_api`
- Web/desktop: `http://localhost/appfitness_api`

Puedes personalizarlo con:

```bash
flutter run --dart-define=API_BASE_URL=http://TU_HOST/appfitness_api
```
