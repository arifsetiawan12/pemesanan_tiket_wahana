import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pemesanan_tiket_model.dart';
import '../models/detail_pemesanan_tiket_model.dart';
import '../services/api_service.dart';
import 'faktur_pemesanan_tiket_screen.dart';

class RiwayatPemesananTiketScreen extends StatefulWidget {
  const RiwayatPemesananTiketScreen({super.key});

  @override
  State<RiwayatPemesananTiketScreen> createState() =>
      _RiwayatPemesananTiketScreenState();
}

class _RiwayatPemesananTiketScreenState
    extends State<RiwayatPemesananTiketScreen> {
  List<PemesananTiket> riwayat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final fetchedRiwayat = await ApiService().getRiwayatPemesanan(token);

      // Urutkan dari tanggal kunjungan paling lama ke paling baru
      // fetchedRiwayat.sort(
      //   (a, b) => DateTime.parse(
      //     a.tanggalKunjungan,
      //   ).compareTo(DateTime.parse(b.tanggalKunjungan)),
      // );

      setState(() {
        riwayat = fetchedRiwayat;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal ambil riwayat: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan Tiket'),
        backgroundColor: const Color.fromARGB(255, 140, 192, 230),
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : riwayat.isEmpty
              ? const Center(child: Text('Belum ada riwayat pemesanan.'))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: riwayat.length,
                itemBuilder: (context, index) {
                  final pemesanan = riwayat[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode Pemesanan : ${pemesanan.kodePemesanan}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tanggal Kunjungan : ${DateFormat('dd MMM yyyy').format(DateTime.parse(pemesanan.tanggalKunjungan))}',
                          ),
                          Text('Total Tiket : ${pemesanan.totalTiket}'),
                          Text(
                            'Total Harga : Rp ${pemesanan.totalHarga.toStringAsFixed(0)}',
                          ),
                          Text('Status: ${pemesanan.status}'),
                          const Divider(height: 20),
                          const Text(
                            'Wahana yang Dipesan :',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...pemesanan.detailPemesanan.map((detail) {
                                final wahana = detail.wahana;
                                return wahana == null
                                    ? const SizedBox()
                                    : ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            wahana.foto != null
                                                ? Image.network(
                                                  'http://192.168.43.144:8000/storage/${wahana.foto}',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                                : const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                      ),
                                      title: Text(wahana.namaWahana),
                                      subtitle: Text(
                                        'Jumlah : ${detail.jumlah} • Harga : Rp ${detail.harga.toStringAsFixed(0)}',
                                      ),
                                    );
                              }).toList(),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      140,
                                      192,
                                      230,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Cetak Faktur',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => FakturPemesananTiketScreen(
                                              pemesanan: pemesanan,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
