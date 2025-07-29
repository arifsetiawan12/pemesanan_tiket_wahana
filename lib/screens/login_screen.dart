import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'customer_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  // Controller untuk input nama dan password
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true;

  // Fungsi login HTTP POST ke API Laravel
  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.144/api_laravel_backend/public/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      print('Login response: $data');

      if (response.statusCode == 200) {
        final user = data['user'];
        final token = data['token'];

        // Simpan token dan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user));
        await prefs.setString('name', user['name'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('nohp', user['nohp'] ?? '');
        await prefs.setString('alamat', user['alamat'] ?? '');
        await prefs.setString('status', user['status'] ?? '');

        final status = user['status'];

        // Cek status user
        if (status == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CustomerHomePage()),
          );
        } else {
          setState(() {
            errorMessage = 'Status pengguna tidak dikenali: $status';
          });
        }
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Login gagal';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Membersihkan controller saat tidak dipakai
  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Login di atas
              // const Icon(
              //   Icons.login_rounded,
              //   size: 64,
              //   color: Colors.blueAccent,
              // ),

              // Logo aplikasi (opsional)
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/logo.jpg'),
              ),

              const SizedBox(height: 16),
              const Text(
                'Selamat Datang !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan login untuk melanjutkan',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // Form Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Lengkap/Pengguna'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        hintText: 'Masukkan nama',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Password',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checkbox & Lupa Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  rememberMe = val ?? false;
                                });
                              },
                            ),
                            const Text('Ingat Saya'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Lupa password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.login, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Menampilkan error jika ada
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
