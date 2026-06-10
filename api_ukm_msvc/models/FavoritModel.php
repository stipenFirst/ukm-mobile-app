<?php
class FavoritModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function isFavorite(int $userId, int $ukmId): bool
    {
        $stmt = $this->db->prepare('SELECT id FROM favorit_ukm WHERE id_user = :id_user AND id_ukm = :id_ukm LIMIT 1');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
        return (bool)$stmt->fetch();
    }

    public function add(int $userId, int $ukmId): void
    {
        if ($this->isFavorite($userId, $ukmId)) {
            return;
        }
        $stmt = $this->db->prepare('INSERT INTO favorit_ukm (id_user, id_ukm) VALUES (:id_user, :id_ukm)');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
    }

    public function remove(int $userId, int $ukmId): bool
    {
        $stmt = $this->db->prepare('DELETE FROM favorit_ukm WHERE id_user = :id_user AND id_ukm = :id_ukm');
        return $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
    }
}
