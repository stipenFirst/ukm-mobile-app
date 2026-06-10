<?php
class TokenModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }

    public function create(int $userId, string $plainToken): void
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare('INSERT INTO api_tokens (user_id, token_hash, expires_at) VALUES (:user_id, :token_hash, DATE_ADD(NOW(), INTERVAL 7 DAY))');
        $stmt->execute(['user_id' => $userId, 'token_hash' => $hash]);
    }

    public function findUserByToken(string $plainToken): ?array
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare('SELECT u.id, u.nama, u.email, u.foto_profil, u.nim, u.fakultas, u.prodi, u.alamat, u.role
            FROM api_tokens t
            JOIN users u ON u.id = t.user_id
            WHERE t.token_hash = :token_hash AND t.expires_at > NOW()
            LIMIT 1');
        $stmt->execute(['token_hash' => $hash]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function deleteExpired(): void
    {
        $this->db->exec('DELETE FROM api_tokens WHERE expires_at <= NOW()');
    }
}
