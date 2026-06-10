class ApiConfig {
  // Default untuk test Flutter Web/Chrome di laptop dengan XAMPP lokal.
  // Untuk HP fisik, jalankan dengan:
  // flutter run -d <device_id> --dart-define=API_BASE_URL=http://IP_LAPTOP/api_ukm_msvc
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/api_ukm_msvc',
  );

  static String endpoint(String fileName) => '$baseUrl/$fileName';

  static String uploadUrl(String fileName) => '$baseUrl/uploads/$fileName';
}
