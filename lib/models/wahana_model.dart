/// wahana_model.dart
/// Model data Wahana untuk aplikasi Flutter.
/// Mencerminkan field pada tabel 'wahanas' di database Laravel.

class Wahana {
  final int id;
  final String kodeWahana;
  final String namaWahana;
  final String deskripsi;
  final int hargaTiket;
  final String foto;

  Wahana({
    required this.id,
    required this.kodeWahana,
    required this.namaWahana,
    required this.deskripsi,
    required this.hargaTiket,
    required this.foto,
  });

  factory Wahana.fromJson(Map<String, dynamic> json) {
    return Wahana(
      id: json['id'],
      kodeWahana: json['kode_wahana'],
      namaWahana: json['nama_wahana'],
      deskripsi: json['deskripsi'],
      hargaTiket: json['harga_tiket'],
      foto: json['foto'],
    );
  }
}
