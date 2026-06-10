<?php
class UkmController
{
    private UkmService $service;

    public function __construct()
    {
        $this->service = new UkmService();
    }

    public function index(): void
    {
        Request::requireGet();
        Response::success($this->service->all(), 'Data UKM berhasil dimuat.');
    }

    public function store(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $id = $this->service->create(Request::all());
        Response::success(['id' => $id], 'UKM berhasil ditambahkan.');
    }

    public function update(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $id = (int)Request::input('id', 0);
        $this->service->update($id, Request::all());
        Response::success(null, 'UKM berhasil diperbarui.');
    }

    public function destroy(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $this->service->delete((int)Request::input('id', 0));
        Response::success(null, 'UKM berhasil dihapus.');
    }

    public function members(): void
    {
        Request::requirePost();
        AuthMiddleware::user('admin');
        $members = $this->service->members((int)Request::input('id_ukm', 0));
        Response::success($members, 'Data anggota berhasil dimuat.');
    }
}
