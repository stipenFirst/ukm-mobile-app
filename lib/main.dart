import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/admin_dashboard_screen.dart'; // IMPORT HALAMAN ADMIN
import 'controllers/auth_controller.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive untuk penyimpanan lokal
  await Hive.initFlutter();
  
  // Membuka kotak penyimpanan bernama 'sessionBox'
  await Hive.openBox('sessionBox'); 
  
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah sudah ada token yang tersimpan
    var box = Hive.box('sessionBox');
    String? token = box.get('token');
    String? role = box.get('role'); // Ambil role yang tersimpan

    // Logika Pintar untuk menentukan layar awal
    Widget initialScreen = const LoginScreen();
    if (token != null) {
      if (role == 'admin') {
        initialScreen = const AdminDashboardScreen();
      } else {
        initialScreen = const HomeScreen();
      }
    }

    return GetMaterialApp(
      title: 'Aplikasi UKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: initialScreen, // Gunakan initialScreen yang sudah ditentukan di atas
    );
  }
}