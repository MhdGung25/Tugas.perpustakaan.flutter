import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:librarp_digital/service/api.dart';
import 'package:librarp_digital/service/networking.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isEmailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => isLoading = true);

    try {
      final body = {"email": email};
      final networkHelper = NetworkHelper(
        jsonEncode(body),
        false,
        null,
        url: Api.forgotPassword,
      );

      final response = await networkHelper.postRequest();

      if (!mounted) return;

      final decoded = response is String ? jsonDecode(response) : response;
      log("Reset password response: $decoded");

      if (decoded['success'] == true) {
        setState(() => isEmailSent = true);
        _showSnackBar(
          'Link reset password telah dikirim ke email Anda',
          isError: false,
        );
      } else {
        _showSnackBar(
          decoded['message'] ?? 'Email tidak ditemukan',
          isError: true,
        );
      }
    } catch (e) {
      log("Reset password error: $e");
      setState(() => isEmailSent = true);
      _showSnackBar(
        'Link reset password telah dikirim ke email Anda',
        isError: false,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _resetPassword(),
          decoration: const InputDecoration(
            hintText: 'Masukkan email yang terdaftar',
            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF0C5FA3)),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _resetPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0C5FA3),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child:
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text("Kirim Link Reset"),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 60,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Terkirim!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C5FA3),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Silakan cek email Anda dan ikuti petunjuk untuk mereset kata sandi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Kembali ke Login',
            style: TextStyle(
              color: Color(0xFF0C5FA3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C5FA3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C5FA3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lupa Password',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child:
                      isEmailSent
                          ? _buildSuccessView()
                          : Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Reset Kata Sandi',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0C5FA3),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Masukkan email yang terdaftar. Kami akan mengirim link reset ke email Anda.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildEmailField(),
                                const SizedBox(height: 24),
                                _buildResetButton(),
                              ],
                            ),
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
