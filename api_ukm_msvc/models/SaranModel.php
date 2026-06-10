<?php
class SaranModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function create(int $userId, string $isiSaran): int
    {
        $stmt = $this->db->prepare('INSERT INTO saran_tpm (id_user, isi_saran) VALUES (:id_user, :isi_saran)');
        $stmt->execute(['id_user' => $userId, 'isi_saran' => $isiSaran]);
        return (int)$this->db->lastInsertId();
    }

    public function getAll(): array
    {
        $stmt = $this->db->query(
            'SELECT s.id_saran, s.isi_saran, s.tanggal_kirim, u.nama, u.email
             FROM saran_tpm s
             LEFT JOIN users u ON s.id_user = u.id
             ORDER BY s.tanggal_kirim DESC'
        );
        return $stmt->fetchAll();
    }
}
