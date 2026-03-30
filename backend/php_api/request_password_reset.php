<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

app_require_post();
$payload = app_read_json_body();

$email = app_normalize_email((string) ($payload['email'] ?? ''));
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa un correo valido.',
    ]);
}

try {
    $db = app_db();
    $user = app_find_user_by_email($db, $email);

    $resetCode = null;
    if ($user !== null) {
        $resetCode = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $resetHash = password_hash($resetCode, PASSWORD_DEFAULT);
        $expiresAt = (new DateTimeImmutable('+15 minutes'))->format('Y-m-d H:i:s');
        $userId = (string) $user['id'];

        $stmt = $db->prepare(
            'INSERT INTO password_reset_tickets (user_id, email, reset_code_hash, expires_at, used_at)
             VALUES (?, ?, ?, ?, NULL)
             ON DUPLICATE KEY UPDATE
               email = VALUES(email),
               reset_code_hash = VALUES(reset_code_hash),
               expires_at = VALUES(expires_at),
               used_at = NULL'
        );
        $stmt->bind_param('ssss', $userId, $email, $resetHash, $expiresAt);
        $stmt->execute();
        $stmt->close();
    }

    $response = [
        'success' => true,
        'message' => 'Si el correo existe, enviaremos un codigo de verificacion.',
    ];

    if (getenv('APPFITNESS_RESET_DEBUG') === '1' && $resetCode !== null) {
        $response['resetCode'] = $resetCode;
    }

    app_send_json(200, $response);
} catch (mysqli_sql_exception $error) {
    app_send_json(500, [
        'success' => false,
        'message' => 'No se pudo generar el codigo de recuperacion.',
    ]);
}
