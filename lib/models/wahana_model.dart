class Wahana {
  final int id;
  final String kodeWahana;
  final String namaWahana;
  final String deskripsi;
  final double hargaTiket; // ubah dari int ke double
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
      id: int.tryParse(json['id'].toString()) ?? 0,
      kodeWahana: json['kode_wahana'] ?? '',
      namaWahana: json['nama_wahana'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      hargaTiket: double.tryParse(json['harga_tiket'].toString()) ?? 0.0,
      foto: json['foto'] ?? '',
    );
  }
}
