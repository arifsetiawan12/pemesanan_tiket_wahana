import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pemesanan_tiket_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FakturPemesananTiketScreen extends StatelessWidget {
  final PemesananTiket pemesanan;

  const FakturPemesananTiketScreen({super.key, required this.pemesanan});

  /// Fungsi untuk mencetak faktur ke PDF
  void _cetakFaktur(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FAKTUR PEMESANAN TIKET WAHANA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              _buildDetailItem("Kode Pemesanan", pemesanan.kodePemesanan),
              _buildDetailItem(
                "Tanggal Pemesanan",
                DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(pemesanan.tanggalPemesanan)),
              ),
              _buildDetailItem(
                "Tanggal Kunjungan",
                DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(pemesanan.tanggalKunjungan)),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Detail Tiket:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              // Menampilkan daftar wahana yang dipesan
              ...pemesanan.detailPemesanan.map((detail) {
                final wahana = detail.wahana;
                if (wahana == null) return pw.SizedBox();
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(" ${wahana.namaWahana}"),
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text("   Jumlah Tiket")),
                        pw.Text(": ${detail.jumlah}"),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text("   Harga per Tiket")),
                        pw.Text(": Rp ${detail.harga.toStringAsFixed(0)}"),
                      ],
                    ),
                    pw.Divider(),
                  ],
                );
              }),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "Total Tiket",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(": ${pemesanan.totalTiket}"),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "Total Harga",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(": Rp ${pemesanan.totalHarga.toStringAsFixed(0)}"),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Status Pembayaran:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(pemesanan.status),
            ],
          );
        },
      ),
    );

    // Cetak atau simpan PDF
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Widget utama tampilan faktur di layar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faktur Pemesanan Tiket"),
        backgroundColor: const Color.fromARGB(255, 140, 192, 230),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Center(
                  child: Text(
                    'FAKTUR PEMESANAN TIKET WAHANA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRow("Kode Pemesanan", pemesanan.kodePemesanan),
                _buildRow(
                  "Tanggal Pemesanan",
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(pemesanan.tanggalPemesanan)),
                ),
                _buildRow(
                  "Tanggal Kunjungan",
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(pemesanan.tanggalKunjungan)),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const Text(
                  "Detail Tiket:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...pemesanan.detailPemesanan.map((detail) {
                  final wahana = detail.wahana;
                  if (wahana == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ${wahana.namaWahana}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildRow("Jumlah Tiket", "${detail.jumlah}"),
                        _buildRow(
                          "Harga per Tiket",
                          "Rp ${detail.harga.toStringAsFixed(0)}",
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
                _buildRow("Total Tiket", "${pemesanan.totalTiket}"),
                _buildRow(
                  "Total Harga",
                  "Rp ${pemesanan.totalHarga.toStringAsFixed(0)}",
                ),
                const SizedBox(height: 16),
                const Text(
                  "Status Pembayaran:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(pemesanan.status),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text("Cetak / Simpan Faktur"),
                    onPressed: () => _cetakFaktur(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 140, 192, 230),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget bantu menampilkan info baris di layar
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text("$label")),
          Expanded(
            child: Text(
              ": $value",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget bantu menampilkan info di PDF
  pw.Widget _buildDetailItem(String label, String value) {
    return pw.Row(
      children: [pw.Expanded(child: pw.Text(label)), pw.Text(": $value")],
    );
  }
}
