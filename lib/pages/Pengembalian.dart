// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PengembalianPage extends StatefulWidget {
  final String title;
  final String namaAnggota;

  const PengembalianPage({
    super.key,
    required this.title,
    required this.namaAnggota,
  });

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage>
    with TickerProviderStateMixin {
  int notificationCount = 0;
  bool isLoading = false;
  List<dynamic> pengembalianList = [];
  List<dynamic> filteredPengembalianList = [];
  List<String> notifications = [];

  String searchQuery = '';
  String selectedStatus = 'Semua';

  final List<String> statusOptions = [
    'Semua',
    'Hari Ini',
    'Besok',
    'Terlambat',
    'Normal',
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    fetchPengembalian();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  Future<void> fetchPengembalian() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.27:8000/api/pengembalian'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          final List<dynamic> data = body['data'];

          List<String> newNotifications = [];
          DateTime now = DateTime.now();

          for (var item in data) {
            String tanggalKembaliStr = item['tanggal_kembali'];
            DateTime tanggalKembali =
                DateTime.tryParse(tanggalKembaliStr) ?? now;
            Duration difference = tanggalKembali.difference(now);

            if (difference.inDays == 0) {
              newNotifications.add(
                "Hari ini adalah batas akhir pengembalian buku dengan kode ${item['kode_pengembalian']}.",
              );
            } else if (difference.inDays == 1) {
              newNotifications.add(
                "Buku dengan kode ${item['kode_pengembalian']} harus dikembalikan besok.",
              );
            } else if (difference.inDays > 1 && difference.inDays <= 3) {
              newNotifications.add(
                "Pengingat: Buku ${item['kode_pengembalian']} akan jatuh tempo dalam ${difference.inDays} hari.",
              );
            } else if (difference.inDays < 0) {
              newNotifications.add(
                "Terlambat! Buku ${item['kode_pengembalian']} seharusnya dikembalikan ${-difference.inDays} hari yang lalu.",
              );
            }
          }

          setState(() {
            pengembalianList = data;
            filteredPengembalianList = data;
            notifications = newNotifications;
            notificationCount = newNotifications.length;
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

  String getStatusPengembalian(Map<String, dynamic> pengembalian) {
    String tanggalKembaliStr = pengembalian['tanggal_kembali'];
    DateTime tanggalKembali =
        DateTime.tryParse(tanggalKembaliStr) ?? DateTime.now();
    DateTime now = DateTime.now();
    Duration difference = tanggalKembali.difference(now);

    if (difference.inDays == 0) return 'Hari Ini';
    if (difference.inDays == 1) return 'Besok';
    if (difference.inDays < 0) return 'Terlambat';
    return 'Normal';
  }

  void _filterPengembalian() {
    setState(() {
      filteredPengembalianList =
          pengembalianList.where((pengembalian) {
            final kode =
                pengembalian['kode_pengembalian']?.toString().toLowerCase() ??
                '';
            final status = getStatusPengembalian(pengembalian);
            final cocokCari = kode.contains(searchQuery.toLowerCase());
            final cocokStatus =
                selectedStatus == 'Semua' || status == selectedStatus;
            return cocokCari && cocokStatus;
          }).toList();
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notifikasi Pengembalian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              notifications.isEmpty
                  ? const Text('Tidak ada notifikasi.')
                  : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder:
                          (context, index) => ListTile(
                            leading: const Icon(
                              Icons.notifications,
                              color: Colors.blue,
                            ),
                            title: Text(notifications[index]),
                          ),
                    ),
                  ),
            ],
          ),
        );
      },
    );

    setState(() => notificationCount = 0);
  }

  void lihatDetailPengembalian(Map<String, dynamic> pengembalian) {
    final List details = pengembalian['details'] ?? [];
    final kondisi = details.isNotEmpty ? details[0]['kondisi_buku'] : '-';
    final jumlah = details.isNotEmpty ? details[0]['jumlah_buku'] : '-';
    final status = getStatusPengembalian(pengembalian);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Detail Pengembalian'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kode: ${pengembalian['kode_pengembalian'] ?? '-'}"),
                const SizedBox(height: 8),
                Text(
                  "Tanggal Kembali: ${pengembalian['tanggal_kembali'] ?? '-'}",
                ),
                const SizedBox(height: 8),
                Text("Kondisi Buku: $kondisi"),
                const SizedBox(height: 8),
                Text("Jumlah Buku: $jumlah"),
                const SizedBox(height: 8),
                Text("Status: $status"),
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

  void kembalikanBuku(Map<String, dynamic> pengembalian) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi Pengembalian'),
            content: Text(
              'Yakin ingin mengembalikan buku dengan kode ${pengembalian['kode_pengembalian']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showMessage('Buku berhasil dikembalikan.');
                },
                child: const Text('Kembalikan'),
              ),
            ],
          ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Terlambat':
        return Colors.red;
      case 'Hari Ini':
        return Colors.orange;
      case 'Besok':
        return Colors.yellow.shade700;
      default:
        return Colors.green;
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _showNotifications,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Cari kode pengembalian...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        _filterPengembalian();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        _filterPengembalian();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Filter Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child:
                        filteredPengembalianList.isEmpty
                            ? const Center(
                              child: Text("Tidak ada data pengembalian."),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredPengembalianList.length,
                              itemBuilder: (context, index) {
                                final item = filteredPengembalianList[index];
                                final status = getStatusPengembalian(item);
                                final color = getStatusColor(status);
                                return GestureDetector(
                                  onTap: () => kembalikanBuku(item),
                                  onLongPress:
                                      () => lihatDetailPengembalian(item),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.assignment_return,
                                        color: color,
                                      ),
                                      title: Text(
                                        "Kode: ${item['kode_pengembalian']}",
                                      ),
                                      subtitle: Text(
                                        "Tanggal Kembali: ${item['tanggal_kembali']}",
                                      ),
                                      trailing: Text(
                                        status,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
