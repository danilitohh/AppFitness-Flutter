<?php
declare(strict_types=1);

// Endpoint de login.
// Valida credenciales, admite migracion de hash legacy y devuelve el usuario.

require __DIR__ . '/bootstrap.php';

// 1. Validacion basica del request.
app_require_post();
$payload = app_read_json_body();

$email = app_normalize_email((string) ($payload['email'] ?? ''));
$password = (string) ($payload['password'] ?? '');

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa un correo valido.',
    ]);
}

if (trim($password) === '') {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa tu contrasena.',
    ]);
}

try {
    // 2. Busqueda de usuario y verificacion de credenciales.
    $db = app_db();
    $user = app_find_user_by_email($db, $email);

    $invalidCredentials = function (): void {
        app_send_json(401, [
            'success' => false,
            'message' => 'Correo o contrasena incorrectos.',
        ]);
    };

    if ($user === null) {
        $invalidCredentials();
    }

    $storedHash = trim((string) ($user['password_hash'] ?? ''));
    $valid = app_password_verify($password, $storedHash);
    $usedLegacyHash = false;

    if (!$valid && $storedHash !== '') {
        $legacyHash = app_password_hash_legacy($email, $password);
        if (hash_equals($legacyHash, $storedHash)) {
            $valid = true;
            $usedLegacyHash = true;
        }
    }

    if (!$valid) {
        $invalidCredentials();
    }

    // 3. Si el hash es viejo o requiere upgrade, se reemplaza al iniciar sesion.
    if ($usedLegacyHash || app_password_needs_rehash($storedHash)) {
        $newHash = app_password_hash($password);
        $updateStmt = $db->prepare(
            'UPDATE users
             SET password_hash = ?, updated_at = CURRENT_TIMESTAMP
             WHERE id = ?'
        );
        $updateStmt->bind_param('ss', $newHash, $user['id']);
        $updateStmt->execute();
        $updateStmt->close();
    }

    app_send_json(200, [
        'success' => true,
        'message' => 'Sesion iniciada.',
        'user' => app_user_payload($user),
    ]);
} catch (mysqli_sql_exception $error) {
    // 4. Error de infraestructura o base de datos.
    app_send_json(500, [
        'success' => false,
        'message' => 'Error al validar las credenciales.',
    ]);
}
