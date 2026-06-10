<?php
class AbsensiController
{
    private AbsensiService $service;

    public function __construct()
    {
        $this->service = new AbsensiService();
    }

    public function store(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $id = $this->service->store((int)$user['id'], Request::all());
        Response::success(['id_absensi' => $id], 'Absensi berhasil disimpan.');
    }

    public function historyByMember(): void
    {
        Request::requireGet();
        AuthMiddleware::user('admin');
        $data = $this->service->historyByMember((int)Request::input('id_user', 0), (int)Request::input('id_ukm', 0));
        Response::success($data, 'Riwayat kehadiran berhasil dimuat.');
    }
}
