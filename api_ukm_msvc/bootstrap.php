<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

spl_autoload_register(function (string $class): void {
    $directories = ['core', 'models', 'services', 'controllers'];
    foreach ($directories as $directory) {
        $file = __DIR__ . DIRECTORY_SEPARATOR . $directory . DIRECTORY_SEPARATOR . $class . '.php';
        if (file_exists($file)) {
            require_once $file;
            return;
        }
    }
});

set_exception_handler(function (Throwable $e): void {
    Response::error('Terjadi kesalahan server.', 500, [
        'detail' => getenv('APP_DEBUG') ? $e->getMessage() : null,
    ]);
});
