<?php
class Response
{
    public static function success(array|object|null $data = null, string $message = 'Berhasil', int $code = 200): void
    {
        http_response_code($code);
        $payload = ['status' => 'success', 'message' => $message];
        if ($data !== null) {
            $payload['data'] = $data;
        }
        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error(string $message, int $code = 400, array $extra = []): void
    {
        http_response_code($code);
        $payload = ['status' => 'error', 'message' => $message];
        foreach ($extra as $key => $value) {
            if ($value !== null) {
                $payload[$key] = $value;
            }
        }
        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
