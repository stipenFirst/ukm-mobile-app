<?php
class AuthMiddleware
{
    public static function user(?string $requiredRole = null): array
    {
        $token = Request::bearerToken();
        if (!$token) {
            Response::error('Token tidak ditemukan. Silakan login kembali.', 401);
        }

        $user = (new AuthService())->userFromToken($token);
        if (!$user) {
            Response::error('Token tidak valid atau sudah kedaluwarsa.', 401);
        }

        if ($requiredRole !== null && ($user['role'] ?? '') !== $requiredRole) {
            Response::error('Akses ditolak. Role tidak sesuai.', 403);
        }

        return $user;
    }
}
