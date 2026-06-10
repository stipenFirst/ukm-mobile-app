<?php
class FavoritController
{
    private FavoritModel $favorit;

    public function __construct()
    {
        $this->favorit = new FavoritModel();
    }

    public function check(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $isFavorite = $this->favorit->isFavorite((int)$user['id'], (int)Request::input('id_ukm', 0));
        Response::success(['is_favorit' => $isFavorite], 'Status favorit berhasil dicek.');
    }

    public function add(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $this->favorit->add((int)$user['id'], (int)Request::input('id_ukm', 0));
        Response::success(null, 'Berhasil mengikuti UKM ini.');
    }

    public function remove(): void
    {
        Request::requirePost();
        $user = AuthMiddleware::user();
        $this->favorit->remove((int)$user['id'], (int)Request::input('id_ukm', 0));
        Response::success(null, 'Batal mengikuti UKM ini.');
    }
}
