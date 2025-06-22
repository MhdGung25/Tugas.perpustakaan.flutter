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

  final Color primaryColor = Color(0xFF4A90E2); // biru lembut
  final Color accentColor = Color(0xFF7ED6DF); // hijau pastel
  final Color backgroundColor = Color(0xFFF7F9FB); // putih lembut
  final Color cardColor = Color(0xFFEAF2F8); // abu terang

  @override
  void initState() {
    super.initState();
    bukuPinjaman = [];
    _loadUserSession();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal peminjaman adalah 3 buku")),
      );
      return;
    }

    bool isAlreadyBorrowed = bukuPinjaman.any((b) => b['id'] == buku['id']);

    if (isAlreadyBorrowed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Buku ini sudah dipinjam")));
      return;
    }

    setState(() {
      bukuPinjaman.add(buku);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Buku berhasil dipilih untuk dipinjam")),
    );
  }

  void confirmPinjaman() {
    if (bukuPinjaman.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih buku terlebih dahulu")),
      );
      return;
    }

    if (anggotaId == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data login tidak ditemukan")),
      );
      return;
    }

    _submitPinjaman();
  }

  Future<void> _submitPinjaman() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pinjaman berhasil dibuat")),
        );
        setState(() => bukuPinjaman.clear());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      "Buku Dipilih (${bukuPinjaman.length}/3)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child:
                          bukuPinjaman.isEmpty
                              ? const Center(
                                child: Text("Belum ada buku yang dipilih"),
                              )
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: bukuPinjaman.length,
                                itemBuilder: (context, index) {
                                  var buku = bukuPinjaman[index];
                                  return Container(
                                    width: 240,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Card(
                                      color: cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          buku['judul'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Pengarang: ${buku['pengarang'] ?? ''}",
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red.shade400,
                                          ),
                                          onPressed:
                                              () => setState(() {
                                                bukuPinjaman.removeAt(index);
                                              }),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1),
                    Expanded(
                      child:
                          widget.selectedBooks.isEmpty
                              ? const Center(
                                child: Text("Tidak ada buku tersedia"),
                              )
                              : ListView.builder(
                                itemCount: widget.selectedBooks.length,
                                itemBuilder: (context, index) {
                                  var buku = widget.selectedBooks[index];
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        buku['judul'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Pengarang: ${buku['pengarang'] ?? ''}",
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: primaryColor,
                                        ),
                                        onPressed: () => pinjamBuku(buku),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ScaleTransition(
                        scale: _animation,
                        child: ElevatedButton.icon(
                          onPressed: confirmPinjaman,
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Konfirmasi Peminjaman"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
