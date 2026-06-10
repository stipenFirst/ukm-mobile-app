<?php
class KeanggotaanService
{
    private KeanggotaanModel $keanggotaan;

    public function __construct()
    {
        $this->keanggotaan = new KeanggotaanModel();
    }

    public function acceptedUkmByUser(int $userId): array
    {
        return $this->keanggotaan->acceptedUkmByUser($userId);
    }

    public function statusByUserAndUkm(int $userId, int $ukmId): array
    {
        if ($ukmId <= 0) {
            Response::error('ID UKM tidak valid.');
        }

        $row = $this->keanggotaan->statusByUserAndUkm($userId, $ukmId);
        return $row ?: ['status' => 'Belum Mendaftar'];
    }

    public function activeMembers(): array
    {
        return $this->keanggotaan->activeMembers();
    }

    public function deleteMembership(int $pendaftaranId): void
    {
        if ($pendaftaranId <= 0) {
            Response::error('ID keanggotaan tidak valid.');
        }

        $this->keanggotaan->deleteMembership($pendaftaranId);
    }
}
