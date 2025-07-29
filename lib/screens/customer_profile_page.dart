import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      setState(() {
        _user = jsonDecode(userString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightBlue = Color(0xFF60A5FA); // Warna biru muda

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: lightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF60A5FA), // lightBlue
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          _user!['name'] ?? '-',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _user!['email'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: lightBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildProfileItem(
                          icon: Icons.person,
                          title: 'Nama',
                          value: _user!['name'] ?? '-',
                        ),
                        _buildProfileItem(
                          icon: Icons.email,
                          title: 'Email',
                          value: _user!['email'] ?? '-',
                        ),
                        _buildProfileItem(
                          icon: Icons.phone, // 📱 Ikon telepon
                          title: 'No Hp',
                          value: _user!['nohp'] ?? '-',
                        ),
                        _buildProfileItem(
                          icon: Icons.home, // 🏠 Ikon rumah/alamat
                          title: 'Alamat',
                          value: _user!['alamat'] ?? '-',
                        ),
                        if (_user!['status'] != null)
                          _buildProfileItem(
                            icon: Icons.verified_user,
                            title: 'Status',
                            value: _user!['status'],
                          ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear(); // Logout
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightBlue,
                            textStyle: const TextStyle(fontSize: 16),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[400]),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
