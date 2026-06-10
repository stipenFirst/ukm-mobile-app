<?php
class AktivitasModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function allByUkm(int $ukmId): array
    {
        $stmt = $this->db->prepare('SELECT a.id_aktivitas, a.id_ukm, uk.nama_ukm, a.judul, a.deskripsi, a.tanggal_mulai, a.lokasi, a.created_at,
            uk.latitude, uk.longitude
            FROM aktivitas_ukm a
            JOIN ukm uk ON uk.id = a.id_ukm
            WHERE a.id_ukm = :id_ukm
            ORDER BY a.tanggal_mulai DESC, a.id_aktivitas DESC');
        $stmt->execute(['id_ukm' => $ukmId]);
        return $stmt->fetchAll();
    }

    public function all(?int $ukmId = null): array
    {
        if ($ukmId !== null && $ukmId > 0) {
            return $this->allByUkm($ukmId);
        }

        $stmt = $this->db->query('SELECT a.id_aktivitas, a.id_ukm, uk.nama_ukm, a.judul, a.deskripsi, a.tanggal_mulai, a.lokasi, a.created_at,
            uk.latitude, uk.longitude
            FROM aktivitas_ukm a
            JOIN ukm uk ON uk.id = a.id_ukm
            ORDER BY a.tanggal_mulai DESC, a.id_aktivitas DESC');
        return $stmt->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT a.id_aktivitas, a.id_ukm, uk.nama_ukm, a.judul, a.deskripsi, a.tanggal_mulai, a.lokasi,
            uk.latitude, uk.longitude
            FROM aktivitas_ukm a
            JOIN ukm uk ON uk.id = a.id_ukm
            WHERE a.id_aktivitas = :id
            LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(int $ukmId, string $judul, string $deskripsi, string $tanggalMulai, string $lokasi): int
    {
        $stmt = $this->db->prepare('INSERT INTO aktivitas_ukm (id_ukm, judul, deskripsi, tanggal_mulai, lokasi)
            VALUES (:id_ukm, :judul, :deskripsi, :tanggal_mulai, :lokasi)');
        $stmt->execute([
            'id_ukm' => $ukmId,
            'judul' => $judul,
            'deskripsi' => $deskripsi,
            'tanggal_mulai' => $tanggalMulai,
            'lokasi' => $lokasi,
        ]);
        return (int)$this->db->lastInsertId();
    }
}
