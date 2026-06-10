<?php
class NotifikasiController
{
    public function index(): void
    {
        Request::requireGet();
        $user = AuthMiddleware::user();
        $data = (new NotifikasiModel())->byUser((int)$user['id']);
        Response::success($data, 'Data notifikasi berhasil dimuat.');
    }
}
