import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatelessWidget {
  final String namaAnggota;
  final String anggotaId;

  const Homepage({
    super.key,
    required this.namaAnggota,
    required this.anggotaId,
    required String title,
    required String token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Selamat Datang, $namaAnggota'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  'Halo, $namaAnggota!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anggota ID: $anggotaId',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? anggotaId;
  String? userId;
  String? namaAnggota;

  @override
  void initState() {
    super.initState();
    _checkLoginData();
  }

  Future<void> _checkLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final anggota = prefs.getString('anggota_id');
    final user = prefs.getString('id_user');
    final nama = prefs.getString('nama');

    if (anggota == null || user == null || nama == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data login tidak ditemukan")),
      );
      return;
    }

    setState(() {
      anggotaId = anggota;
      userId = user;
      namaAnggota = nama;
    });

    // Pindah ke homepage setelah data di-load
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => Homepage(
                namaAnggota: namaAnggota!,
                anggotaId: anggotaId!,
                title: '',
                token: '',
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      ),
    );
  }
}
