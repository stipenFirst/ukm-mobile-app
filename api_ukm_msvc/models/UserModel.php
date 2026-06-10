<?php
class UserModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function findByEmail(string $email): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function findById(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT id, nama, email, foto_profil, nim, fakultas, prodi, alamat, role FROM users WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(string $nama, string $email, string $passwordHash): int
    {
        $stmt = $this->db->prepare('INSERT INTO users (nama, email, password, role) VALUES (:nama, :email, :password, "user")');
        $stmt->execute([
            'nama' => $nama,
            'email' => $email,
            'password' => $passwordHash,
        ]);
        return (int)$this->db->lastInsertId();
    }

    public function updateProfile(int $id, array $data): bool
    {
        $stmt = $this->db->prepare('UPDATE users SET nama = :nama, nim = :nim, fakultas = :fakultas, prodi = :prodi, alamat = :alamat WHERE id = :id');
        return $stmt->execute([
            'id' => $id,
            'nama' => $data['nama'],
            'nim' => $data['nim'],
            'fakultas' => $data['fakultas'],
            'prodi' => $data['prodi'],
            'alamat' => $data['alamat'],
        ]);
    }

    public function updatePhoto(int $id, ?string $fileName): bool
    {
        $stmt = $this->db->prepare('UPDATE users SET foto_profil = :foto WHERE id = :id');
        return $stmt->execute(['id' => $id, 'foto' => $fileName]);
    }
}
