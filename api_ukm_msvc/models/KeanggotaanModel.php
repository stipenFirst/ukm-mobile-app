<?php
class KeanggotaanModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function acceptedUkmByUser(int $userId): array
    {
        $stmt = $this->db->prepare('SELECT p.id AS id_pendaftaran, p.tanggal_daftar, p.status,
            uk.id, uk.nama_ukm, uk.kategori, uk.deskripsi, uk.latitude, uk.longitude
            FROM pendaftaran p
            JOIN ukm uk ON uk.id = p.id_ukm
            WHERE p.id_user = :id_user AND p.status = "Diterima"
            ORDER BY uk.nama_ukm ASC');
        $stmt->execute(['id_user' => $userId]);
        return $stmt->fetchAll();
    }

    public function statusByUserAndUkm(int $userId, int $ukmId): ?array
    {
        $stmt = $this->db->prepare('SELECT id, id_user, id_ukm, status, tanggal_daftar
            FROM pendaftaran
            WHERE id_user = :id_user AND id_ukm = :id_ukm
            LIMIT 1');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function isAcceptedMember(int $userId, int $ukmId): bool
    {
        $stmt = $this->db->prepare('SELECT id FROM pendaftaran
            WHERE id_user = :id_user AND id_ukm = :id_ukm AND status = "Diterima"
            LIMIT 1');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
        return (bool)$stmt->fetch();
    }

    public function activeMembers(): array
    {
        $stmt = $this->db->query('SELECT p.id AS id_pendaftaran, p.id_user, p.id_ukm, p.tanggal_daftar,
            u.nama, u.email, u.nim, u.fakultas, u.prodi,
            uk.nama_ukm, uk.kategori,
            COUNT(a.id_absensi) AS total_kehadiran,
            MAX(a.waktu_absen) AS terakhir_absen
            FROM pendaftaran p
            JOIN users u ON u.id = p.id_user
            JOIN ukm uk ON uk.id = p.id_ukm
            LEFT JOIN absensi_ukm a ON a.id_user = p.id_user AND a.id_ukm = p.id_ukm
            WHERE p.status = "Diterima"
            GROUP BY p.id, p.id_user, p.id_ukm, p.tanggal_daftar, u.nama, u.email, u.nim, u.fakultas, u.prodi, uk.nama_ukm, uk.kategori
            ORDER BY uk.nama_ukm ASC, u.nama ASC');
        return $stmt->fetchAll();
    }

    public function deleteMembership(int $pendaftaranId): bool
    {
        $stmt = $this->db->prepare('DELETE FROM pendaftaran WHERE id = :id AND status = "Diterima"');
        return $stmt->execute(['id' => $pendaftaranId]);
    }
}
