import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PengembalianPage extends StatefulWidget {
  final String title;
  const PengembalianPage({super.key, required this.title});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  int notificationCount = 0;
  bool isLoading = true;
  List<dynamic> pengembalianList = [];
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchPengembalian();
  }

  Future<void> fetchPengembalian() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      pengembalianList = [];
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8000/api/pengembalian'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        List<String> newNotifications = [];
        DateTime now = DateTime.now();

        for (var item in data) {
          String tanggalKembaliStr = item['tanggal_kembali'];
          DateTime tanggalKembali = DateTime.tryParse(tanggalKembaliStr) ?? now;
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

        if (mounted) {
          setState(() {
            pengembalianList = data;
            notifications.clear();
            notifications.addAll(newNotifications);
            notificationCount = newNotifications.length;
          });
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching pengembalian: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(notifications[index]),
            );
          },
        );
      },
    );

    setState(() {
      notificationCount = 0;
    });
  }

  Widget _buildPengembalianCard(Map<String, dynamic> data) {
    final List details = data['details'] ?? [];
    final kondisi =
        details.isNotEmpty ? details[0]['kondisi_buku'] : 'Belum ada data';
    final jumlah =
        details.isNotEmpty ? details[0]['jumlah_buku'].toString() : '-';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_return,
            size: 48,
            color: Color(0xFF4E73DF),
          ),
          const SizedBox(height: 10),
          Text(
            "Kode: ${data['kode_pengembalian']}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            "Tgl Kembali: ${data['tanggal_kembali']}",
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            "Kondisi: $kondisi\nJumlah: $jumlah buku",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: Tambahkan aksi pengembalian
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E73DF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Kembalikan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDEE6FF), Color(0xFFE3E6F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pengembalian Buku",
                style: TextStyle(color: Colors.black),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                    ),
                    onPressed: _showNotifications,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : pengembalianList.isEmpty
                ? const Center(child: Text("Tidak ada data pengembalian"))
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                    children:
                        pengembalianList.map<Widget>((data) {
                          return _buildPengembalianCard(data);
                        }).toList(),
                  ),
                ),
      ),
    );
  }
}
