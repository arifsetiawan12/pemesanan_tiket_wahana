import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      image: 'assets/images/4.jpg',
      title: 'Lawang Park',
      subtitle: 'Wisata Alam & Wahana Keluarga',
      desc: 'Nikmati keindahan alam dan serunya wahana di Lawang Park, destinasi wisata terbaik di Sumatera Barat.',
    ),
    _OnboardData(
      image: 'assets/images/5.jpg',
      title: 'Pesan Tiket Mudah',
      subtitle: 'Semua dalam genggaman',
      desc: 'Pesan tiket wahana favoritmu dengan cepat, mudah, dan tanpa antre.',
    ),
    _OnboardData(
      image: 'assets/images/7.jpg',
      title: 'Pembayaran Praktis',
      subtitle: 'Aman & Fleksibel',
      desc: 'Bayar tiket kapan saja, di mana saja, dengan berbagai metode pembayaran.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                final data = _pages[i];
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradasi gelap bawah
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              Colors.black87,
                            ],
                            stops: [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Konten teks
                    AnimatedSlide(
                      offset: _currentPage == i ? Offset.zero : const Offset(0.2, 0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Hero(
                            tag: 'logo',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.subtitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              data.desc,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.blueAccent : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                )),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _nextPage,
                      child: Text(_currentPage == _pages.length - 1 ? 'Mulai' : 'Selanjutnya', style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  if (_currentPage == _pages.length - 1)
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Login/Daftar',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontFamily: 'Poppins', // font modern dan mudah dibaca
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Lewati', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String subtitle;
  final String desc;
  _OnboardData({required this.image, required this.title, required this.subtitle, required this.desc});
} 