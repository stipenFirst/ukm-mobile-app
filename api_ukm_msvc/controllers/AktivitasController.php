<?php
class AktivitasController
{
    private AktivitasService $service;

    public function __construct()
    {
        $this->service = new AktivitasService();
    }

    public function forUser(): void
    {
        Request::requireGet();
        $user = AuthMiddleware::user();
        $data = $this->service->forUser((int)$user['id'], (int)Request::input('id_ukm', 0));
        Response::success($data, 'Aktivitas UKM berhasil dimuat.');
    }

    public function forAdmin(): void
    {
        Request::requireGet();
        AuthMiddleware::user('admin');
        $ukmId = (int)Request::input('id_ukm', 0);
        Response::success($this->service->forAdmin($ukmId > 0 ? $ukmId : null), 'Data aktivitas berhasil dimuat.');
    }

    public function store(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $id = $this->service->create(Request::all());
        Response::success(['id_aktivitas' => $id], 'Aktivitas UKM berhasil ditambahkan.');
    }
}
