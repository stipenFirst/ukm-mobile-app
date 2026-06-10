<?php
class NotifikasiModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function byUser(int $userId): array
    {
        $stmt = $this->db->prepare('SELECT n.id_notif, n.judul, n.pesan, n.tanggal, u.nama_ukm
            FROM notifikasi n
            JOIN favorit_ukm f ON n.id_ukm = f.id_ukm
            JOIN ukm u ON n.id_ukm = u.id
            WHERE f.id_user = :id_user
            ORDER BY n.tanggal DESC');
        $stmt->execute(['id_user' => $userId]);
        return $stmt->fetchAll();
    }
}
