import '../models/wahana_model.dart';

class DetailPemesananTiket {
  final int id;
  final int pemesananTiketId;
  final int wahanaId;
  final int jumlah;
  final double harga;
  final double subtotal;
  final Wahana? wahana;

  DetailPemesananTiket({
    required this.id,
    required this.pemesananTiketId,
    required this.wahanaId,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
    this.wahana,
  });

  factory DetailPemesananTiket.fromJson(Map<String, dynamic> json) {
    return DetailPemesananTiket(
      id: json['id'],
      pemesananTiketId: json['pemesanan_tiket_id'],
      wahanaId: json['wahana_id'],
      jumlah: json['jumlah'],
      harga: double.parse(json['harga'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      wahana: json['wahana'] != null ? Wahana.fromJson(json['wahana']) : null,
    );
  }
}
