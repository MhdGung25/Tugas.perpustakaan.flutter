import 'package:flutter/material.dart';
import 'package:librarp_digital/pages/ProfilePage.dart';
import 'package:librarp_digital/pages/buku.dart';
import 'package:librarp_digital/pages/pinjaman.dart';
import 'package:librarp_digital/pages/pengembalian.dart';

class Homepage extends StatefulWidget {
  final String namaAnggota;
  final String anggotaId;

  const Homepage({
    super.key,
    required this.namaAnggota,
    required this.anggotaId,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BukuPage(title: 'Daftar Buku', namaAnggota: widget.namaAnggota),
      PinjamanPage(title: 'Peminjaman', selectedBooks: const []),
      PengembalianPage(title: 'Pengembalian', namaAnggota: widget.namaAnggota),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Selamat Datang di Perpustakaan',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              widget.namaAnggota,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
