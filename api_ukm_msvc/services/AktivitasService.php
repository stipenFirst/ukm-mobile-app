<?php
class AktivitasService
{
    private AktivitasModel $aktivitas;
    private KeanggotaanModel $keanggotaan;

    public function __construct()
    {
        $this->aktivitas = new AktivitasModel();
        $this->keanggotaan = new KeanggotaanModel();
    }

    public function forUser(int $userId, int $ukmId): array
    {
        if ($ukmId <= 0) {
            Response::error('ID UKM tidak valid.');
        }

        if (!$this->keanggotaan->isAcceptedMember($userId, $ukmId)) {
            Response::error('Akses aktivitas hanya untuk anggota yang sudah diterima.', 403);
        }

        return $this->aktivitas->allByUkm($ukmId);
    }

    public function forAdmin(?int $ukmId = null): array
    {
        return $this->aktivitas->all($ukmId);
    }

    public function create(array $data): int
    {
        $ukmId = (int)($data['id_ukm'] ?? 0);
        $judul = trim((string)($data['judul'] ?? ''));
        $deskripsi = trim((string)($data['deskripsi'] ?? ''));
        $tanggalMulai = trim((string)($data['tanggal_mulai'] ?? ''));
        $lokasi = trim((string)($data['lokasi'] ?? ''));

        if ($ukmId <= 0 || $judul === '' || $tanggalMulai === '') {
            Response::error('UKM, judul aktivitas, dan tanggal wajib diisi.');
        }

        if ($lokasi === '') {
            $lokasi = 'Sekretariat UKM';
        }

        return $this->aktivitas->create($ukmId, $judul, $deskripsi, $tanggalMulai, $lokasi);
    }
}
