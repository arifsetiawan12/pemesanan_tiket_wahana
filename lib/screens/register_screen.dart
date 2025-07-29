import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nohpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nohpController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    setState(() => isLoading = true);

    final user = User(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      nohp:
          nohpController.text.trim().isEmpty
              ? null
              : nohpController.text.trim(),
      alamat:
          alamatController.text.trim().isEmpty
              ? null
              : alamatController.text.trim(),
      status: 'customer',
    );

    try {
      final result = await ApiService().registerUser(user);
      setState(() => isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        final String errorMsg = result['message'] ?? 'Registrasi gagal!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // TextField reusable yang sudah tidak menampilkan garis bawah (underline)
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required Icon icon,
    String? hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: icon,
            suffixIcon: suffixIcon,
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),

            // HILANGKAN GARIS BAWAH/OUTLINE
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // <- garis bawah dihilangkan
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Field Nama
              buildTextField(
                controller: nameController,
                label: 'Nama Lengkap',
                icon: const Icon(Icons.person, color: Colors.blue),
                hint: 'Nama lengkap Anda',
              ),

              // Field Email
              buildTextField(
                controller: emailController,
                label: 'Email',
                icon: const Icon(Icons.email, color: Colors.blue),
                hint: 'Email aktif',
                keyboardType: TextInputType.emailAddress,
              ),

              // Field Password
              buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: const Icon(Icons.lock, color: Colors.blue),
                hint: 'Masukkan password',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              // Field No HP
              buildTextField(
                controller: nohpController,
                label: 'Nomor HP',
                icon: const Icon(Icons.phone, color: Colors.blue),
                hint: 'Opsional',
                keyboardType: TextInputType.phone,
              ),

              // Field Alamat
              buildTextField(
                controller: alamatController,
                label: 'Alamat Lengkap',
                icon: const Icon(Icons.home, color: Colors.blue),
                hint: 'Opsional',
                maxLines: 2,
              ),

              const SizedBox(height: 8),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.app_registration, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Link Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
