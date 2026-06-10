<?php
class ProfileService
{
    private UserModel $users;

    public function __construct()
    {
        $this->users = new UserModel();
    }

    public function updateProfile(int $userId, array $input): array
    {
        $data = [
            'nama' => trim((string)($input['nama'] ?? '')),
            'nim' => trim((string)($input['nim'] ?? '')),
            'fakultas' => trim((string)($input['fakultas'] ?? '')),
            'prodi' => trim((string)($input['prodi'] ?? '')),
            'alamat' => trim((string)($input['alamat'] ?? '')),
        ];

        if ($data['nama'] === '') {
            Response::error('Nama tidak boleh kosong.');
        }

        $this->users->updateProfile($userId, $data);
        return $this->users->findById($userId) ?? [];
    }

    public function uploadPhoto(int $userId, array $file): string
    {
        $user = $this->users->findById($userId);
        UploadHelper::deleteProfileImage($user['foto_profil'] ?? null);
        $newFile = UploadHelper::saveProfileImage($file, $userId);
        $this->users->updatePhoto($userId, $newFile);
        return $newFile;
    }

    public function deletePhoto(int $userId): void
    {
        $user = $this->users->findById($userId);
        UploadHelper::deleteProfileImage($user['foto_profil'] ?? null);
        $this->users->updatePhoto($userId, null);
    }
}
