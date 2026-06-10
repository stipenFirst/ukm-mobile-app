<?php
class Request
{
    public static function all(): array
    {
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (str_contains($contentType, 'application/json')) {
            $raw = file_get_contents('php://input');
            $json = json_decode($raw ?: '', true);
            if (is_array($json)) {
                return array_merge($_GET, $json);
            }
        }
        return array_merge($_GET, $_POST);
    }

    public static function input(string $key, mixed $default = null): mixed
    {
        $data = self::all();
        return isset($data[$key]) ? trim((string)$data[$key]) : $default;
    }

    public static function requirePost(): void
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            Response::error('Method harus POST.', 405);
        }
    }

    public static function requireGet(): void
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            Response::error('Method harus GET.', 405);
        }
    }

    public static function bearerToken(): ?string
    {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authorization = $headers['Authorization']
            ?? $headers['authorization']
            ?? ($_SERVER['HTTP_AUTHORIZATION'] ?? '');

        if (preg_match('/Bearer\s+(\S+)/', $authorization, $matches)) {
            return $matches[1];
        }

        return self::input('token');
    }
}
