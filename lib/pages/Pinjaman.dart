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
  late List<dynamic> bukuPinjaman;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = false;
  String? anggotaId;
  String? userId;

  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFF3B82F6);
  final Color accentBlue = const Color(0xFF60A5FA);
  final Color paleBlue = const Color(0xFFDBEAFE);
  final Color backgroundBlue = const Color(0xFFF8FAFC);
  final Color cardBlue = const Color(0xFFEFF6FF);

  @override
  void initState() {
    super.initState();
    bukuPinjaman = [];
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

  void pinjamBuku(Map<String, dynamic> buku) {
    if (bukuPinjaman.length >= 3) {
      _showCustomSnackBar(
        "Maksimal 3 buku dapat dipinjam",
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    if (buku['status']?.toLowerCase() == 'dipinjam') {
      _showCustomSnackBar("Buku sedang dipinjam", Colors.red, Icons.lock);
      return;
    }

    bool isAlreadyBorrowed = bukuPinjaman.any((b) => b['id'] == buku['id']);
    if (isAlreadyBorrowed) {
      _showCustomSnackBar("Buku sudah dipilih", Colors.red, Icons.error);
      return;
    }

    setState(() => bukuPinjaman.add(buku));
    _showCustomSnackBar("Buku ditambahkan", Colors.green, Icons.check_circle);
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

  Future<void> _submitPinjaman() async {
    final prefs = await SharedPreferences.getInstance();
    final anggotaId = prefs.getString('anggota_id');
    final userId = prefs.getString('user_id');

    final url = Uri.parse('http://192.168.1.9:8000/api/peminjaman');
    final body = {
      "tanggal_pinjaman": DateTime.now().toIso8601String(),
      "lama_pinjaman": 7,
      "keterangan": "Pinjaman Buku",
      "anggota_id": anggotaId,
      "user_id": userId,
      "buku":
          bukuPinjaman.map((b) => {"buku_id": b['id'], "jumlah": 1}).toList(),
    };

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showCustomSnackBar(
          "Pinjaman berhasil",
          Colors.green,
          Icons.check_circle,
        );
        setState(() => bukuPinjaman.clear());
      } else {
        _showCustomSnackBar("Gagal: ${response.body}", Colors.red, Icons.error);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showCustomSnackBar("Error: $e", Colors.red, Icons.error);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryBlue, lightBlue]),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(lightBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Memproses peminjaman...",
                      style: TextStyle(color: primaryBlue),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.book, color: lightBlue),
                            const SizedBox(width: 8),
                            Text(
                              "Dipilih (${bukuPinjaman.length}/3)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...bukuPinjaman.map(
                          (b) => ListTile(
                            title: Text(b['judul'] ?? ''),
                            subtitle: Text(
                              "Pengarang: ${b['pengarang'] ?? '-'}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => setState(() => bukuPinjaman.remove(b)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.selectedBooks.length,
                      itemBuilder: (context, index) {
                        final buku = widget.selectedBooks[index];
                        final isSelected = bukuPinjaman.any(
                          (b) => b['id'] == buku['id'],
                        );
                        final status =
                            buku['status']?.toLowerCase() == 'dipinjam'
                                ? 'Dipinjam'
                                : 'Tersedia';
                        final statusColor =
                            status == 'Dipinjam' ? Colors.red : Colors.green;

                        return Card(
                          color: cardBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(Icons.menu_book, color: lightBlue),
                            title: Text(
                              buku['judul'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pengarang: ${buku['pengarang'] ?? '-'}",
                                  style: TextStyle(
                                    color: primaryBlue.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  "Status: $status",
                                  style: TextStyle(color: statusColor),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: isSelected ? Colors.green : lightBlue,
                              ),
                              onPressed:
                                  isSelected ? null : () => pinjamBuku(buku),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ScaleTransition(
                      scale: _animation,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitPinjaman,
                          icon: const Icon(Icons.check),
                          label: const Text(
                            "Konfirmasi Peminjaman",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
