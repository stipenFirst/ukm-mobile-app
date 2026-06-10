<?php
class AbsensiModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function create(int $activityId, int $userId, int $ukmId, ?float $latitude, ?float $longitude, ?float $distance): int
    {
        $stmt = $this->db->prepare('INSERT INTO absensi_ukm (id_aktivitas, id_user, id_ukm, latitude, longitude, jarak_meter, status)
            VALUES (:id_aktivitas, :id_user, :id_ukm, :latitude, :longitude, :jarak_meter, "Hadir")');
        $stmt->execute([
            'id_aktivitas' => $activityId,
            'id_user' => $userId,
            'id_ukm' => $ukmId,
            'latitude' => $latitude,
            'longitude' => $longitude,
            'jarak_meter' => $distance,
        ]);
        return (int)$this->db->lastInsertId();
    }

    public function findByUserAndActivity(int $userId, int $activityId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM absensi_ukm WHERE id_user = :id_user AND id_aktivitas = :id_aktivitas LIMIT 1');
        $stmt->execute(['id_user' => $userId, 'id_aktivitas' => $activityId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function historyByMember(int $userId, int $ukmId): array
    {
        $stmt = $this->db->prepare('SELECT ab.id_absensi, ab.id_aktivitas, ab.id_user, ab.id_ukm, ab.latitude, ab.longitude,
            ab.jarak_meter, ab.status, ab.waktu_absen,
            ak.judul, ak.deskripsi, ak.tanggal_mulai, ak.lokasi,
            u.nama, uk.nama_ukm
            FROM absensi_ukm ab
            JOIN aktivitas_ukm ak ON ak.id_aktivitas = ab.id_aktivitas
            JOIN users u ON u.id = ab.id_user
            JOIN ukm uk ON uk.id = ab.id_ukm
            WHERE ab.id_user = :id_user AND ab.id_ukm = :id_ukm
            ORDER BY ab.waktu_absen DESC');
        $stmt->execute(['id_user' => $userId, 'id_ukm' => $ukmId]);
        return $stmt->fetchAll();
    }
}
