<?php
class SaranController
{
    public function index(): void
    {
        Request::requireGet();
        AuthMiddleware::user('admin');
        $data = (new SaranModel())->getAll();
        Response::success($data, 'Data saran berhasil dimuat.');
    }

    public function store(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $isi = Request::input('isi_saran', '');
        if ($isi === '') {
            Response::error('Isi saran tidak boleh kosong.');
        }
        (new SaranModel())->create((int)$user['id'], $isi);
        Response::success(null, 'Saran berhasil dikirim.');
    }
}
