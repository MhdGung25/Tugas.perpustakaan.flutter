import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Pinjaman.dart';

class BukuPage extends StatefulWidget {
  final String title;
  final String namaAnggota;

  const BukuPage({Key? key, required this.title, required this.namaAnggota})
    : super(key: key);

  @override
  State<BukuPage> createState() => _BukuPageState();
}

class _BukuPageState extends State<BukuPage> with TickerProviderStateMixin {
  bool isLoading = false;
  List<dynamic> bukuList = [];
  List<dynamic> bukuPinjaman = [];
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchBuku();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  Future<void> fetchBuku() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.8:8000/api/buku'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          setState(() => bukuList = body['data']);
        } else {
          setState(() => bukuList = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Format data tidak valid dari server."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data dari server.")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan jaringan.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void pinjamBuku(Map<String, dynamic> buku) {
    if (bukuPinjaman.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 3 buku boleh dipinjam")),
      );
      return;
    }

    if (bukuPinjaman.any((item) => item['id'] == buku['id'])) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Buku sudah dipilih")));
      return;
    }

    setState(() => bukuPinjaman.add(buku));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Buku berhasil ditambahkan")));
  }

  void batalkanPinjaman(Map<String, dynamic> buku) {
    setState(() {
      bukuPinjaman.removeWhere((item) => item['id'] == buku['id']);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Peminjaman dibatalkan")));
  }

  Widget _buildBukuPinjaman() {
    if (bukuPinjaman.isEmpty) {
      return const Center(child: Text("Belum ada buku dipilih"));
    }

    return ListView.builder(
      itemCount: bukuPinjaman.length,
      itemBuilder: (context, index) {
        final buku = bukuPinjaman[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.blueAccent),
            title: Text(
              buku['judul'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Pengarang: ${buku['pengarang'] ?? '-'}"),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              onPressed: () => batalkanPinjaman(buku),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListBuku() {
    return ListView.builder(
      itemCount: bukuList.length,
      itemBuilder: (context, index) {
        final buku = bukuList[index];
        return SlideTransition(
          position: _slideAnimation,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blueAccent),
              title: Text(
                buku['judul'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Pengarang: ${buku['pengarang'] ?? '-'}"),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => pinjamBuku(buku),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // light blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // matching homepage
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          widget.namaAnggota,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              )
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Buku yang akan dipinjam:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 130,
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _buildBukuPinjaman(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1.2),
                        const Text(
                          "Daftar Buku",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: _buildListBuku()),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: Colors.transparent,
                      child: ElevatedButton.icon(
                        onPressed:
                            bukuPinjaman.isEmpty
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PinjamanPage(
                                            title: "Pinjaman",
                                            selectedBooks: bukuPinjaman,
                                          ),
                                    ),
                                  );
                                },
                        icon: const Icon(Icons.library_books),
                        label: const Text("Lihat Pinjaman"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blue.shade100,
                          disabledForegroundColor: Colors.white70,
                          minimumSize: const Size.fromHeight(50),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
