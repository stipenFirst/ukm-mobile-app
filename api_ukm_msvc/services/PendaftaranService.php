<?php
class PendaftaranService
{
    private PendaftaranModel $pendaftaran;

    public function __construct()
    {
        $this->pendaftaran = new PendaftaranModel();
    }

    public function all(): array
    {
        return $this->pendaftaran->all();
    }

    public function daftar(int $userId, int $ukmId, string $alasan): int
    {
        if ($ukmId <= 0 || trim($alasan) === '') {
            Response::error('UKM dan alasan bergabung wajib diisi.');
        }

        if ($this->pendaftaran->findByUserAndUkm($userId, $ukmId)) {
            Response::error('Anda sudah pernah mendaftar di UKM ini.');
        }

        return $this->pendaftaran->create($userId, $ukmId, trim($alasan));
    }

    public function updateStatus(int $id, string $status): void
    {
        $allowed = ['Pending', 'Diterima', 'Ditolak'];
        if ($id <= 0 || !in_array($status, $allowed, true)) {
            Response::error('ID atau status tidak valid.');
        }
        $this->pendaftaran->updateStatus($id, $status);
    }
}
