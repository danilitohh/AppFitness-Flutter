<?php
declare(strict_types=1);

return [
    'db_host' => getenv('APPFITNESS_DB_HOST') ?: '127.0.0.1',
    'db_port' => (int) (getenv('APPFITNESS_DB_PORT') ?: '3306'),
    'db_name' => getenv('APPFITNESS_DB_NAME') ?: 'appfitness',
    'db_user' => getenv('APPFITNESS_DB_USER') ?: 'root',
    'db_pass' => getenv('APPFITNESS_DB_PASS') ?: '',
];
