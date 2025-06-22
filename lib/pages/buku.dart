import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Pinjaman.dart';

class BukuPage extends StatefulWidget {
  const BukuPage({Key? key, required this.title}) : super(key: key);
  final String title;

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
      duration: const Duration(milliseconds: 600),
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
        Uri.parse('http://192.168.1.9:8000/api/buku'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          setState(() {
            bukuList = body['data'];
          });
        } else {
          setState(() => bukuList = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Format data tidak valid")),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memuat data buku")));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan jaringan")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void pinjamBuku(Map<String, dynamic> buku) {
    if (bukuPinjaman.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimal 3 buku")));
      return;
    }

    if (bukuPinjaman.any((item) => item['id'] == buku['id'])) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Buku sudah dipinjam")));
      return;
    }

    setState(() {
      bukuPinjaman.add(buku);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Buku berhasil dipinjam")));
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
      return const Center(child: Text("Belum ada buku dipinjam"));
    }

    return ListView.builder(
      itemCount: bukuPinjaman.length,
      itemBuilder: (context, index) {
        var buku = bukuPinjaman[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.blue[50],
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
        var buku = bukuList[index];
        return SlideTransition(
          position: _slideAnimation,
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      "Buku yang akan dipinjam:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(height: 160, child: _buildBukuPinjaman()),
                    const Divider(thickness: 1.2),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PinjamanPage(
                                  title: "Pinjaman",
                                  selectedBooks: bukuPinjaman,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.library_books),
                      label: const Text("Lihat Pinjaman"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
