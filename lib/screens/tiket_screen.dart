import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Untuk MediaType
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/wahana_model.dart';
import '../models/detail_pemesanan_tiket_model.dart';
import '../models/pemesanan_tiket_model.dart';
import '../services/api_service.dart';
import 'riwayat_pemesanan_tiket_screen.dart';

class TiketkuScreen extends StatefulWidget {
  const TiketkuScreen({super.key});

  @override
  State<TiketkuScreen> createState() => _TiketkuScreenState();
}

class _TiketkuScreenState extends State<TiketkuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tanggalPemesananController =
      TextEditingController();
  final TextEditingController totalTiketController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  final TextEditingController tanggalKunjunganController =
      TextEditingController();

  File? _buktiPembayaranFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController buktiPembayaranController =
      TextEditingController();

  int? idCustomer;
  String namaCustomer = '';
  DateTime? selectedDate;
  File? selectedImage;

  List<Wahana> wahanaList = [];

  List<Map<String, dynamic>> pesananList = [
    {'selectedWahana': null, 'jumlahTiket': TextEditingController()},
  ];

  @override
  void initState() {
    super.initState();

    fetchUser();
    fetchWahanaList();

    tanggalPemesananController.text = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.now());

    statusController.text = 'selesai';

    // namaCustomerController.text = namaCustomer;
  }

  Future<void> _pickBuktiPembayaran() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _buktiPembayaranFile = File(pickedFile.path);
                      buktiPembayaranController.text = pickedFile.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _buktiPembayaranFile = File(pickedFile.path);
                      buktiPembayaranController.text = pickedFile.name;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        idCustomer = user['id']; // Ambil ID
        namaCustomer = user['name'] ?? '-'; // Ambil Nama
      });
    }
  }

  Future<void> fetchWahanaList() async {
    try {
      final data = await ApiService().getWahana();
      setState(() {
        wahanaList = data;
      });
    } catch (e) {
      print('Gagal ambil wahana: $e');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void tambahBaris() {
    setState(() {
      pesananList.add({
        'selectedWahana': null,
        'jumlahTiket': TextEditingController(),
      });
    });
  }

  void hapusBaris(int index) {
    if (pesananList.length > 1) {
      setState(() {
        pesananList.removeAt(index);
      });
    }
  }

  int hitungTotalTiket() {
    int total = 0;
    for (var item in pesananList) {
      final jumlah = int.tryParse(item['jumlahTiket'].text) ?? 0;
      total += jumlah;
    }
    return total;
  }

  double hitungTotalHarga() {
    double total = 0;
    for (var item in pesananList) {
      final Wahana? w = item['selectedWahana'];
      final TextEditingController ctrl = item['jumlahTiket'];
      if (w != null && ctrl.text.isNotEmpty) {
        final jumlah = int.tryParse(ctrl.text) ?? 0;
        total += w.hargaTiket * jumlah;
      }
    }
    return total;
  }

  void submitTiket() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      if (idCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Customer tidak ditemukan')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan, silakan login ulang'),
          ),
        );
        return;
      }

      final tanggal = DateFormat('yyyy-MM-dd').format(selectedDate!);
      double totalHarga = 0;
      int totalTiket = 0;

      final List<Map<String, dynamic>> pesanan =
          pesananList
              .map((item) {
                final wahana = item['selectedWahana'];
                if (wahana == null) return null;

                final jumlah = int.tryParse(item['jumlahTiket'].text) ?? 0;
                final harga = wahana.hargaTiket ?? 0.0;
                final subtotal = harga * jumlah;
                totalHarga += subtotal;
                totalTiket += jumlah;

                return {
                  'wahana_id': wahana.id.toString(),
                  'jumlah': jumlah.toString(),
                  'harga': harga.toString(),
                  'subtotal': subtotal.toString(),
                };
              })
              .where((item) => item != null)
              .cast<Map<String, dynamic>>()
              .toList();

      final uri = Uri.parse('http://192.168.43.144:8000/api/pemesanan');
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['customer_id'] = idCustomer.toString()
            ..fields['tanggal_kunjungan'] = tanggal
            ..fields['total_tiket'] = totalTiket.toString()
            ..fields['total_harga'] = totalHarga.toString()
            ..fields['status'] = statusController.text;

      // Tambahkan data detail_wahana
      for (int i = 0; i < pesanan.length; i++) {
        final item = pesanan[i];
        request.fields['wahana_id[$i]'] = item['wahana_id'];
        request.fields['jumlah[$i]'] = item['jumlah'];
        request.fields['harga[$i]'] = item['harga'];
        request.fields['subtotal[$i]'] = item['subtotal'];
      }

      // Upload bukti pembayaran jika ada
      if (_buktiPembayaranFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti_pembayaran',
            _buktiPembayaranFile!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      try {
        final responseStream = await request.send();
        final response = await http.Response.fromStream(responseStream);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tiket berhasil dipesan!')),
            );

            // Reset Form
            setState(() {
              pesananList = [
                {
                  'selectedWahana': null,
                  'jumlahTiket': TextEditingController(),
                },
              ];
              selectedDate = null;
              _buktiPembayaranFile = null;
              buktiPembayaranController.clear();
            });

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatPemesananTiketScreen(),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${data['message']}')),
            );
          }
        } else {
          print('Error Status: ${response.statusCode}');
          print('Response Body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        print('Submit Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error saat submit: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua isian')),
      );
    }
  }

  // @override
  // void dispose() {
  //   buktiPembayaranController.dispose();
  //   super.dispose();
  // }

  InputDecoration customInputDecoration(
    String label,
    IconData icon, {
    bool isMoney = false,
    Color color = Colors.grey,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon:
          isMoney
              ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 25),
                    const SizedBox(width: 4),
                    const Text(
                      'Rp',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
              : Icon(icon, color: color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHarga = hitungTotalHarga();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('Pesan Tiket Wahana'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body:
          wahanaList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Customer
                      TextFormField(
                        readOnly: true,
                        // controller: namaCustomerController,
                        controller: TextEditingController(text: namaCustomer),
                        decoration: InputDecoration(
                          labelText: 'Nama Customer',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tanggal Pemesanan
                      TextFormField(
                        controller: tanggalPemesananController,
                        readOnly: true,
                        decoration: customInputDecoration(
                          'Tanggal Pemesanan',
                          Icons.date_range,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List Pesanan
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pesananList.length,
                        itemBuilder: (context, index) {
                          final item = pesananList[index];
                          return Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 24),
                            // lebih longgar jaraknya
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEAF2FF,
                              ), // biru lembut, bukan putih
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Dropdown Wahana
                                DropdownButtonFormField<Wahana>(
                                  decoration: customInputDecoration(
                                    'Pilih Wahana',
                                    Icons.location_on,
                                  ),
                                  value: item['selectedWahana'],
                                  items:
                                      wahanaList.map((w) {
                                        return DropdownMenuItem<Wahana>(
                                          value: w,
                                          child: Text(w.namaWahana),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      item['selectedWahana'] = val;
                                    });
                                  },
                                  validator:
                                      (val) =>
                                          val == null
                                              ? 'Pilih wahana dulu'
                                              : null,
                                ),
                                const SizedBox(height: 12),

                                // Harga Tiket
                                TextFormField(
                                  enabled: false,
                                  controller: TextEditingController(
                                    text:
                                        item['selectedWahana'] != null
                                            ? item['selectedWahana'].hargaTiket
                                                .toStringAsFixed(0)
                                            : '',
                                  ),
                                  decoration: customInputDecoration(
                                    'Harga Tiket',
                                    Icons.monetization_on,
                                    isMoney: true,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Jumlah Tiket
                                TextFormField(
                                  controller: item['jumlahTiket'],
                                  keyboardType: TextInputType.number,
                                  decoration: customInputDecoration(
                                    'Jumlah Tiket',
                                    Icons.confirmation_number,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Wajib diisi';
                                    }
                                    if (int.tryParse(val) == null) {
                                      return 'Harus berupa angka';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Subtotal
                                TextFormField(
                                  enabled: false,
                                  controller: TextEditingController(
                                    text:
                                        (item['selectedWahana'] != null &&
                                                int.tryParse(
                                                      item['jumlahTiket'].text,
                                                    ) !=
                                                    null)
                                            ? (item['selectedWahana']
                                                        .hargaTiket *
                                                    int.parse(
                                                      item['jumlahTiket'].text,
                                                    ))
                                                .toStringAsFixed(0)
                                            : '',
                                  ),
                                  decoration: customInputDecoration(
                                    'Subtotal',
                                    Icons.calculate,
                                    isMoney: true,
                                  ),
                                ),

                                // Tombol Hapus
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => hapusBaris(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Tombol Tambah Wahana
                      Align(
                        alignment: Alignment.center,
                        child: OutlinedButton.icon(
                          onPressed: tambahBaris,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Tambah Wahana'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tanggal Kunjungan
                      TextFormField(
                        controller: tanggalKunjunganController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Kunjungan',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.date_range,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                  tanggalKunjunganController.text = DateFormat(
                                    'dd MMM yyyy',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),

                      // Total Tiket
                      TextFormField(
                        controller: TextEditingController(
                          text: hitungTotalTiket().toString(),
                        ),
                        readOnly: true,
                        decoration: customInputDecoration(
                          'Total Tiket',
                          Icons.format_list_numbered,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total Harga
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: totalHarga.toStringAsFixed(0),
                          ),
                          decoration: customInputDecoration(
                            'Total Harga',
                            Icons.attach_money,
                            color: Colors.lightBlue,
                            isMoney: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Status Pemesanan
                      Visibility(
                        visible: false,
                        maintainState: true,
                        child: TextFormField(
                          controller: statusController,
                          readOnly: true,
                          decoration: customInputDecoration(
                            'Status Pemesanan',
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _pickBuktiPembayaran,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.lightBlue[100],
                                  backgroundImage:
                                      _buktiPembayaranFile != null
                                          ? FileImage(_buktiPembayaranFile!)
                                          : null,
                                  child:
                                      _buktiPembayaranFile == null
                                          ? const Icon(
                                            Icons.receipt_long,
                                            size: 60,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[200],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _buktiPembayaranFile != null
                                      ? 'Bukti pembayaran terpilih'
                                      : 'Klik untuk unggah bukti pembayaran',
                                  style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.qr_code_2,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Barcode Pembayaran',
                                              ),
                                              content: Image.asset(
                                                'assets/images/barcode_dana.jpg', // ← pastikan file ada di folder assets/images
                                                width: 300,
                                                height: 300,
                                                fit: BoxFit.contain,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                  child: const Text('Tutup'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submitTiket,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Pesan Tiket Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
