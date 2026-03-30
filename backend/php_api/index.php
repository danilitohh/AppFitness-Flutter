<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

echo json_encode([
    'service' => 'appfitness-auth-api',
    'status' => 'ok',
    'endpoints' => [
        'POST /register.php',
        'POST /login.php',
        'POST /request_password_reset.php',
        'POST /confirm_password_reset.php',
    ],
], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
