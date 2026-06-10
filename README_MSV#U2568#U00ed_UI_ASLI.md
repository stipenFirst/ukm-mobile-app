# UKM App MSVC - UI Asli Dipertahankan

Versi ini mempertahankan tampilan awal aplikasi, termasuk halaman user, admin, tab-tab, mini game/easter egg, konversi mata uang, jam dunia, profil, scan KTM, geofencing, dan CRUD admin.

Perubahan utama hanya pada struktur folder dan konfigurasi API:

- `lib/views/screens/` berisi UI lama yang dipertahankan.
- `lib/config/api_config.dart` menjadi pusat URL API.
- `lib/services/ocr_text_service*` memisahkan OCR agar aplikasi tetap bisa dites di Chrome.
- Header token otomatis ditambahkan untuk endpoint yang membutuhkan login/admin.

## Test di Chrome laptop

Pastikan API berada di `C:\xampp\htdocs\api_ukm_msvc`, Apache dan MySQL aktif, lalu jalankan:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Default API untuk Chrome adalah:

```text
http://localhost/api_ukm_msvc
```

## Test di HP fisik

Ganti IP sesuai IP laptop di hotspot/WiFi:

```bash
flutter run -d <device_id> --dart-define=API_BASE_URL=http://IP_LAPTOP/api_ukm_msvc
```

Contoh:

```bash
flutter run -d R58Mxxxx --dart-define=API_BASE_URL=http://192.168.43.25/api_ukm_msvc
```

Atau edit default URL di `lib/config/api_config.dart`.

## Catatan fitur Web

Fitur scan KTM dengan Google ML Kit tidak didukung saat berjalan di Chrome/Web. UI tetap ada, tetapi fitur ini perlu dites di HP Android. Upload foto sudah dibuat kompatibel dengan Chrome dan Android.
