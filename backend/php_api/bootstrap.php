<?php
declare(strict_types=1);

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function app_send_json(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function app_require_post(): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
        app_send_json(405, [
            'success' => false,
            'message' => 'Metodo no permitido. Usa POST.',
        ]);
    }
}

function app_read_json_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        app_send_json(400, [
            'success' => false,
            'message' => 'Cuerpo JSON invalido.',
        ]);
    }

    return $decoded;
}

function app_db(): mysqli
{
    static $db = null;
    if ($db instanceof mysqli) {
        return $db;
    }

    $config = require __DIR__ . '/config.php';
    $db = new mysqli(
        (string) $config['db_host'],
        (string) $config['db_user'],
        (string) $config['db_pass'],
        (string) $config['db_name'],
        (int) $config['db_port'],
    );
    $db->set_charset('utf8mb4');

    return $db;
}

function app_normalize_email(string $value): string
{
    return strtolower(trim($value));
}

function app_password_error(string $value): ?string
{
    if (trim($value) === '') {
        return 'Ingresa una contrasena.';
    }
    if (strlen($value) < 8) {
        return 'Minimo 8 caracteres.';
    }
    if (!preg_match('/[A-Za-z]/', $value)) {
        return 'Incluye al menos una letra.';
    }
    if (!preg_match('/\d/', $value)) {
        return 'Incluye al menos un numero.';
    }
    return null;
}

function app_password_hash(string $password): string
{
    return password_hash($password, PASSWORD_DEFAULT);
}

function app_password_hash_legacy(string $email, string $password): string
{
    return hash('sha256', "{$email}::{$password}::appfitness");
}

function app_password_verify(string $password, string $hash): bool
{
    if ($hash === '') {
        return false;
    }

    return password_verify($password, $hash);
}

function app_password_needs_rehash(string $hash): bool
{
    if ($hash === '') {
        return true;
    }

    return password_needs_rehash($hash, PASSWORD_DEFAULT);
}

function app_new_id(): string
{
    return sprintf('%d%03d', (int) round(microtime(true) * 1000000), random_int(100, 999));
}

function app_user_payload(array $userRow): array
{
    $createdAtRaw = (string) ($userRow['created_at'] ?? date('Y-m-d H:i:s'));
    try {
        $createdAt = (new DateTimeImmutable($createdAtRaw))->format(DATE_ATOM);
    } catch (Exception $error) {
        $createdAt = date(DATE_ATOM);
    }

    return [
        'id' => (string) $userRow['id'],
        'name' => (string) $userRow['full_name'],
        'email' => (string) $userRow['email'],
        'passwordHash' => '',
        'createdAt' => $createdAt,
    ];
}

function app_find_user_by_email(mysqli $db, string $email): ?array
{
    $stmt = $db->prepare(
        'SELECT id, full_name, email, password_hash, created_at
         FROM users
         WHERE email = ?
         LIMIT 1'
    );
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    return is_array($row) ? $row : null;
}

function app_find_user_by_id(mysqli $db, string $userId): ?array
{
    $stmt = $db->prepare(
        'SELECT id, full_name, email, password_hash, created_at
         FROM users
         WHERE id = ?
         LIMIT 1'
    );
    $stmt->bind_param('s', $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    return is_array($row) ? $row : null;
}

function app_ensure_default_goals(mysqli $db, string $userId): void
{
    $stmt = $db->prepare(
        'INSERT INTO fitness_goals (user_id)
         VALUES (?)
         ON DUPLICATE KEY UPDATE user_id = user_id'
    );
    $stmt->bind_param('s', $userId);
    $stmt->execute();
    $stmt->close();
}

function app_create_user_with_defaults(
    mysqli $db,
    string $name,
    string $email,
    string $passwordHash
): array {
    $userId = app_new_id();

    $stmt = $db->prepare(
        'INSERT INTO users (id, full_name, email, password_hash)
         VALUES (?, ?, ?, ?)'
    );
    $stmt->bind_param('ssss', $userId, $name, $email, $passwordHash);
    $stmt->execute();
    $stmt->close();

    app_ensure_default_goals($db, $userId);

    $createdUser = app_find_user_by_id($db, $userId);
    if ($createdUser === null) {
        throw new RuntimeException('No se pudo recuperar el usuario creado.');
    }

    return $createdUser;
}
