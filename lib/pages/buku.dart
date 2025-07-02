// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pinjaman.dart';

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
  List<dynamic> filteredBukuList = [];

  String searchQuery = '';
  String selectedStatus = 'Semua';

  final List<String> statusOptions = ['Semua', 'Tersedia', 'Dipinjam'];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchBuku();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  Future<void> fetchBuku() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.27:8000/api/buku'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          final Set<String> kodeUnik = {};
          final filtered =
              body['data'].where((buku) {
                final kode = buku['kode_buku']?.toString().trim() ?? '';
                if (kodeUnik.contains(kode)) return false;
                kodeUnik.add(kode);
                return true;
              }).toList();

          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            bukuList = filtered;
            filteredBukuList = filtered;
          });
        } else {
          _showMessage("Format data tidak valid dari server.", isError: true);
        }
      } else {
        _showMessage("Gagal memuat data dari server.", isError: true);
      }
    } catch (e) {
      _showMessage("Terjadi kesalahan jaringan.", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  String getStatus(Map<String, dynamic> buku) {
    final stok = buku['stok'] ?? 0;
    return stok > 0 ? 'tersedia' : 'dipinjam';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void pinjamBuku(Map<String, dynamic> buku) {
    final status = getStatus(buku);

    if (bukuPinjaman.length >= 3) {
      _showMessage("Maksimal 3 buku boleh dipinjam", isError: true);
      return;
    }

    final kode = buku['kode_buku'];
    final sudahAda = bukuPinjaman.any((item) => item['kode_buku'] == kode);

    if (sudahAda) {
      _showMessage("Buku dengan kode yang sama sudah dipilih", isError: true);
      return;
    }

    if (status == 'dipinjam') {
      _showMessage("Buku sedang dipinjam oleh anggota lain", isError: true);
      return;
    }

    setState(() => bukuPinjaman.add(buku));
    _showMessage("Buku berhasil ditambahkan");
  }

  void lihatDetailBuku(Map<String, dynamic> buku) {
    final status = getStatus(buku);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(buku['judul'] ?? 'Detail Buku'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kode Buku: ${buku['kode_buku'] ?? '-'}"),
                const SizedBox(height: 8),
                Text("Pengarang: ${buku['pengarang'] ?? '-'}"),
                const SizedBox(height: 8),
                Text(
                  "Status: ${status == 'dipinjam' ? 'Dipinjam' : 'Tersedia'}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }

  void _filterBooks() {
    setState(() {
      filteredBukuList =
          bukuList.where((buku) {
            final judul = buku['judul']?.toString().toLowerCase() ?? '';
            final status = getStatus(buku);
            final cocokCari = judul.contains(searchQuery.toLowerCase());
            final cocokStatus =
                selectedStatus == 'Semua' ||
                (selectedStatus == 'Tersedia' && status != 'dipinjam') ||
                (selectedStatus == 'Dipinjam' && status == 'dipinjam');
            return cocokCari && cocokStatus;
          }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Cari buku...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          _filterBooks();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items:
                            statusOptions
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          selectedStatus = value!;
                          _filterBooks();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filter Status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Text(
                      "Buku yang dipilih (${bukuPinjaman.length}/3)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          bukuPinjaman
                              .map(
                                (buku) => Chip(
                                  label: Text(
                                    "${buku['kode_buku'] ?? ''} - ${buku['judul'] ?? '-'}",
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      bukuPinjaman.removeWhere(
                                        (item) =>
                                            item['kode_buku'] ==
                                            buku['kode_buku'],
                                      );
                                    });
                                    _showMessage("Buku dibatalkan");
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredBukuList.length,
                        itemBuilder: (context, index) {
                          final buku = filteredBukuList[index];
                          final status = getStatus(buku);
                          final sudahDipinjam = status == 'dipinjam';
                          final sudahDipilih = bukuPinjaman.any(
                            (item) => item['kode_buku'] == buku['kode_buku'],
                          );

                          return GestureDetector(
                            onLongPress: () => lihatDetailBuku(buku),
                            onTap: () => pinjamBuku(buku),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.menu_book_rounded,
                                  color:
                                      sudahDipinjam ? Colors.grey : Colors.blue,
                                ),
                                title: Text(
                                  "${buku['kode_buku'] ?? '---'} - ${buku['judul'] ?? '-'}",
                                ),
                                subtitle: Text(
                                  "Pengarang: ${buku['pengarang'] ?? '-'}",
                                ),
                                trailing: Icon(
                                  sudahDipinjam
                                      ? Icons.lock
                                      : sudahDipilih
                                      ? Icons.check
                                      : Icons.add,
                                  color:
                                      sudahDipinjam
                                          ? Colors.grey
                                          : sudahDipilih
                                          ? Colors.green
                                          : Colors.blue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton:
          bukuPinjaman.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
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
                backgroundColor: const Color(0xFF1976D2),
                icon: const Icon(Icons.check),
                label: const Text("Pinjam Buku"),
              )
              : null,
    );
  }
}
