import 'detail_pemesanan_tiket_model.dart';

class PemesananTiket {
  final int id;
  final int? userId;
  final String kodePemesanan;
  final String tanggalPemesanan;
  final String tanggalKunjungan;
  final int totalTiket;
  final double totalHarga;
  final String status;
  final String? buktiPembayaran;
  final List<DetailPemesananTiket> detailPemesanan;

  PemesananTiket({
    required this.id,
    this.userId,
    required this.kodePemesanan,
    required this.tanggalPemesanan,
    required this.tanggalKunjungan,
    required this.totalTiket,
    required this.totalHarga,
    required this.status,
    this.buktiPembayaran,
    required this.detailPemesanan,
  });

  factory PemesananTiket.fromJson(Map<String, dynamic> json) {
    return PemesananTiket(
      id: json['id'],
      userId: json['user_id'],
      kodePemesanan: json['kode_pemesanan'],
      tanggalPemesanan: json['tanggal_pemesanan'],
      tanggalKunjungan: json['tanggal_kunjungan'],
      totalTiket: json['total_tiket'],
      totalHarga: double.parse(json['total_harga'].toString()),
      status: json['status'],
      buktiPembayaran: json['bukti_pembayaran'],
      detailPemesanan:
          (json['detail_pemesanan'] as List<dynamic>)
              .map((e) => DetailPemesananTiket.fromJson(e))
              .toList(),
    );
  }
}
