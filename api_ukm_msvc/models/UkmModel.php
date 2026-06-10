<?php
class UkmModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function all(): array
    {
        return $this->db->query('SELECT id, nama_ukm, kategori, deskripsi, latitude, longitude FROM ukm ORDER BY nama_ukm ASC')->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT id, nama_ukm, kategori, deskripsi, latitude, longitude FROM ukm WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(array $data): int
    {
        $stmt = $this->db->prepare('INSERT INTO ukm (nama_ukm, kategori, deskripsi, latitude, longitude)
            VALUES (:nama_ukm, :kategori, :deskripsi, :latitude, :longitude)');
        $stmt->execute($data);
        return (int)$this->db->lastInsertId();
    }

    public function update(int $id, array $data): bool
    {
        $data['id'] = $id;
        $stmt = $this->db->prepare('UPDATE ukm SET nama_ukm = :nama_ukm, kategori = :kategori, deskripsi = :deskripsi,
            latitude = :latitude, longitude = :longitude WHERE id = :id');
        return $stmt->execute($data);
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('DELETE FROM ukm WHERE id = :id');
        return $stmt->execute(['id' => $id]);
    }

    public function acceptedMembers(int $ukmId): array
    {
        $stmt = $this->db->prepare('SELECT u.id, u.nama, u.email, u.nim, u.fakultas, u.prodi, p.tanggal_daftar
            FROM pendaftaran p
            JOIN users u ON u.id = p.id_user
            WHERE p.id_ukm = :id_ukm AND p.status = "Diterima"
            ORDER BY u.nama ASC');
        $stmt->execute(['id_ukm' => $ukmId]);
        return $stmt->fetchAll();
    }
}
