<?php
class UkmService
{
    private UkmModel $ukm;

    public function __construct()
    {
        $this->ukm = new UkmModel();
    }

    public function all(): array
    {
        return $this->ukm->all();
    }

    public function create(array $input): int
    {
        $data = $this->validate($input);
        return $this->ukm->create($data);
    }

    public function update(int $id, array $input): void
    {
        if (!$this->ukm->find($id)) {
            Response::error('Data UKM tidak ditemukan.', 404);
        }
        $this->ukm->update($id, $this->validate($input));
    }

    public function delete(int $id): void
    {
        if (!$this->ukm->find($id)) {
            Response::error('Data UKM tidak ditemukan.', 404);
        }
        $this->ukm->delete($id);
    }

    public function members(int $ukmId): array
    {
        return $this->ukm->acceptedMembers($ukmId);
    }

    private function validate(array $input): array
    {
        $nama = trim((string)($input['nama_ukm'] ?? ''));
        $kategori = trim((string)($input['kategori'] ?? ''));
        $deskripsi = trim((string)($input['deskripsi'] ?? ''));
        $latitude = trim((string)($input['latitude'] ?? ''));
        $longitude = trim((string)($input['longitude'] ?? ''));

        if ($nama === '' || $kategori === '') {
            Response::error('Nama UKM dan kategori wajib diisi.');
        }

        return [
            'nama_ukm' => $nama,
            'kategori' => $kategori,
            'deskripsi' => $deskripsi,
            'latitude' => $latitude === '' ? null : (float)$latitude,
            'longitude' => $longitude === '' ? null : (float)$longitude,
        ];
    }
}
