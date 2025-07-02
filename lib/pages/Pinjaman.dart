// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PinjamanPage extends StatefulWidget {
  final String title;
  final List<dynamic> selectedBooks;

  const PinjamanPage({
    Key? key,
    required this.title,
    required this.selectedBooks,
  }) : super(key: key);

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> bukuDipilih = [];
  int lamaPinjamHari = 1;
  bool isLoading = false;

  String? anggotaId;
  String? userId;

  late AnimationController _controller;
  late Animation<double> _animation;

  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFF3B82F6);
  final Color cardBlue = const Color(0xFFEFF6FF);
  final Color backgroundBlue = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      anggotaId = prefs.getString('anggota_id');
      userId = prefs.getString('user_id');
    });
  }

  void toggleBuku(Map<String, dynamic> buku) {
    setState(() {
      if (bukuDipilih.any((b) => b['id'] == buku['id'])) {
        bukuDipilih.removeWhere((b) => b['id'] == buku['id']);
      } else {
        if (bukuDipilih.length < 3 &&
            buku['status']?.toLowerCase() != 'dipinjam') {
          bukuDipilih.add(buku);
        }
      }
    });
  }

  Future<void> _submitPinjaman() async {
    if (bukuDipilih.isEmpty) {
      _showCustomSnackBar(
        "Pilih setidaknya 1 buku",
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('http://192.168.1.27:8000/api/peminjaman');
    final tanggalPinjam = DateTime.now();
    final tanggalKembali = tanggalPinjam.add(Duration(days: lamaPinjamHari));

    try {
      for (var buku in bukuDipilih) {
        final body = {
          'anggota_id': anggotaId,
          'buku_id': buku['id'],
          'tanggal_pinjam': tanggalPinjam.toIso8601String(),
          'tanggal_kembali': tanggalKembali.toIso8601String(),
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorData = jsonDecode(response.body);
          _showCustomSnackBar(
            "Gagal meminjam buku: ${errorData['message'] ?? 'Terjadi kesalahan'}",
            Colors.red,
            Icons.error,
          );
          return;
        }
      }

      setState(() {
        isLoading = false;
        bukuDipilih.clear();
      });

      _showCustomSnackBar(
        "Pinjaman berhasil!",
        Colors.green,
        Icons.check_circle,
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/pengembalian',
            arguments: {'refresh': true, 'show_success': true},
          );
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showCustomSnackBar("Kesalahan koneksi: $e", Colors.red, Icons.error);
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(title: Text(widget.title), backgroundColor: primaryBlue),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children:
                          widget.selectedBooks.map((buku) {
                            final selected = bukuDipilih.any(
                              (b) => b['id'] == buku['id'],
                            );
                            return CheckboxListTile(
                              title: Text(buku['judul'] ?? 'Tanpa Judul'),
                              subtitle: Text(
                                "Pengarang: ${buku['pengarang'] ?? '-'}",
                              ),
                              value: selected,
                              onChanged: (checked) => toggleBuku(buku),
                              activeColor: lightBlue,
                            );
                          }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: lamaPinjamHari.toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Lama pinjam (hari)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final hari = int.tryParse(value);
                            if (hari != null && hari >= 1 && hari <= 30) {
                              setState(() => lamaPinjamHari = hari);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _submitPinjaman,
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Konfirmasi Peminjaman"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
