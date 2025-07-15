import 'package:flutter/material.dart';
import '../models/wahana_model.dart';
import '../services/api_service.dart';
// import 'wahana_add_screen.dart';
// import 'wahana_edit_screen.dart';

class WahanaHomeScreen extends StatefulWidget {
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
        ],
      ),
      body: FutureBuilder<List<Wahana>>(
        future: futureWahana,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data wahana."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final wahana = snapshot.data![index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: (wahana.foto != null && wahana.foto!.isNotEmpty)
                        ? NetworkImage('https://yourdomain.com/storage/${wahana.foto}')
                        : const AssetImage('assets/default_image.png') as ImageProvider,
                  ),
                  title: Text(
                    wahana.namaWahana ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      // Baris harga dengan ikon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.black, // ganti sesuai tema
                          ),
                          SizedBox(width: 8), // jarak antara ikon dan teks
                          Expanded(
                            child: Text(
                              'Harga : Rp ${wahana.hargaTiket?.toStringAsFixed(0) ?? "0"}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4), // jarak antar baris
                      // Baris deskripsi dengan ikon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Deskripsi : ${wahana.deskripsi ?? ""}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ====================
                      // Tombol Edit dimatikan:
                      // ====================
                      /*
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WahanaEditScreen(wahana: wahana),
                            ),
                          );
                          refreshData();
                        },
                      ),
                      */
                      // ====================
                      // Tombol Hapus dimatikan:
                      // ====================
                      /*
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: Text(
                                'Yakin ingin menghapus data ${wahana.namaWahana ?? "wahana ini"}?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text('Hapus'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await ApiService().deleteWahana(wahana.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data berhasil dihapus')),
                              );
                              refreshData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal menghapus data')),
                              );
                            }
                          }
                        },
                      ),
                      */
                    ],
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
