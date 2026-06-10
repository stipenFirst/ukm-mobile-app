<?php
class AuthService
{
    private UserModel $users;
    private TokenModel $tokens;

    public function __construct()
    {
        $this->users = new UserModel();
        $this->tokens = new TokenModel();
    }

    public function register(string $nama, string $email, string $password): void
    {
        if ($nama === '' || $email === '' || $password === '') {
            Response::error('Semua kolom harus diisi.');
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Response::error('Format email tidak valid.');
        }

        if (strlen($password) < 6) {
            Response::error('Password minimal 6 karakter.');
        }

        if ($this->users->findByEmail($email)) {
            Response::error('Email sudah digunakan, silakan gunakan email lain.');
        }

        $this->users->create($nama, $email, password_hash($password, PASSWORD_BCRYPT));
    }

    public function login(string $email, string $password): array
    {
        if ($email === '' || $password === '') {
            Response::error('Email dan password harus diisi.');
        }

        $user = $this->users->findByEmail($email);
        if (!$user || !password_verify($password, $user['password'])) {
            Response::error('Email atau password salah.', 401);
        }

        $this->tokens->deleteExpired();
        $plainToken = bin2hex(random_bytes(32));
        $this->tokens->create((int)$user['id'], $plainToken);

        return [
            'id_user' => (int)$user['id'],
            'nama' => $user['nama'],
            'email' => $user['email'],
            'foto_profil' => $user['foto_profil'],
            'role' => $user['role'],
            'token' => $plainToken,
        ];
    }

    public function userFromToken(string $token): ?array
    {
        return $this->tokens->findUserByToken($token);
    }
}
