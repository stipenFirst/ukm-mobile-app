<?php
class PendaftaranModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function all(): array
    {
        $stmt = $this->db->query('SELECT p.id, p.id_user, p.id_ukm, u.nama AS nama_mahasiswa, uk.nama_ukm,
            p.alasan_bergabung, p.status, p.tanggal_daftar
            FROM pendaftaran p
            JOIN users u ON p.id_user = u.id
            JOIN ukm uk ON p.id_ukm = uk.id
            ORDER BY p.tanggal_daftar DESC');
        return $stmt->fetchAll();
    }

    public function create(int $userId, int $ukmId, string $alasan): int
    {
        $stmt = $this->db->prepare('INSERT INTO pendaftaran (id_user, id_ukm, alasan_bergabung, status)
            VALUES (:id_user, :id_ukm, :alasan, "Pending")');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId, 'alasan' => $alasan]);
        return (int)$this->db->lastInsertId();
    }

    public function findByUserAndUkm(int $userId, int $ukmId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM pendaftaran WHERE id_user = :id_user AND id_ukm = :id_ukm LIMIT 1');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function updateStatus(int $id, string $status): bool
    {
        $stmt = $this->db->prepare('UPDATE pendaftaran SET status = :status WHERE id = :id');
        return $stmt->execute(['id' => $id, 'status' => $status]);
    }
}
