import 'package:flutter/material.dart';
import 'package:librarp_digital/pages/buku.dart';
import 'package:librarp_digital/pages/Pinjaman.dart';
import 'package:librarp_digital/pages/Pengembalian.dart';
import 'package:librarp_digital/pages/ProfilePage.dart';

class Homepage extends StatelessWidget {
  final String namaAnggota;
  final String anggotaId;

  const Homepage({Key? key, required this.namaAnggota, required this.anggotaId})
    : super(key: key);

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light Blue
      appBar: AppBar(
        title: Text('Selamat Datang, $namaAnggota'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 64,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Halo, $namaAnggota!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID Anggota: $anggotaId',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuItem(
                  icon: Icons.book,
                  label: 'Buku',
                  onTap: () {
                    _navigateTo(
                      context,
                      BukuPage(title: 'Daftar Buku', namaAnggota: namaAnggota),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.shopping_cart,
                  label: 'Peminjaman',
                  onTap: () {
                    _navigateTo(
                      context,
                      PinjamanPage(
                        title: 'Peminjaman',
                        selectedBooks:
                            const [], // bisa diganti fetch data nanti
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.assignment_return,
                  label: 'Pengembalian',
                  onTap: () {
                    _navigateTo(
                      context,
                      PengembalianPage(title: 'Pengembalian'),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  label: 'Profil',
                  onTap: () {
                    _navigateTo(context, const ProfilePage());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.blueAccent.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
