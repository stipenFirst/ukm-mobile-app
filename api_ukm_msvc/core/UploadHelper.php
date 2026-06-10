<?php
class UploadHelper
{
    private const MAX_SIZE = 2 * 1024 * 1024; // 2 MB
    private const ALLOWED_MIME = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];

    public static function saveProfileImage(array $file, int $userId): string
    {
        if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            Response::error('File gambar tidak valid.');
        }

        if (($file['size'] ?? 0) > self::MAX_SIZE) {
            Response::error('Ukuran gambar maksimal 2 MB.');
        }

        $mime = mime_content_type($file['tmp_name']);
        if (!isset(self::ALLOWED_MIME[$mime])) {
            Response::error('Format gambar harus JPG, PNG, atau WEBP.');
        }

        $uploadDir = __DIR__ . '/../uploads';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        $extension = self::ALLOWED_MIME[$mime];
        $fileName = 'profil_' . $userId . '_' . bin2hex(random_bytes(8)) . '.' . $extension;
        $target = $uploadDir . DIRECTORY_SEPARATOR . $fileName;

        if (!move_uploaded_file($file['tmp_name'], $target)) {
            Response::error('Gagal menyimpan file gambar.');
        }

        return $fileName;
    }

    public static function deleteProfileImage(?string $fileName): void
    {
        if (!$fileName) {
            return;
        }

        $path = realpath(__DIR__ . '/../uploads/' . basename($fileName));
        $uploadDir = realpath(__DIR__ . '/../uploads');

        if ($path && $uploadDir && str_starts_with($path, $uploadDir) && file_exists($path)) {
            unlink($path);
        }
    }
}
