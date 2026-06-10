<?php
class AbsensiService
{
    private AbsensiModel $absensi;
    private AktivitasModel $aktivitas;
    private KeanggotaanModel $keanggotaan;

    public function __construct()
    {
        $this->absensi = new AbsensiModel();
        $this->aktivitas = new AktivitasModel();
        $this->keanggotaan = new KeanggotaanModel();
    }

    public function store(int $userId, array $data): int
    {
        $activityId = (int)($data['id_aktivitas'] ?? 0);
        if ($activityId <= 0) {
            Response::error('ID aktivitas tidak valid.');
        }

        $activity = $this->aktivitas->find($activityId);
        if (!$activity) {
            Response::error('Aktivitas tidak ditemukan.', 404);
        }

        $ukmId = (int)$activity['id_ukm'];
        if (!$this->keanggotaan->isAcceptedMember($userId, $ukmId)) {
            Response::error('Absensi hanya dapat dilakukan oleh anggota yang sudah diterima.', 403);
        }

        if ($this->absensi->findByUserAndActivity($userId, $activityId)) {
            Response::error('Anda sudah melakukan absensi untuk aktivitas ini.');
        }

        $distance = isset($data['jarak_meter']) && $data['jarak_meter'] !== '' ? (float)$data['jarak_meter'] : null;
        if ($distance !== null && $distance > 50) {
            Response::error('Absensi ditolak karena jarak Anda lebih dari 50 meter dari sekretariat UKM.');
        }

        $latitude = isset($data['latitude']) && $data['latitude'] !== '' ? (float)$data['latitude'] : null;
        $longitude = isset($data['longitude']) && $data['longitude'] !== '' ? (float)$data['longitude'] : null;

        return $this->absensi->create($activityId, $userId, $ukmId, $latitude, $longitude, $distance);
    }

    public function historyByMember(int $userId, int $ukmId): array
    {
        if ($userId <= 0 || $ukmId <= 0) {
            Response::error('ID anggota atau UKM tidak valid.');
        }

        return $this->absensi->historyByMember($userId, $ukmId);
    }
}
