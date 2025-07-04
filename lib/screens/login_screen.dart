import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:librarp_digital/screens/register_screen.dart';
import 'package:librarp_digital/pages/dashboard.dart';
import 'package:librarp_digital/model/user_model.dart';
import 'package:librarp_digital/service/api.dart';
import 'package:librarp_digital/service/networking.dart';
import 'package:librarp_digital/screens/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _formController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _formController.forward();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password tidak boleh kosong');
      return;
    }

    setState(() => isLoading = true);

    final body = {"email": email, "password": password};
    final networkHelper = NetworkHelper(
      jsonEncode(body),
      false,
      null,
      url: Api.login,
    );

    try {
      final response = await networkHelper.postRequest();
      if (response == null) {
        _showSnackBar('Gagal terhubung ke server. Periksa koneksi jaringan.');
        return;
      }

      final decoded = response is String ? jsonDecode(response) : response;
      final data = UserModel.fromJson(decoded);

      if (data.accessToken != null && data.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", data.accessToken!);
        await prefs.setInt("id_user", data.user!.idUser ?? 0);
        await prefs.setString("email", data.user!.email ?? "");
        await prefs.setString("nama_lengkap", data.user!.namaLengkap ?? "");
        await prefs.setInt("level", data.user!.level ?? 0);

        if (decoded['anggota'] != null) {
          await prefs.setString(
            "anggota_id",
            decoded['anggota']['id'].toString(),
          );
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DashboardPage(
                  namaAnggota: data.user!.namaLengkap ?? '',
                  token: data.accessToken!,
                  anggotaId: data.user!.idUser.toString(),
                ),
          ),
        );
      } else {
        _showSnackBar("Login gagal: Token atau data user tidak ditemukan.");
      }
    } catch (e) {
      log("Login error: $e");
      _showSnackBar('Terjadi kesalahan saat login');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool obscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Masukkan ${label.toLowerCase()}',
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Masukkan password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed:
                  () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _login,
      child: const Text("Masuk"),
    );
  }

  Widget _buildBottomLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            );
          },
          child: const Text(
            "Lupa Password?",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Belum punya akun?"),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                'Daftar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C5FA3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: _formSlide,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/Logo.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LIBRARY DIGITAL',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C5FA3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField('Email', _emailController, false),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator()
                      : _buildLoginButton(),
                  const SizedBox(height: 10),
                  _buildBottomLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
