import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class DashboardPage extends StatefulWidget {
  final String namaAnggota;
  final String token;
  final String anggotaId;

  const DashboardPage({
    super.key,
    required this.namaAnggota,
    required this.token,
    required this.anggotaId,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHomepage();
  }

  Future<void> _navigateToHomepage() async {
    // Small delay to show loading indicator
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navigate to Homepage using the passed parameters
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => Homepage(
              namaAnggota: widget.namaAnggota,
              anggotaId: widget.anggotaId,
            ),
      ),
    );
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
