import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' show asin, cos, sqrt;
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'login_screen.dart';
import 'detail_ukm_screen.dart';
import '../../config/api_config.dart';
import '../../services/ocr_text_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String _namaUser = '';
  String _idUser = '';
  String _fotoProfil = '';

  List _ukmList = [];
  List _acceptedUkmList = [];
  final Map<String, List> _activityByUkm = {};
  final Map<String, Map<String, dynamic>> _presenceStateByActivity = {};
  bool _isLoadingUkm = true;
  bool _isLoadingAccepted = true;
  bool _isUploadingFoto = false;
  bool _isUpdatingProfile = false;
  bool _isScanning = false;
  String? _loadingActivityId;
  String? _submittingActivityId;

  final TextEditingController _saranController = TextEditingController();
  bool _isKirimSaran = false;

  final TextEditingController _currencyController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _conversionResult = '';
  bool _isConverting = false;
  final List<String> _currencies = ['IDR', 'USD', 'MYR', 'EUR', 'SAR'];

  String _selectedTimeZone = 'WIB';
  String _currentTime = '';
  Timer? _clockTimer;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _fakultasController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  int _tapCount = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  Map<String, String> _authHeaders() {
    final token = Hive.box('sessionBox').get('token')?.toString() ?? '';
    return {'Authorization': 'Bearer $token'};
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUkmData();
    _fetchAcceptedUkmData();
    _startClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _saranController.dispose();
    _currencyController.dispose();
    _namaController.dispose();
    _nimController.dispose();
    _fakultasController.dispose();
    _prodiController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final box = Hive.box('sessionBox');
    setState(() {
      _namaUser = box.get('nama_user')?.toString() ?? 'Mahasiswa';
      _idUser = box.get('id_user')?.toString() ?? '';
      _fotoProfil = box.get('foto_profil')?.toString() ?? '';
      _namaController.text = _namaUser;
    });
  }

  Future<void> _scanKTM() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image == null) return;

    setState(() => _isScanning = true);
    try {
      final rawText = await OcrTextService().recognizeTextFromImagePath(image.path);
      final lines = rawText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      _namaController.clear();
      _nimController.clear();
      _fakultasController.clear();
      _prodiController.clear();
      _alamatController.clear();

      final nimMatch = RegExp(r'\b\d{9,11}\b').firstMatch(rawText);
      if (nimMatch != null) _nimController.text = nimMatch.group(0)!;

      String extractValue(int index, String keyword) {
        var value = lines[index].replaceAll(RegExp(keyword, caseSensitive: false), '').trim();
        value = value.replaceAll(RegExp(r'^[:;\-\s]+'), '').trim();
        if (value.isNotEmpty) return value;
        if (index + 1 < lines.length) {
          final nextLine = lines[index + 1];
          if ((nextLine == ':' || nextLine == ';') && index + 2 < lines.length) {
            return lines[index + 2].replaceAll(RegExp(r'^[:;\-\s]+'), '').trim();
          }
          return nextLine.replaceAll(RegExp(r'^[:;\-\s]+'), '').trim();
        }
        return '';
      }

      for (var i = 0; i < lines.length; i++) {
        final lowerLine = lines[i].toLowerCase();
        if (lowerLine.startsWith('nama') && !lowerLine.contains('universitas')) {
          _namaController.text = extractValue(i, 'nama');
        } else if ((lowerLine.startsWith('nim') || lowerLine.startsWith('npm')) && _nimController.text.isEmpty) {
          _nimController.text = extractValue(i, 'nim');
          if (_nimController.text.isEmpty) _nimController.text = extractValue(i, 'npm');
        } else if (lowerLine.startsWith('fakultas')) {
          _fakultasController.text = extractValue(i, 'fakultas');
        } else if (lowerLine.startsWith('program studi') || lowerLine.startsWith('prodi')) {
          _prodiController.text = extractValue(i, 'program studi');
          if (_prodiController.text.isEmpty) _prodiController.text = extractValue(i, 'prodi');
        } else if (lowerLine.startsWith('alamat')) {
          _alamatController.text = extractValue(i, 'alamat');
        }
      }

      if (_namaController.text.isEmpty && _fakultasController.text.isEmpty) {
        _showRawTextDialog(rawText);
      } else {
        _showSnackBar('Scan AI selesai. Silakan periksa kembali datanya.', Colors.green);
      }
    } on UnsupportedError catch (e) {
      _showSnackBar(e.message ?? 'Fitur scan KTM belum tersedia di platform ini.', Colors.orange);
    } catch (e) {
      _showSnackBar('Gagal membaca teks dari gambar. Pastikan foto terang dan fokus.', Colors.red);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showRawTextDialog(String rawText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Kesulitan Membaca'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pola KTM tidak terdeteksi dengan baik. Pastikan foto tegak, fokus, dan tidak silau. Berikut teks mentah yang berhasil ditangkap:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                child: Text(rawText, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }

  Future<void> _updateProfileData() async {
    if (_namaController.text.trim().isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.orange);
      return;
    }

    setState(() => _isUpdatingProfile = true);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('update_profil.php')),
        headers: _authHeaders(),
        body: {
          'id_user': _idUser,
          'nama': _namaController.text.trim(),
          'nim': _nimController.text.trim(),
          'fakultas': _fakultasController.text.trim(),
          'prodi': _prodiController.text.trim(),
          'alamat': _alamatController.text.trim(),
        },
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final box = Hive.box('sessionBox');
        await box.put('nama_user', _namaController.text.trim());
        setState(() => _namaUser = _namaController.text.trim());
        _showSnackBar(data['message'] ?? 'Profil berhasil diperbarui.', Colors.green);
      } else {
        _showSnackBar(data['message'] ?? 'Gagal menyimpan profil.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Koneksi gagal saat menyimpan profil.', Colors.red);
    } finally {
      if (mounted) setState(() => _isUpdatingProfile = false);
    }
  }

  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    final nowUtc = DateTime.now().toUtc();
    late final DateTime targetTime;
    switch (_selectedTimeZone) {
      case 'WIB':
        targetTime = nowUtc.add(const Duration(hours: 7));
        break;
      case 'WITA':
        targetTime = nowUtc.add(const Duration(hours: 8));
        break;
      case 'WIT':
        targetTime = nowUtc.add(const Duration(hours: 9));
        break;
      case 'London':
        targetTime = nowUtc;
        break;
      default:
        targetTime = nowUtc.add(const Duration(hours: 7));
    }
    final h = targetTime.hour.toString().padLeft(2, '0');
    final m = targetTime.minute.toString().padLeft(2, '0');
    final s = targetTime.second.toString().padLeft(2, '0');
    setState(() => _currentTime = '$h:$m:$s');
  }

  void _showTimeZoneOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final zones = ['WIB', 'WITA', 'WIT', 'London'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.all(16), child: Text('Pilih Zona Waktu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ...zones.map((zone) => ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.blue),
                    title: Text(zone),
                    trailing: _selectedTimeZone == zone ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () {
                      setState(() => _selectedTimeZone = zone);
                      _updateTime();
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _convertCurrency() async {
    if (_currencyController.text.trim().isEmpty) {
      _showSnackBar('Silakan masukkan jumlah uang.', Colors.orange);
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionResult = '';
    });

    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/$_fromCurrency'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final rate = double.parse(data['rates'][_toCurrency].toString());
          final amount = double.parse(_currencyController.text.trim());
          final total = amount * rate;
          setState(() => _conversionResult = '${total.toStringAsFixed(2)} $_toCurrency');
        }
      } else {
        _showSnackBar('Gagal mengambil data tukaran mata uang.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Tidak ada koneksi internet.', Colors.red);
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;

    setState(() => _isUploadingFoto = true);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.endpoint('upload_foto.php')));
      request.headers.addAll(_authHeaders());
      request.fields['id_user'] = _idUser;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
      final res = await request.send();
      final responseData = await res.stream.bytesToString();
      final data = json.decode(responseData);
      if (data['status'] == 'success') {
        final box = Hive.box('sessionBox');
        await box.put('foto_profil', data['foto_profil']);
        setState(() => _fotoProfil = data['foto_profil']);
        _showSnackBar('Foto profil berhasil diperbarui.', Colors.green);
      } else {
        _showSnackBar(data['message'] ?? 'Gagal upload foto.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal menyambung ke server.', Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingFoto = false);
    }
  }

  Future<void> _hapusFotoProfil() async {
    setState(() => _isUploadingFoto = true);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('hapus_foto.php')),
        headers: _authHeaders(),
        body: {'id_user': _idUser},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final box = Hive.box('sessionBox');
        await box.delete('foto_profil');
        setState(() => _fotoProfil = '');
        _showSnackBar('Foto profil berhasil dihapus.', Colors.green);
      } else {
        _showSnackBar(data['message'] ?? 'Gagal hapus foto.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal hapus foto.', Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingFoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.photo_library, color: Colors.blue), title: const Text('Pilih dari Galeri'), onTap: () { Navigator.pop(context); _pickAndUploadImage(); }),
            if (_fotoProfil.isNotEmpty) ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Hapus Foto Profil', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); _hapusFotoProfil(); }),
          ],
        ),
      ),
    );
  }

  void _safeLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box('sessionBox');
              box.delete('token');
              box.delete('role');
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUkmData() async {
    setState(() => _isLoadingUkm = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.endpoint('get_ukm.php')));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _ukmList = data['data'] ?? []);
        }
      }
    } catch (e) {
      _showSnackBar('Sambungan ke API gagal.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingUkm = false);
    }
  }

  Future<void> _fetchAcceptedUkmData() async {
    setState(() => _isLoadingAccepted = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.endpoint('get_ukm_diterima.php')), headers: _authHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _acceptedUkmList = data['data'] ?? []);
        }
      }
    } catch (e) {
      _showSnackBar('Gagal memuat UKM yang sudah diterima.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingAccepted = false);
    }
  }

  Future<void> _fetchActivitiesForUkm(String idUkm) async {
    if (_activityByUkm.containsKey(idUkm)) return;
    setState(() => _activityByUkm[idUkm] = []);
    try {
      final response = await http.get(Uri.parse("${ApiConfig.endpoint('get_aktivitas_user.php')}?id_ukm=$idUkm"), headers: _authHeaders());
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() => _activityByUkm[idUkm] = data['data'] ?? []);
      } else {
        _showSnackBar(data['message'] ?? 'Gagal memuat aktivitas.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal memuat aktivitas UKM.', Colors.red);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  Future<void> _checkActivityLocation(Map ukm, Map activity) async {
    final activityId = activity['id_aktivitas'].toString();
    if (ukm['latitude'] == null || ukm['longitude'] == null) {
      _showSnackBar('Koordinat sekretariat UKM belum diatur.', Colors.orange);
      return;
    }

    setState(() => _loadingActivityId = activityId);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('GPS mati. Silakan aktifkan lokasi.', Colors.red);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showSnackBar('Izin lokasi ditolak.', Colors.red);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
      final targetLat = double.parse(ukm['latitude'].toString());
      final targetLong = double.parse(ukm['longitude'].toString());
      final distance = _calculateDistance(position.latitude, position.longitude, targetLat, targetLong);

      setState(() {
        _presenceStateByActivity[activityId] = {
          'isNear': distance <= 50,
          'distance': distance,
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      });

      _showSnackBar(
        distance <= 50 ? 'Lokasi valid. Absensi siap dilakukan.' : 'Terlalu jauh: ${distance.toStringAsFixed(1)} meter dari sekretariat.',
        distance <= 50 ? Colors.green : Colors.orange,
      );
    } catch (e) {
      _showSnackBar('Gagal mengambil lokasi. Pastikan GPS aktif.', Colors.red);
    } finally {
      if (mounted) setState(() => _loadingActivityId = null);
    }
  }

  Future<void> _submitAbsensi(Map activity) async {
    final activityId = activity['id_aktivitas'].toString();
    final state = _presenceStateByActivity[activityId];
    if (state == null || state['isNear'] != true) {
      _showSnackBar('Cek lokasi dulu dan pastikan jarak maksimal 50 meter.', Colors.orange);
      return;
    }

    setState(() => _submittingActivityId = activityId);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('absen_aktivitas.php')),
        headers: _authHeaders(),
        body: {
          'id_aktivitas': activityId,
          'latitude': state['latitude'].toString(),
          'longitude': state['longitude'].toString(),
          'jarak_meter': state['distance'].toString(),
        },
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar(data['message'] ?? 'Absensi berhasil disimpan.', Colors.green);
        setState(() => _presenceStateByActivity.remove(activityId));
      } else {
        _showSnackBar(data['message'] ?? 'Absensi gagal.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan absensi.', Colors.red);
    } finally {
      if (mounted) setState(() => _submittingActivityId = null);
    }
  }

  Future<void> _kirimSaran() async {
    if (_saranController.text.trim().isEmpty) {
      _showSnackBar('Saran tidak boleh kosong.', Colors.orange);
      return;
    }
    setState(() => _isKirimSaran = true);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('kirim_saran.php')),
        headers: _authHeaders(),
        body: {'id_user': _idUser, 'isi_saran': _saranController.text.trim()},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar('Saran berhasil dikirim. Terima kasih!', Colors.green);
        _saranController.clear();
      } else {
        _showSnackBar(data['message'] ?? 'Gagal mengirim saran.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal mengirim saran.', Colors.red);
    } finally {
      if (mounted) setState(() => _isKirimSaran = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  Widget _modernHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 58, left: 22, right: 22, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500, Colors.cyan.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(34), bottomRight: Radius.circular(34)),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () {
                    _tapCount++;
                    if (_tapCount == 5) {
                      _tapCount = 0;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TarikTambangScreen()));
                    }
                  },
                  child: Text('Selamat Datang,', style: TextStyle(color: Colors.blue.shade50, fontSize: 15)),
                ),
                const SizedBox(width: 6),
                Tooltip(message: "Tekan 5x tulisan 'Selamat Datang' untuk mini game", child: Icon(Icons.info_outline, color: Colors.blue.shade50, size: 16)),
              ]),
              const SizedBox(height: 6),
              Text(_namaUser, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('${_acceptedUkmList.length} UKM diterima • ${_ukmList.length} UKM tersedia', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
            ]),
          ),
          GestureDetector(
            onTap: _showTimeZoneOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.35))),
              child: Column(children: [
                Text(_selectedTimeZone, style: TextStyle(color: Colors.blue.shade50, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(_currentTime, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard() {
    return _modernCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.currency_exchange, color: Colors.blue), SizedBox(width: 8), Text('Kalkulator Mata Uang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))]),
        const SizedBox(height: 16),
        TextField(controller: _currencyController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Masukkan jumlah', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))) ,
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(value: _fromCurrency, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), items: _currencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => setState(() => _fromCurrency = val!))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: Colors.grey)),
          Expanded(child: DropdownButtonFormField<String>(value: _toCurrency, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), items: _currencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => setState(() => _toCurrency = val!))),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isConverting ? null : _convertCurrency, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _isConverting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Konversi Sekarang'))),
        if (_conversionResult.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14)), child: Column(children: [const Text('Hasil Konversi', style: TextStyle(color: Colors.green, fontSize: 12)), Text(_conversionResult, style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold))])),
        ],
      ]),
    );
  }

  Widget _modernCard({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))]),
      child: child,
    );
  }

  Widget _buildHomeTab() {
    return DefaultTabController(
      length: 2,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _modernHeader(),
        Container(
          margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)]),
          child: TabBar(
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
            tabs: const [Tab(icon: Icon(Icons.currency_exchange), text: 'Kalkulator'), Tab(icon: Icon(Icons.groups), text: 'Daftar UKM')],
          ),
        ),
        Expanded(child: TabBarView(children: [
          SingleChildScrollView(child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 20), child: _buildCurrencyCard())),
          _buildCompactUkmList(),
        ])),
      ]),
    );
  }

  Widget _buildCompactUkmList() {
    if (_isLoadingUkm) return const Center(child: CircularProgressIndicator());
    if (_ukmList.isEmpty) return Center(child: TextButton.icon(onPressed: _fetchUkmData, icon: const Icon(Icons.refresh), label: const Text('Muat Ulang')));
    return RefreshIndicator(
      onRefresh: _fetchUkmData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _ukmList.length,
        itemBuilder: (context, index) => _ukmCard(_ukmList[index], compact: true),
      ),
    );
  }

  Widget _ukmCard(Map ukm, {bool compact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.blue.shade50), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 7))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailUkmScreen(ukm: ukm))).then((_) { _fetchAcceptedUkmData(); }),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(width: 54, height: 54, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.cyan.shade300]), borderRadius: BorderRadius.circular(18)), child: Center(child: Text(ukm['nama_ukm'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ukm['nama_ukm']?.toString() ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(ukm['kategori']?.toString() ?? 'UMUM', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600, fontSize: 12)),
              if (!compact) ...[const SizedBox(height: 6), Text(ukm['deskripsi']?.toString() ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700))],
            ])),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ]),
        ),
      ),
    );
  }

  Widget _buildUkmTab() {
    final categories = <String>['Semua'];
    if (_ukmList.isNotEmpty) {
      categories.addAll(_ukmList.map((e) => e['kategori']?.toString().toUpperCase() ?? 'UMUM').where((cat) => cat.isNotEmpty).toSet().toList());
    }

    final filteredUkm = _ukmList.where((ukm) {
      final ukmCategory = ukm['kategori']?.toString().toUpperCase() ?? 'UMUM';
      final ukmName = ukm['nama_ukm'].toString().toLowerCase();
      return (_selectedCategory == 'Semua' || ukmCategory == _selectedCategory) && ukmName.contains(_searchQuery.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('Katalog UKM', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue.shade800))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(hintText: 'Cari nama UKM...', prefixIcon: const Icon(Icons.search, color: Colors.blue), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.blue.shade100))),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: categories.map((cat) {
            final selected = _selectedCategory == cat;
            return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(cat, style: TextStyle(color: selected ? Colors.white : Colors.blue.shade700, fontWeight: FontWeight.bold)), selected: selected, selectedColor: Colors.blue.shade700, backgroundColor: Colors.blue.shade50, onSelected: (value) { if (value) setState(() => _selectedCategory = cat); }));
          }).toList()),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoadingUkm
              ? const Center(child: CircularProgressIndicator())
              : filteredUkm.isEmpty
                  ? Center(child: Text("UKM '$_searchQuery' tidak ditemukan", style: TextStyle(color: Colors.grey.shade600)))
                  : RefreshIndicator(onRefresh: _fetchUkmData, child: ListView.builder(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), itemCount: filteredUkm.length, itemBuilder: (_, i) => _ukmCard(filteredUkm[i]))),
        ),
      ]),
    );
  }

  Widget _buildAcceptedUkmTab() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 4), child: Text('UKM Saya', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue.shade800))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Hanya UKM dengan status diterima yang muncul di sini. Absensi hanya dapat dilakukan dari tab ini.', style: TextStyle(color: Colors.grey.shade700))),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoadingAccepted
              ? const Center(child: CircularProgressIndicator())
              : _acceptedUkmList.isEmpty
                  ? _emptyState(icon: Icons.verified_user_outlined, title: 'Belum menjadi anggota UKM', subtitle: 'Daftar UKM dulu, lalu tunggu admin menerima pendaftaran Anda.')
                  : RefreshIndicator(
                      onRefresh: _fetchAcceptedUkmData,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _acceptedUkmList.length,
                        itemBuilder: (context, index) => _acceptedUkmExpansion(_acceptedUkmList[index]),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _acceptedUkmExpansion(Map ukm) {
    final idUkm = ukm['id'].toString();
    final activities = _activityByUkm[idUkm];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 7))]),
      child: ExpansionTile(
        onExpansionChanged: (open) { if (open) _fetchActivitiesForUkm(idUkm); },
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.verified, color: Colors.green.shade700)),
        title: Text(ukm['nama_ukm']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Diterima sejak ${ukm['tanggal_daftar'] ?? '-'}"),
        children: [
          if (activities == null)
            const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator())
          else if (activities.isEmpty)
            Padding(padding: const EdgeInsets.all(18), child: Text('Belum ada aktivitas untuk UKM ini.', style: TextStyle(color: Colors.grey.shade600)))
          else
            ...activities.map((activity) => _activityCard(ukm, activity)).toList(),
        ],
      ),
    );
  }

  Widget _activityCard(Map ukm, Map activity) {
    final id = activity['id_aktivitas'].toString();
    final state = _presenceStateByActivity[id];
    final isNear = state?['isNear'] == true;
    final distance = state?['distance'] as double?;
    final isChecking = _loadingActivityId == id;
    final isSubmitting = _submittingActivityId == id;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.65), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.blue.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(activity['judul']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 6),
        Text(activity['deskripsi']?.toString() ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _miniInfo(Icons.calendar_month, activity['tanggal_mulai']?.toString() ?? '-'),
          _miniInfo(Icons.place, activity['lokasi']?.toString() ?? 'Sekretariat UKM'),
        ]),
        if (distance != null) ...[
          const SizedBox(height: 10),
          Text('Jarak Anda: ${distance.toStringAsFixed(1)} meter', style: TextStyle(color: isNear ? Colors.green.shade700 : Colors.orange.shade800, fontWeight: FontWeight.bold)),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: isChecking ? null : () => _checkActivityLocation(ukm, activity), icon: isChecking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, size: 18), label: const Text('Cek Lokasi'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(onPressed: isNear && !isSubmitting ? () => _submitAbsensi(activity) : null, icon: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle, size: 18), label: const Text('Absen'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white))),
        ]),
      ]),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: Colors.blue), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12))]),
    );
  }

  Widget _emptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 70, color: Colors.grey.shade400), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.blue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.white));
  }

  Widget _buildProfilTab() {
    final ImageProvider imageProvider = _fotoProfil.isNotEmpty
        ? NetworkImage(ApiConfig.uploadUrl(_fotoProfil))
        : const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png');
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 78, bottom: 36),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade400]), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36))),
          child: Column(children: [
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Stack(alignment: Alignment.bottomRight, children: [
                CircleAvatar(radius: 60, backgroundColor: Colors.white, backgroundImage: imageProvider, child: _isUploadingFoto ? const CircularProgressIndicator() : null),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
              ]),
            ),
            const SizedBox(height: 15),
            Text(_namaUser, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text('User ID: $_idUser', style: const TextStyle(color: Colors.white))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isScanning ? null : _scanKTM, icon: _isScanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.document_scanner), label: Text(_isScanning ? 'MEMINDAI GAMBAR...' : 'Isi Otomatis dengan Scan KTM'), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
            const SizedBox(height: 20),
            _buildTextField('Nama Lengkap', _namaController, Icons.person),
            const SizedBox(height: 12),
            _buildTextField('NIM / NPM', _nimController, Icons.badge),
            const SizedBox(height: 12),
            _buildTextField('Fakultas', _fakultasController, Icons.domain),
            const SizedBox(height: 12),
            _buildTextField('Program Studi', _prodiController, Icons.school),
            const SizedBox(height: 12),
            _buildTextField('Alamat', _alamatController, Icons.home, maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isUpdatingProfile ? null : _updateProfileData, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _isUpdatingProfile ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SIMPAN PROFIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSaranTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Text('Subjek TPM', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue.shade800)),
          const SizedBox(height: 10),
          Text('Bagikan saran dan pandangan Anda mengenai aplikasi dan subjek Teknologi Pembangunan Mudah Alih.', style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          const SizedBox(height: 24),
          TextField(controller: _saranController, maxLines: 6, decoration: InputDecoration(hintText: 'Contoh: Fitur aplikasi sudah menarik...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: Colors.white)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _isKirimSaran ? null : _kirimSaran, icon: _isKirimSaran ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send), label: Text(_isKirimSaran ? 'MENGIRIM...' : 'KIRIM SARAN', style: const TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        ]),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _safeLogout();
    } else {
      setState(() => _selectedIndex = index);
      if (index == 2) _fetchAcceptedUkmData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      _buildUkmTab(),
      _buildAcceptedUkmTab(),
      _buildProfilTab(),
      _buildSaranTab(),
      const SizedBox(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'UKM'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'UKM Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Saran'),
          BottomNavigationBarItem(icon: Icon(Icons.logout, color: Colors.red), label: 'Keluar'),
        ],
      ),
    );
  }
}

class TarikTambangScreen extends StatefulWidget {
  const TarikTambangScreen({super.key});

  @override
  State<TarikTambangScreen> createState() => _TarikTambangScreenState();
}

class _TarikTambangScreenState extends State<TarikTambangScreen> {
  double _scorePlayer1 = 50.0;
  double _scorePlayer2 = 50.0;
  bool _isGameOver = false;
  String _winnerName = "";

  void _onTapPlayer1() {
    if (_isGameOver) return;
    setState(() {
      _scorePlayer1 += 2.0;
      _scorePlayer2 -= 2.0;
      _checkWinner();
    });
  }

  void _onTapPlayer2() {
    if (_isGameOver) return;
    setState(() {
      _scorePlayer2 += 2.0;
      _scorePlayer1 -= 2.0;
      _checkWinner();
    });
  }

  void _checkWinner() {
    if (_scorePlayer1 >= 70.0) {
      _isGameOver = true;
      _winnerName = "PEMAIN MERAH MENANG!";
      _showWinnerDialog();
    } else if (_scorePlayer2 >= 70.0) {
      _isGameOver = true;
      _winnerName = "PEMAIN BIRU MENANG!";
      _showWinnerDialog();
    }
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Permainan Selesai!", textAlign: TextAlign.center),
        content: Text(_winnerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
                child: const Text("Tutup Game", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _scorePlayer1 = 50.0;
                    _scorePlayer2 = 50.0;
                    _isGameOver = false;
                  });
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("Main Lagi (Rematch)"),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: _scorePlayer1.toInt(),
              child: GestureDetector(
                onTap: _onTapPlayer1,
                child: Container(
                  width: double.infinity,
                  color: Colors.redAccent,
                  child: RotatedBox(
                    quarterTurns: 2, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("PEMAIN MERAH", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("TEKAN SECEPAT MUNGKIN!", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 20),
                        Text("${_scorePlayer1.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 10, width: double.infinity, color: Colors.black87,
              child: Center(child: Container(width: 40, height: 10, color: Colors.yellow)),
            ),
            Expanded(
              flex: _scorePlayer2.toInt(),
              child: GestureDetector(
                onTap: _onTapPlayer2,
                child: Container(
                  width: double.infinity,
                  color: Colors.blueAccent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${_scorePlayer2.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 20),
                      const Text("TEKAN SECEPAT MUNGKIN!", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 10),
                      const Text("PEMAIN BIRU", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}