import 'package:flutter/material.dart';
import 'package:librarp_digital/pages/Pengembalian.dart';
import 'package:librarp_digital/pages/HomePage.dart';
import 'package:librarp_digital/pages/buku.dart';
import 'package:librarp_digital/pages/ProfilePage.dart';
import 'package:librarp_digital/pages/Pinjaman.dart';

class DashboardPage extends StatefulWidget {
  final String namaAnggota;
  final String token;
  final String anggotaId;

  const DashboardPage({
    Key? key,
    required this.namaAnggota,
    required this.token,
    required this.anggotaId,
  }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(
        title: 'Beranda',
        namaAnggota: widget.namaAnggota,
        token: widget.token,
        anggotaId: widget.anggotaId,
      ),
      const BukuPage(title: 'Buku'),
      const PinjamanPage(title: 'Pinjaman', selectedBooks: []),
      const PengembalianPage(title: "Pengembalian"),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Buku'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Pinjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Pengembalian',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
