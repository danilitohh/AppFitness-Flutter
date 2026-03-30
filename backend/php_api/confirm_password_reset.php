<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

app_require_post();
$payload = app_read_json_body();

$email = app_normalize_email((string) ($payload['email'] ?? ''));
$code = trim((string) ($payload['code'] ?? ''));
$newPassword = (string) ($payload['newPassword'] ?? '');

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa un correo valido.',
    ]);
}

$passwordError = app_password_error($newPassword);
if ($passwordError !== null) {
    app_send_json(400, [
        'success' => false,
        'message' => $passwordError,
    ]);
}

if (strlen($code) !== 6) {
    app_send_json(400, [
        'success' => false,
        'message' => 'Ingresa un codigo de 6 digitos.',
    ]);
}

try {
    $db = app_db();

    $stmt = $db->prepare(
        'SELECT u.id AS user_id, u.email, t.id AS ticket_id, t.reset_code_hash, t.expires_at, t.used_at
         FROM users u
         LEFT JOIN password_reset_tickets t ON t.user_id = u.id
         WHERE u.email = ?
         LIMIT 1'
    );
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    if (!is_array($row)) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Codigo invalido o vencido.',
        ]);
    }

    if ($row['ticket_id'] === null || $row['reset_code_hash'] === null) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Codigo invalido o vencido.',
        ]);
    }

    if ($row['used_at'] !== null) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Codigo invalido o vencido.',
        ]);
    }

    $expiresAt = new DateTimeImmutable((string) $row['expires_at']);
    if ($expiresAt < new DateTimeImmutable()) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Codigo invalido o vencido.',
        ]);
    }

    if (!password_verify($code, (string) $row['reset_code_hash'])) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Codigo invalido o vencido.',
        ]);
    }

    $passwordHash = app_password_hash($newPassword);
    $userId = (string) $row['user_id'];
    $ticketId = (int) $row['ticket_id'];

    $updateUserStmt = $db->prepare(
        'UPDATE users
         SET password_hash = ?, updated_at = CURRENT_TIMESTAMP
         WHERE id = ?'
    );
    $updateUserStmt->bind_param('ss', $passwordHash, $userId);
    $updateUserStmt->execute();
    $updateUserStmt->close();

    $markTicketStmt = $db->prepare(
        'UPDATE password_reset_tickets
         SET used_at = CURRENT_TIMESTAMP
         WHERE id = ?'
    );
    $markTicketStmt->bind_param('i', $ticketId);
    $markTicketStmt->execute();
    $markTicketStmt->close();

    app_send_json(200, [
        'success' => true,
        'message' => 'Contrase?a actualizada. Ya puedes iniciar sesion.',
    ]);
} catch (mysqli_sql_exception $error) {
    app_send_json(500, [
        'success' => false,
        'message' => 'No se pudo actualizar la contrase?a.',
    ]);
}
