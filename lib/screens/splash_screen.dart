import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import layar login, sesuaikan jika file Anda berbeda
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController(); // Mengatur halaman onboarding
  int _currentPage = 0; // Menyimpan indeks halaman yang sedang tampil

  // Data onboarding: gambar, judul, dan deskripsi
  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding1.jpeg',
      'title': 'Wisata Seru di Lawang',
      'description': 'Nikmati berbagai wahana seru di Lawang Adventure Park.',
    },
    {
      'image': 'assets/images/onboarding2.jpeg',
      'title': 'Pesan Tiket Lebih Mudah',
      'description': 'Tiket wahana bisa dipesan langsung dari aplikasi.',
    },
    {
      'image': 'assets/images/onboarding3.jpeg',
      'title': 'Bayar Tanpa Ribet',
      'description': 'Pembayaran bisa dilakukan kapan saja, di mana saja.',
    },
  ];

  // Fungsi untuk berpindah ke halaman selanjutnya
  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Menampilkan PageView (slide)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index; // Update halaman saat swipe
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return Container(
                // Menampilkan gambar background untuk setiap halaman
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(data['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  // Gradien gelap dari bawah agar teks lebih terlihat
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Judul onboarding
                      Text(
                        data['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Deskripsi onboarding
                      Text(
                        data['description']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Indikator halaman (lingkaran di bawah)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _currentPage == i
                                      ? Colors.white
                                      : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Tombol aksi
                      _currentPage == onboardingData.length - 1
                          ? Column(
                            children: [
                              // Tombol "Daftar Sekarang"
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Tombol "Login"
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // Arahkan ke halaman login
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                          : ElevatedButton(
                            // Tombol "Selanjutnya"
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _nextPage,
                            child: const Text(
                              'Selanjutnya',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
          // Tombol "Lewati" di pojok kanan atas (hilang di halaman terakhir)
          Positioned(
            top: 40,
            right: 20,
            child:
                _currentPage != onboardingData.length - 1
                    ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPage = onboardingData.length - 1;
                          _pageController.jumpToPage(
                            _currentPage,
                          ); // Loncat ke akhir
                        });
                      },
                      child: const Text(
                        'Lewati',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : const SizedBox(),
          ),
          // Logo atau nama aplikasi di pojok kiri atas
          const Positioned(
            top: 40,
            left: 20,
            child: Text(
              'LawPark',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
