import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import '../../config/api_config.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  List _pendaftaranList = [];
  bool _isLoading = true;

  List _ukmList = [];
  bool _isLoadingUkm = true;

  List _keanggotaanAktifList = [];
  bool _isLoadingKeanggotaan = true;

  List _saranList = [];
  bool _isLoadingSaran = true;

  final TextEditingController _namaUkmCtrl = TextEditingController();
  final TextEditingController _kategoriCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _longCtrl = TextEditingController();

  final TextEditingController _judulAktivitasCtrl = TextEditingController();
  final TextEditingController _deskripsiAktivitasCtrl = TextEditingController();
  final TextEditingController _tanggalAktivitasCtrl = TextEditingController();
  final TextEditingController _lokasiAktivitasCtrl = TextEditingController();

  Map<String, String> _authHeaders() {
    final token = Hive.box('sessionBox').get('token')?.toString() ?? '';
    return {'Authorization': 'Bearer $token'};
  }

  @override
  void initState() {
    super.initState();
    _fetchPendaftaranData();
    _fetchUkmData();
    _fetchKeanggotaanAktif();
    _fetchSaranData();
  }

  @override
  void dispose() {
    _namaUkmCtrl.dispose();
    _kategoriCtrl.dispose();
    _deskripsiCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    _judulAktivitasCtrl.dispose();
    _deskripsiAktivitasCtrl.dispose();
    _tanggalAktivitasCtrl.dispose();
    _lokasiAktivitasCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPendaftaranData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.endpoint('get_pendaftaran.php')), headers: _authHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _pendaftaranList = data['data'] ?? []);
        }
      } else {
        _showSnackBar('Error server saat memuat pendaftaran.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal memuat data pendaftaran.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String statusBaru) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('update_status_pendaftaran.php')),
        headers: _authHeaders(),
        body: {'id': id, 'status': statusBaru},
      );
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar(data['message'] ?? 'Status berhasil diperbarui.', statusBaru == 'Diterima' ? Colors.green : Colors.orange);
          await _fetchPendaftaranData();
          await _fetchKeanggotaanAktif();
        } else {
          _showSnackBar(data['message'] ?? 'Gagal memperbarui status.', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal terhubung ke server.', Colors.red);
    }
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
      _showSnackBar('Gagal memuat data UKM.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingUkm = false);
    }
  }

  Future<void> _simpanUkm({String? idUkm}) async {
    if (_namaUkmCtrl.text.trim().isEmpty || _kategoriCtrl.text.trim().isEmpty) {
      _showSnackBar('Nama dan kategori UKM wajib diisi.', Colors.orange);
      return;
    }

    Navigator.pop(context);
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final url = idUkm == null ? ApiConfig.endpoint('tambah_ukm.php') : ApiConfig.endpoint('edit_ukm.php');
    final bodyData = {
      'nama_ukm': _namaUkmCtrl.text.trim(),
      'kategori': _kategoriCtrl.text.trim(),
      'deskripsi': _deskripsiCtrl.text.trim(),
      'latitude': _latCtrl.text.trim(),
      'longitude': _longCtrl.text.trim(),
    };
    if (idUkm != null) bodyData['id'] = idUkm;

    try {
      final response = await http.post(Uri.parse(url), headers: _authHeaders(), body: bodyData);
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar(data['message'] ?? 'UKM berhasil disimpan.', Colors.green);
          _fetchUkmData();
        } else {
          _showSnackBar(data['message'] ?? 'Gagal menyimpan UKM.', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal menghubungi server.', Colors.red);
    }
  }

  Future<void> _hapusUkm(String idUkm) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.post(Uri.parse(ApiConfig.endpoint('hapus_ukm.php')), headers: _authHeaders(), body: {'id': idUkm});
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar('UKM berhasil dihapus.', Colors.green);
          _fetchUkmData();
          _fetchKeanggotaanAktif();
        } else {
          _showSnackBar(data['message'] ?? 'Gagal menghapus UKM.', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal menghubungi server.', Colors.red);
    }
  }

  Future<void> _lihatAnggotaUkm(String idUkm, String namaUkm) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.post(Uri.parse(ApiConfig.endpoint('get_anggota_ukm.php')), headers: _authHeaders(), body: {'id_ukm': idUkm});
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showAnggotaDialog(namaUkm, data['data'] ?? []);
        } else {
          _showSnackBar('Belum ada anggota yang diterima di UKM ini.', Colors.orange);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal memuat data anggota.', Colors.red);
    }
  }

  Future<void> _fetchKeanggotaanAktif() async {
    setState(() => _isLoadingKeanggotaan = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.endpoint('get_keanggotaan_aktif.php')), headers: _authHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _keanggotaanAktifList = data['data'] ?? []);
        }
      }
    } catch (e) {
      _showSnackBar('Gagal memuat keanggotaan aktif.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingKeanggotaan = false);
    }
  }

  Future<void> _fetchSaranData() async {
    setState(() => _isLoadingSaran = true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.endpoint('get_saran.php')), headers: _authHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _saranList = data['data'] ?? []);
        }
      } else {
        _showSnackBar('Error server saat memuat saran.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal memuat data saran.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingSaran = false);
    }
  }

  Future<void> _hapusKeanggotaan(Map item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Keanggotaan?'),
        content: Text("Yakin ingin menghapus ${item['nama']} dari ${item['nama_ukm']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('hapus_keanggotaan.php')),
        headers: _authHeaders(),
        body: {'id_pendaftaran': item['id_pendaftaran'].toString()},
      );
      if (mounted) Navigator.pop(context);
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar('Keanggotaan berhasil dihapus.', Colors.green);
        _fetchKeanggotaanAktif();
        _fetchPendaftaranData();
      } else {
        _showSnackBar(data['message'] ?? 'Gagal menghapus keanggotaan.', Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal menghapus keanggotaan.', Colors.red);
    }
  }

  Future<void> _showAbsensiHistory(Map item) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final url = "${ApiConfig.endpoint('get_absensi_anggota.php')}?id_user=${item['id_user']}&id_ukm=${item['id_ukm']}";
      final response = await http.get(Uri.parse(url), headers: _authHeaders());
      if (mounted) Navigator.pop(context);
      final data = json.decode(response.body);
      final List history = data['status'] == 'success' ? (data['data'] ?? []) : [];
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Kehadiran ${item['nama']}"),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: history.isEmpty
                ? const Center(child: Text('Belum ada riwayat kehadiran.'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final h = history[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(h['judul']?.toString() ?? '-'),
                          subtitle: Text("Waktu absen: ${h['waktu_absen'] ?? '-'}\nJarak: ${h['jarak_meter'] ?? '-'} meter"),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal memuat riwayat kehadiran.', Colors.red);
    }
  }

  Future<void> _simpanAktivitas(String idUkm) async {
    if (_judulAktivitasCtrl.text.trim().isEmpty || _tanggalAktivitasCtrl.text.trim().isEmpty) {
      _showSnackBar('Judul dan tanggal aktivitas wajib diisi.', Colors.orange);
      return;
    }
    Navigator.pop(context);
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('tambah_aktivitas.php')),
        headers: _authHeaders(),
        body: {
          'id_ukm': idUkm,
          'judul': _judulAktivitasCtrl.text.trim(),
          'deskripsi': _deskripsiAktivitasCtrl.text.trim(),
          'tanggal_mulai': _tanggalAktivitasCtrl.text.trim(),
          'lokasi': _lokasiAktivitasCtrl.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context);
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _showSnackBar('Aktivitas berhasil ditambahkan.', Colors.green);
      } else {
        _showSnackBar(data['message'] ?? 'Gagal menambahkan aktivitas.', Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Gagal menambahkan aktivitas.', Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Admin'),
        content: const Text('Anda yakin ingin keluar dari panel admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box('sessionBox');
              box.delete('token');
              box.delete('role');
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _logout(context);
    } else {
      setState(() => _selectedIndex = index);
      if (index == 2) _fetchKeanggotaanAktif();
    }
  }

  void _showFormUkmDialog({Map? ukm}) {
    final isEdit = ukm != null;
    if (isEdit) {
      _namaUkmCtrl.text = ukm['nama_ukm']?.toString() ?? '';
      _kategoriCtrl.text = ukm['kategori']?.toString() ?? '';
      _deskripsiCtrl.text = ukm['deskripsi']?.toString() ?? '';
      _latCtrl.text = ukm['latitude']?.toString() ?? '';
      _longCtrl.text = ukm['longitude']?.toString() ?? '';
    } else {
      _namaUkmCtrl.clear();
      _kategoriCtrl.clear();
      _deskripsiCtrl.clear();
      _latCtrl.clear();
      _longCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit UKM' : 'Tambah UKM Baru'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _namaUkmCtrl, decoration: const InputDecoration(labelText: 'Nama UKM', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _kategoriCtrl, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _deskripsiCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: _latCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _longCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()))),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () => _simpanUkm(idUkm: isEdit ? ukm['id'].toString() : null), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white), child: const Text('Simpan')),
        ],
      ),
    );
  }

  void _showTambahAktivitasDialog(Map ukm) {
    _judulAktivitasCtrl.clear();
    _deskripsiAktivitasCtrl.clear();
    _tanggalAktivitasCtrl.text = DateTime.now().toString().substring(0, 16).replaceFirst('T', ' ');
    _lokasiAktivitasCtrl.text = 'Sekretariat UKM';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Aktivitas ${ukm['nama_ukm']}"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _judulAktivitasCtrl, decoration: const InputDecoration(labelText: 'Judul Aktivitas', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _deskripsiAktivitasCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _tanggalAktivitasCtrl, decoration: const InputDecoration(labelText: 'Tanggal Mulai, contoh: 2026-06-03 15:30:00', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _lokasiAktivitasCtrl, decoration: const InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () => _simpanAktivitas(ukm['id'].toString()), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white), child: const Text('Simpan Aktivitas')),
        ],
      ),
    );
  }

  void _showAnggotaDialog(String namaUkm, List anggotaList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Anggota: $namaUkm'),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: anggotaList.isEmpty
              ? const Center(child: Text('Belum ada anggota.'))
              : ListView.builder(
                  itemCount: anggotaList.length,
                  itemBuilder: (context, index) {
                    final anggota = anggotaList[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                      title: Text(anggota['nama']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("NIM: ${anggota['nim'] ?? '-'}\nFakultas: ${anggota['fakultas'] ?? '-'}"),
                      isThreeLine: true,
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }

  void _konfirmasiHapusUkm(String idUkm, String namaUkm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus UKM?'),
        content: Text('Yakin ingin menghapus UKM $namaUkm? Semua data pendaftaran dan aktivitas terkait UKM ini akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _hapusUkm(idUkm); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Ya, Hapus')),
        ],
      ),
    );
  }

  Widget _adminHeader({required String title, required String subtitle, IconData icon = Icons.admin_panel_settings}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 58, left: 22, right: 22, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red.shade600, Colors.orange.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: Colors.white, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.82)))])),
      ]),
    );
  }

  Widget _buildValidasiTab(String namaAdmin) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _adminHeader(title: 'Halo, $namaAdmin', subtitle: 'Kelola persetujuan anggota UKM.', icon: Icons.checklist_rtl),
      Expanded(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pendaftaranList.isEmpty
                ? const Center(child: Text('Belum ada pendaftaran baru.', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _fetchPendaftaranData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendaftaranList.length,
                      itemBuilder: (context, index) {
                        final item = _pendaftaranList[index];
                        final status = item['status']?.toString() ?? 'Pending';
                        final isPending = status == 'Pending';
                        final statusColor = status == 'Diterima' ? Colors.green : (status == 'Ditolak' ? Colors.red : Colors.orange);
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Expanded(child: Text(item['nama_mahasiswa']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                                Chip(label: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)), backgroundColor: statusColor.withOpacity(0.1)),
                              ]),
                              const SizedBox(height: 6),
                              Text("Mendaftar ke: ${item['nama_ukm']}", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Text("Alasan: ${item['alasan_bergabung']}", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700))),
                              if (isPending) ...[
                                const SizedBox(height: 14),
                                Row(children: [
                                  Expanded(child: OutlinedButton.icon(onPressed: () => _updateStatus(item['id'].toString(), 'Ditolak'), icon: const Icon(Icons.close, color: Colors.red), label: const Text('Tolak', style: TextStyle(color: Colors.red)))),
                                  const SizedBox(width: 10),
                                  Expanded(child: ElevatedButton.icon(onPressed: () => _updateStatus(item['id'].toString(), 'Diterima'), icon: const Icon(Icons.check), label: const Text('Terima'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
                                ]),
                              ],
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }

  Widget _buildKelolaUkmTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _adminHeader(title: 'Manajemen UKM', subtitle: 'Tambah, edit, hapus, lihat anggota, dan tambah aktivitas.', icon: Icons.storefront),
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _showFormUkmDialog(), icon: const Icon(Icons.add), label: const Text('Tambah UKM'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))))),
      Expanded(
        child: _isLoadingUkm
            ? const Center(child: CircularProgressIndicator())
            : _ukmList.isEmpty
                ? const Center(child: Text('Belum ada UKM terdaftar.', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _fetchUkmData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _ukmList.length,
                      itemBuilder: (context, index) {
                        final ukm = _ukmList[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: Text(ukm['nama_ukm'][0].toUpperCase(), style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold))),
                            title: Text(ukm['nama_ukm'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(ukm['kategori'] ?? 'UMUM'),
                            trailing: Wrap(spacing: 2, children: [
                              IconButton(icon: const Icon(Icons.event_available, color: Colors.green), onPressed: () => _showTambahAktivitasDialog(ukm), tooltip: 'Tambah Aktivitas'),
                              IconButton(icon: const Icon(Icons.people, color: Colors.blue), onPressed: () => _lihatAnggotaUkm(ukm['id'].toString(), ukm['nama_ukm']), tooltip: 'Lihat Anggota'),
                              IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showFormUkmDialog(ukm: ukm), tooltip: 'Edit UKM'),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _konfirmasiHapusUkm(ukm['id'].toString(), ukm['nama_ukm']), tooltip: 'Hapus UKM'),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }

  Widget _buildKeanggotaanTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _adminHeader(title: 'Keanggotaan Aktif', subtitle: 'Pantau anggota diterima, total kehadiran, dan hapus keanggotaan.', icon: Icons.groups_2),
      Expanded(
        child: _isLoadingKeanggotaan
            ? const Center(child: CircularProgressIndicator())
            : _keanggotaanAktifList.isEmpty
                ? const Center(child: Text('Belum ada anggota aktif.', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _fetchKeanggotaanAktif,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _keanggotaanAktifList.length,
                      itemBuilder: (context, index) {
                        final item = _keanggotaanAktifList[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.verified_user, color: Colors.green.shade700)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['nama']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(item['nama_ukm']?.toString() ?? '-', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600))])),
                                IconButton(onPressed: () => _hapusKeanggotaan(item), icon: const Icon(Icons.person_remove, color: Colors.red), tooltip: 'Hapus Keanggotaan'),
                              ]),
                              const SizedBox(height: 12),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                _infoChip(Icons.badge, "NIM: ${item['nim'] ?? '-'}"),
                                _infoChip(Icons.check_circle, "Hadir: ${item['total_kehadiran'] ?? 0}"),
                                _infoChip(Icons.history, "Terakhir: ${item['terakhir_absen'] ?? '-'}"),
                              ]),
                              const SizedBox(height: 12),
                              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showAbsensiHistory(item), icon: const Icon(Icons.fact_check), label: const Text('Lihat Riwayat Kehadiran'))),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: Colors.red.shade700), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 12))]),
    );
  }

  Widget _buildSaranTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_unread, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kotak Saran Mahasiswa',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_saranList.length} saran masuk',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Muat ulang',
                onPressed: _fetchSaranData,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingSaran
              ? const Center(child: CircularProgressIndicator())
              : _saranList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Belum ada saran masuk',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _saranList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final saran = _saranList[index];
                        final nama = saran['nama']?.toString() ?? 'Anonim';
                        final email = saran['email']?.toString() ?? '';
                        final isi = saran['isi_saran']?.toString() ?? '';
                        final tanggal = saran['tanggal_kirim']?.toString() ?? '';
                        final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(inisial,
                                          style: TextStyle(color: Colors.blue.shade700,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(nama,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 14)),
                                          if (email.isNotEmpty)
                                            Text(email,
                                                style: TextStyle(
                                                    fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tanggal.length >= 10 ? tanggal.substring(0, 10) : tanggal,
                                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Text(isi, style: const TextStyle(fontSize: 14, height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('sessionBox');
    final namaAdmin = box.get('nama_user')?.toString() ?? 'Admin';
    final pages = [
      _buildValidasiTab(namaAdmin),
      _buildKelolaUkmTab(),
      _buildKeanggotaanTab(),
      _buildSaranTab(),
      const SizedBox(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red.shade800,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl), label: 'Validasi'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Kelola UKM'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_2), label: 'Anggota'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Saran'),
          BottomNavigationBarItem(icon: Icon(Icons.logout, color: Colors.red), label: 'Keluar'),
        ],
      ),
    );
  }
}
