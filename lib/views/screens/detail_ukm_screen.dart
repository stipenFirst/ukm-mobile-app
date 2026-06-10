import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import '../../config/api_config.dart';

class DetailUkmScreen extends StatefulWidget {
  final Map ukm;

  const DetailUkmScreen({super.key, required this.ukm});

  @override
  State<DetailUkmScreen> createState() => _DetailUkmScreenState();
}

class _DetailUkmScreenState extends State<DetailUkmScreen> {
  bool _isLoading = false;
  final TextEditingController _alasanController = TextEditingController();

  Map<String, String> _authHeaders() {
    final token = Hive.box('sessionBox').get('token')?.toString() ?? '';
    return {'Authorization': 'Bearer $token'};
  }


  // Variabel untuk Geofencing Absensi
  bool _isNear = false;
  double _distanceInMeters = 0.0;
  bool _loadingLocation = false;
  bool _isCheckingStatus = false;
  String _membershipStatus = 'Belum Mendaftar';

  @override
  void initState() {
    super.initState();
    _fetchMembershipStatus();
  }

  Future<void> _fetchMembershipStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.endpoint('cek_status_pendaftaran.php')}?id_ukm=${widget.ukm['id']}"),
        headers: _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final status = data['data']['status']?.toString() ?? 'Belum Mendaftar';
          if (mounted) setState(() => _membershipStatus = status);
        }
      }
    } catch (e) {
      debugPrint('Gagal cek status pendaftaran: $e');
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  // --- RUMUS GEOFENCING (Hitung Jarak) ---
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  Future<void> _checkPresence() async {
    // Validasi apakah koordinat UKM tersedia di database
    if (widget.ukm['latitude'] == null || widget.ukm['longitude'] == null) {
      _showSnackBar("Koordinat sekretariat UKM ini belum diatur di database.", Colors.orange);
      return;
    }

    setState(() => _loadingLocation = true);

    try {
      // 1. Cek apakah GPS (Service Lokasi) di HP menyala
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("GPS mati. Silakan nyalakan GPS / Lokasi di HP Anda.", Colors.red);
        setState(() => _loadingLocation = false);
        return;
      }

      // 2. Cek Izin (Permission)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Izin lokasi ditolak oleh pengguna.", Colors.red);
          setState(() => _loadingLocation = false);
          return;
        }
      }

      // 3. Cek apakah izin ditolak permanen
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Izin lokasi diblokir permanen. Buka pengaturan HP untuk mengubahnya.", Colors.red);
        setState(() => _loadingLocation = false);
        return;
      }

      // 4. Ambil Lokasi Sekarang
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), 
      );

      // 5. Hitung Jarak
      double targetLat = double.parse(widget.ukm['latitude'].toString());
      double targetLong = double.parse(widget.ukm['longitude'].toString());

      double distance = _calculateDistance(position.latitude, position.longitude, targetLat, targetLong);

      setState(() {
        _distanceInMeters = distance;
        _isNear = distance <= 50; // Jarak maksimal absen 50 meter
        _loadingLocation = false;
      });

      if (_isNear) {
        _showSnackBar("Anda di lokasi! Absensi siap dilakukan.", Colors.green);
      } else {
        _showSnackBar("Terlalu jauh! Jarak Anda: ${distance.toStringAsFixed(1)}m dari sekretariat.", Colors.orange);
      }
    } catch (e) {
      debugPrint("Error Lokasi: $e");
      _showSnackBar("Gagal mengambil lokasi. Pastikan sinyal GPS baik.", Colors.red);
      setState(() => _loadingLocation = false);
    }
  }

  // --- FUNGSI DAFTAR UKM ---
  Future<void> _daftarUkm() async {
    if (_alasanController.text.trim().isEmpty) {
      _showSnackBar('Alasan bergabung wajib diisi!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    var box = Hive.box('sessionBox');
    String? idUser = box.get('id_user')?.toString();

    if (idUser == null) {
      _showSnackBar('Sesi error. Silakan logout dan login ulang agar sistem mengenali ID Anda.', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    // PASTIKAN IP INI SESUAI DENGAN IP LAPTOP KAMU
    final String url = ApiConfig.endpoint('daftar_ukm.php');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _authHeaders(),
        body: {
          'id_user': idUser,
          'id_ukm': widget.ukm['id'].toString(),
          'alasan_bergabung': _alasanController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _alasanController.clear();
          if (mounted) {
            _showSnackBar(data['message'], Colors.green);
            Navigator.pop(context); // Kembali ke list dashboard
          }
        } else {
          if (mounted) _showSnackBar(data['message'], Colors.red);
        }
      } else {
        if (mounted) _showSnackBar('Server Error: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Koneksi server gagal', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog dengan TextField untuk alasan bergabung
  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Daftar ${widget.ukm['nama_ukm']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Silakan tulis alasan Anda ingin bergabung dengan UKM ini:"),
            const SizedBox(height: 15),
            TextField(
              controller: _alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Contoh: Ingin mengembangkan bakat dan minat...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _daftarUkm();           // Eksekusi fungsi daftar
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Kirim Pendaftaran"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ukm['nama_ukm']), 
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Visual
            Container(
              height: 200, width: double.infinity, 
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40, backgroundColor: Colors.white,
                    child: Text(
                      widget.ukm['nama_ukm'][0].toUpperCase(), 
                      style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      widget.ukm['kategori']?.toUpperCase() ?? "UMUM", 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.ukm['nama_ukm'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    widget.ukm['deskripsi'] ?? "Belum ada deskripsi untuk UKM ini.", 
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800),
                    textAlign: TextAlign.justify,
                  ),
                  
                  const Divider(height: 40),

                  // --- KOTAK ABSENSI GEOFENCING ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade100)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red), SizedBox(width: 8),
                            Text("Absensi Sekretariat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_distanceInMeters > 0)
                          Text(
                            "Jarak Anda: ${_distanceInMeters.toStringAsFixed(1)} meter", 
                            style: TextStyle(color: _isNear ? Colors.green : Colors.red, fontWeight: FontWeight.bold)
                          ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _loadingLocation ? null : _checkPresence,
                                icon: _loadingLocation 
                                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) 
                                  : const Icon(Icons.my_location, size: 18),
                                label: const Text("CEK LOKASI"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: (_membershipStatus == 'Diterima' && _isNear)
                                  ? () => _showSnackBar("Lokasi valid. Untuk menyimpan absensi aktivitas, buka tab UKM Saya.", Colors.blue)
                                  : null,
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: Text(_membershipStatus == 'Diterima' ? "ABSEN" : "KHUSUS ANGGOTA"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _membershipStatus == 'Diterima' ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _membershipStatus == 'Diterima' ? Colors.green.shade200 : Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(_membershipStatus == 'Diterima' ? Icons.verified_user : Icons.info_outline, color: _membershipStatus == 'Diterima' ? Colors.green : Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isCheckingStatus ? 'Memeriksa status pendaftaran...' : 'Status pendaftaran: $_membershipStatus',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // --- TOMBOL DAFTAR ---
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      onPressed: (_isLoading || _membershipStatus == 'Diterima' || _membershipStatus == 'Pending') ? null : _showJoinDialog,
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.app_registration),
                      label: Text(
                        _isLoading ? "MEMPROSES..." : (_membershipStatus == 'Diterima' ? "SUDAH MENJADI ANGGOTA" : (_membershipStatus == 'Pending' ? "MENUNGGU VALIDASI ADMIN" : "DAFTAR SEBAGAI ANGGOTA")), 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}