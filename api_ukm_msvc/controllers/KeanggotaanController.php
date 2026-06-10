<?php
class KeanggotaanController
{
    private KeanggotaanService $service;

    public function __construct()
    {
        $this->service = new KeanggotaanService();
    }

    public function acceptedUkmForUser(): void
    {
        Request::requireGet();
        $user = AuthMiddleware::user();
        Response::success($this->service->acceptedUkmByUser((int)$user['id']), 'Data UKM yang diterima berhasil dimuat.');
    }

    public function status(): void
    {
        Request::requireGet();
        $user = AuthMiddleware::user();
        $data = $this->service->statusByUserAndUkm((int)$user['id'], (int)Request::input('id_ukm', 0));
        Response::success($data, 'Status pendaftaran berhasil dimuat.');
    }

    public function activeMembers(): void
    {
        Request::requireGet();
        AuthMiddleware::user('admin');
        Response::success($this->service->activeMembers(), 'Data keanggotaan aktif berhasil dimuat.');
    }

    public function deleteMembership(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $this->service->deleteMembership((int)Request::input('id_pendaftaran', 0));
        Response::success(null, 'Keanggotaan berhasil dihapus.');
    }
}
