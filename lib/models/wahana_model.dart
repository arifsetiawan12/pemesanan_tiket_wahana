/// wahana_model.dart
/// Model data Wahana untuk aplikasi Flutter.
/// Mencerminkan field pada tabel 'wahanas' di database Laravel.

class Wahana {
  final int id;
  final String? kodeWahana; // kode_wahana
  final String? namaWahana; // nama_wahana
  final String? deskripsi; // deskripsi
  final double? hargaTiket; // harga_tiket
  final String? foto; // foto
  final String createdAt;
  final String updatedAt;

  Wahana({
    required this.id,
    this.kodeWahana,
    this.namaWahana,
    this.deskripsi,
    this.hargaTiket,
    this.foto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wahana.fromJson(Map<String, dynamic> json) {
    return Wahana(
      id: json['id'] ?? 0,
      kodeWahana: json['kode_wahana'] ?? '',
      namaWahana: json['nama_wahana'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      hargaTiket:
          json['harga_tiket'] != null
              ? double.tryParse(json['harga_tiket'].toString())
              : null,
      foto: json['foto'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_wahana': kodeWahana,
      'nama_wahana': namaWahana,
      'deskripsi': deskripsi,
      'harga_tiket': hargaTiket,
      'foto': foto,
    };
  }
}
