import 'package:flutter/material.dart';
import '../models/wahana_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'wahana_add_screen.dart';
// import 'wahana_edit_screen.dart';

class WahanaDetailScreen extends StatelessWidget {
  final Wahana wahana;
  const WahanaDetailScreen({super.key, required this.wahana});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(wahana.namaWahana),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: wahana.foto.isNotEmpty
                  ? Hero(
                      tag: 'wahana_foto_${wahana.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'http://192.168.1.32:8000/storage/${wahana.foto}',
                          height: 180,
                        ),
                      ),
                    )
                  : const Icon(Icons.image, size: 120),
            ),
            const SizedBox(height: 16),
            Text('Nama: ${wahana.namaWahana}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kode: ${wahana.kodeWahana}'),
            const SizedBox(height: 8),
            Text('Harga Tiket: Rp ${wahana.hargaTiket.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${wahana.deskripsi}'),
          ],
        ),
      ),
    );
  }
}

class WahanaHomeScreen extends StatefulWidget {
  const WahanaHomeScreen({super.key});
  @override
  _WahanaHomeScreenState createState() => _WahanaHomeScreenState();
}

class _WahanaHomeScreenState extends State<WahanaHomeScreen> {
  late Future<List<Wahana>> futureWahana;

  @override
  void initState() {
    super.initState();
    futureWahana = ApiService().getWahana();
  }

  void refreshData() {
    setState(() {
      futureWahana = ApiService().getWahana();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Wahana'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: refreshData),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('customer');
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Wahana>>(
        future: futureWahana,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error:  ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data wahana."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final wahana = snapshot.data![index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + index * 80),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.95 + 0.05 * value,
                      child: child,
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  color: Colors.white,
                  shadowColor: Colors.blue.withOpacity(0.15),
                  child: ListTile(
                    leading: Hero(
                      tag: 'wahana_foto_${wahana.id}',
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: wahana.foto.isNotEmpty
                            ? NetworkImage('http://192.168.1.32:8000/storage/${wahana.foto}')
                            : const AssetImage('assets/default_image.png') as ImageProvider,
                      ),
                    ),
                    title: Text(
                      wahana.namaWahana,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Harga : Rp ${wahana.hargaTiket.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Deskripsi : ${wahana.deskripsi}',
                                style: TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => WahanaDetailScreen(wahana: wahana),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ));
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 20),
                  ),
                ),
              );
            },
          );
        },
      ),
      // ==================================
      // Tombol Tambah dimatikan:
      // ==================================
      /*
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WahanaAddScreen()),
          );
          refreshData();
        },
      ),
      */
    );
  }
}
