<?php
declare(strict_types=1);

// Endpoint de registro.
// Crea el usuario, valida datos base y genera metas iniciales por defecto.

require __DIR__ . '/bootstrap.php';

// 1. Validacion de entrada.
app_require_post();
$payload = app_read_json_body();

$name = trim((string) ($payload['name'] ?? ''));
$email = app_normalize_email((string) ($payload['email'] ?? ''));
$password = (string) ($payload['password'] ?? '');

if ($name === '') {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa tu nombre para crear la cuenta.',
    ]);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa un correo valido.',
    ]);
}

$passwordError = app_password_error($password);
if ($passwordError !== null) {
    app_send_json(400, [
        'success' => false,
        'message' => $passwordError,
    ]);
}

try {
    // 2. Verifica que el correo no exista y crea el usuario nuevo.
    $db = app_db();

    $existing = app_find_user_by_email($db, $email);
    if ($existing !== null) {
        app_send_json(409, [
            'success' => false,
            'message' => 'Ya existe una cuenta con ese correo.',
        ]);
    }

    $passwordHash = app_password_hash($password);
    $createdUser = app_create_user_with_defaults(
        $db,
        $name,
        $email,
        $passwordHash
    );

    app_send_json(201, [
        'success' => true,
        'message' => 'Cuenta creada. Bienvenido.',
        'user' => app_user_payload($createdUser),
    ]);
} catch (mysqli_sql_exception $error) {
    // 3. Error de persistencia en base de datos.
    app_send_json(500, [
        'success' => false,
        'message' => 'Error al crear la cuenta en base de datos.',
    ]);
}
