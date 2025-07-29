// Tambahan pustaka penting
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/wahana_model.dart';
import 'customer_profile_page.dart'; // Ganti path sesuai lokasi
import 'tiket_screen.dart'; // Ganti path sesuai lokasi
import 'riwayat_pemesanan_tiket_screen.dart'; // Ganti path sesuai lokasi

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  String userName = '-';

  // Kontrol untuk pencarian wahana
  TextEditingController _searchController = TextEditingController();
  List<Wahana> _filteredWahana = [];
  List<Wahana> _allWahana = [];
  bool _isSearching = false;
  bool _isLoadingWahana = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchWahana(); // ambil data wahana
    _searchController.addListener(_onSearchChanged);
  }

  void fetchWahana() async {
    try {
      final data = await ApiService().getWahana();
      setState(() {
        _allWahana = data;
        _isLoadingWahana = false;
      });
    } catch (e) {
      print('Gagal ambil wahana: $e');
      setState(() {
        _isLoadingWahana = false;
      });
    }
  }

  // Fungsi pencarian wahana
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _isSearching = query.isNotEmpty;

      // Filter dari list wahana utama
      _filteredWahana =
          _allWahana.where((w) {
            return w.namaWahana.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _showDetailWahana(BuildContext context, Wahana wahana) {
    // Siapkan URL gambar
    final fotoUrl =
        wahana.foto.startsWith('http')
            ? wahana.foto
            : 'http://192.168.43.144:8000/storage/${wahana.foto}';

    // Tampilkan modal dari bawah (bottom sheet)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator drag
              Center(
                child: Container(
                  height: 5,
                  width: 60,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Gambar wahana
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fotoUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nama wahana
              Text(
                wahana.namaWahana,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Harga
              Text(
                'Harga : Rp ${wahana.hargaTiket.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(
                wahana.deskripsi ?? 'Tidak ada deskripsi.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Tombol Pesan Tiket
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 140, 192, 230),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.confirmation_number,
                    color: Colors.white, // Ubah warna icon jadi putih
                  ),

                  label: const Text(
                    'Pesan Tiket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TiketkuScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TiketkuScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RiwayatPemesananTiketScreen(),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // Ambil nama user dari shared preferences
  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        userName = user['name'] ?? '-';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Header background
          Container(
            height: 240,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/High Rope.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Konten utama scrollable
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hai, $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Temukan Keindahan\nLawPark',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Kartu pencarian dan daftar wahana
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mau Pesan Yang Mana ?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TextField untuk pencarian wahana
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Mau Pesan Tiket Wahana...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Text(
                            'Wisata Wahana',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          // FutureBuilder untuk tampilkan data dari API
                          SizedBox(
                            height: 220,
                            child: FutureBuilder<List<Wahana>>(
                              future: ApiService().getWahana(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('Tidak ada data wahana.'),
                                  );
                                }

                                // Simpan data asli hanya sekali saat pertama kali
                                if (_allWahana.isEmpty) {
                                  _allWahana = snapshot.data!;
                                }

                                // Gunakan hasil pencarian jika ada
                                final displayedWahana =
                                    _isSearching ? _filteredWahana : _allWahana;

                                if (displayedWahana.isEmpty) {
                                  return const Center(
                                    child: Text('Wahana tidak ditemukan.'),
                                  );
                                }

                                // List Wahana horizontal
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: displayedWahana.length,
                                  itemBuilder: (context, index) {
                                    final w = displayedWahana[index];

                                    // Cek apakah URL gambar sudah lengkap, jika tidak, tambahkan path storage Laravel
                                    final fotoUrl =
                                        w.foto.startsWith('http')
                                            ? w.foto
                                            : 'http://192.168.43.144:8000/storage/${w.foto}';

                                    // Ketika gambar diklik, tampilkan modal bottom sheet dengan detail wahana
                                    return GestureDetector(
                                      onTap:
                                          () => _showDetailWahana(context, w),
                                      child: _WisataCard(
                                        imageUrl: fotoUrl,
                                        name: w.namaWahana,
                                        isNetwork: true,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Wahana',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.map,
                                size: 20,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Area : Zona Petualangan',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Buka : 09.00 - 17.00',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
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

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tiketku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Pemesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Widget Kartu Wahana
class _WisataCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isNetwork;

  const _WisataCard({
    required this.imageUrl,
    required this.name,
    this.isNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isNetwork
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image));
                  },
                )
                : Image.asset(imageUrl, fit: BoxFit.cover),

            // Nama wahana
            Positioned(
              left: 8,
              bottom: 8,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
