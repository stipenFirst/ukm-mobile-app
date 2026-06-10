# API UKM - Struktur MSVC/MVC PHP

Versi ini merapikan API UKM dari banyak file PHP prosedural menjadi struktur yang lebih aman dan mudah dirawat.

## Struktur

```text
api_ukm_msvc/
├── bootstrap.php
├── config/
│   └── database.php
├── core/
│   ├── AuthMiddleware.php
│   ├── Database.php
│   ├── Request.php
│   ├── Response.php
│   └── UploadHelper.php
├── controllers/
├── models/
├── services/
├── uploads/
│   └── .htaccess
└── *.php endpoint wrapper
```

## Cara pakai di XAMPP

1. Import `db_ukm.sql` lama.
2. Jalankan `schema_migration.sql` pada database `db_ukm`.
3. Copy folder `api_ukm_msvc` ke `htdocs`.
4. Edit `config/database.php` jika host/user/password database berbeda.
5. Di Flutter, ubah `ApiConfig.baseUrl` menjadi contoh:
   `http://IP-LAPTOP/api_ukm_msvc`

## Catatan keamanan

- Query database sudah memakai PDO prepared statement.
- Login menghasilkan token acak dan token disimpan di tabel `api_tokens`.
- Endpoint admin wajib memakai role `admin`.
- Upload foto dibatasi JPG/JPEG/PNG/WEBP maksimal 2 MB.
- File debug seperti `fix_password.php` dan `test_hash.php` tidak dipakai lagi.

## Update v3 - Keanggotaan Aktif, Aktivitas, dan Absensi

Fitur tambahan:
- User mendapatkan tab **UKM Saya** untuk melihat UKM yang status pendaftarannya sudah `Diterima`.
- User dapat melihat aktivitas UKM dan melakukan absensi aktivitas.
- Absensi hanya dapat disimpan jika user sudah menjadi anggota diterima dan jarak lokasi maksimal 50 meter dari koordinat UKM.
- Admin mendapatkan tab **Anggota** untuk melihat keanggotaan aktif, total kehadiran, riwayat kehadiran, dan menghapus keanggotaan.
- Admin dapat menambahkan aktivitas dari halaman Kelola UKM melalui tombol ikon kalender/event.

Jika database lama sudah pernah dimigrasi, cukup jalankan file:

```sql
schema_migration_keanggotaan_absensi.sql
```

melalui phpMyAdmin pada database `db_ukm`. Jika nama database berbeda, ubah baris `USE db_ukm;` pada file SQL tersebut.
