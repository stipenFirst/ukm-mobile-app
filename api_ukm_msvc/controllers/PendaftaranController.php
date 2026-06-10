<?php
class PendaftaranController
{
    private PendaftaranService $service;

    public function __construct()
    {
        $this->service = new PendaftaranService();
    }

    public function index(): void
    {
        Request::requireGet();
        AuthMiddleware::user('admin');
        Response::success($this->service->all(), 'Data pendaftaran berhasil dimuat.');
    }

    public function daftar(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $id = $this->service->daftar((int)$user['id'], (int)Request::input('id_ukm', 0), Request::input('alasan_bergabung', ''));
        Response::success(['id' => $id], 'Pendaftaran berhasil. Menunggu konfirmasi admin.');
    }

    public function updateStatus(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $this->service->updateStatus((int)Request::input('id', 0), Request::input('status', ''));
        Response::success(null, 'Status pendaftaran berhasil diperbarui.');
    }
}
