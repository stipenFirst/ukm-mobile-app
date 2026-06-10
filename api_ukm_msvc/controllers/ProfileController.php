<?php
class ProfileController
{
    private ProfileService $service;

    public function __construct()
    {
        $this->service = new ProfileService();
    }

    public function update(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $updated = $this->service->updateProfile((int)$user['id'], Request::all());
        Response::success($updated, 'Profil berhasil diperbarui.');
    }

    public function uploadPhoto(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        if (!isset($_FILES['image'])) {
            Response::error('File gambar tidak ditemukan.');
        }
        $fileName = $this->service->uploadPhoto((int)$user['id'], $_FILES['image']);
        Response::success(['foto_profil' => $fileName], 'Foto berhasil diunggah.');
    }

    public function deletePhoto(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $this->service->deletePhoto((int)$user['id']);
        Response::success(null, 'Foto berhasil dihapus.');
    }
}
