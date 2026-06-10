<?php
class AuthController
{
    private AuthService $auth;

    public function __construct()
    {
        $this->auth = new AuthService();
    }

    public function register(): void
    {
        Request::requirePost();
        $this->auth->register(
            Request::input('nama', ''),
            Request::input('email', ''),
            Request::input('password', '')
        );
        Response::success(null, 'Registrasi berhasil. Silakan login.');
    }

    public function login(): void
    {
        Request::requirePost();
        $data = $this->auth->login(Request::input('email', ''), Request::input('password', ''));
        Response::success($data, 'Login berhasil.');
    }
}
