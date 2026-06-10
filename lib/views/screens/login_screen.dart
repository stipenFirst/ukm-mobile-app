import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart'; 
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; 
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart'; // IMPORT HALAMAN ADMIN
import '../../config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    // Tunggu frame pertama selesai sebelum cek biometrik untuk mencegah crash saat init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    if (kIsWeb) {
      if (mounted) setState(() => _canCheckBiometrics = false);
      return;
    }

    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;
      
      if (mounted) {
        setState(() {
          _canCheckBiometrics = isDeviceSupported && canCheck;
        });
      }
    } catch (e) {
      debugPrint("Gagal mendeteksi hardware biometrik: $e");
    }
  }

  Future<void> _authenticateBiometric() async {
    if (kIsWeb) {
      _showSnackBar('Biometrik tidak tersedia saat test di Chrome/Web.', Colors.orange);
      return;
    }

    try {
      var box = Hive.box('sessionBox');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        _showSnackBar('Sesi tidak ditemukan. Silakan login manual dulu.', Colors.orange);
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk akses cepat',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Memungkinkan PIN jika sidik jari gagal
          useErrorDialogs: true,
        ),
      );

      if (authenticated && mounted) {
        String? role = box.get('role'); // Ambil role dari sesi
        
        // Pengecekan Cabang (Routing) berdasarkan Role
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Error Platform: ${e.code}");
      if (mounted) {
        _showSnackBar('Biometrik Error: ${e.message}', Colors.red);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Email dan Password harus diisi!', Colors.orange);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.endpoint('login.php')),
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          var box = Hive.box('sessionBox');
          await box.put('token', data['data']['token']);
          await box.put('nama_user', data['data']['nama']);
          await box.put('id_user', data['data']['id_user'].toString()); 
          await box.put('role', data['data']['role']); // --- SIMPAN ROLE KE HIVE ---
          
          // --- TAMBAHAN BARU: Simpan nama file foto profil (jika ada) ---
          if (data['data']['foto_profil'] != null) {
            await box.put('foto_profil', data['data']['foto_profil']);
          } else {
            await box.delete('foto_profil'); // Hapus dari sesi jika aslinya kosong
          }

          if(mounted) {
            String? role = data['data']['role'];
            
            // Pengecekan Cabang (Routing) saat Login Manual
            if (role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        } else {
          if(mounted) _showSnackBar(data['message'], Colors.red);
        }
      }
    } catch (e) {
      if(mounted) _showSnackBar('Koneksi Gagal! Pastikan IP Server benar.', Colors.red);
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Icon(Icons.shield_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              const Text("Login Mahasiswa", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true, 
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('MASUK'),
                ),
              ),
              if (_canCheckBiometrics) ...[
                const SizedBox(height: 30),
                const Text("Coba Login Biometrik?", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 60, color: Colors.blue),
                  onPressed: _authenticateBiometric,
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text('Buat Akun Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}