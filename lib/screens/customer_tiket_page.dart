import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerTiketPage extends StatefulWidget {
  const CustomerTiketPage({super.key});

  @override
  State<CustomerTiketPage> createState() => _CustomerTiketPageState();
}

class _CustomerTiketPageState extends State<CustomerTiketPage> {
  List<TiketModel> tiketList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTiket();
  }

  Future<void> fetchTiket() async {
    final url = Uri.parse('http://172.20.10.2/tiket-customer');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          tiketList = data.map((json) => TiketModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiketku'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tiketList.isEmpty
              ? const Center(child: Text('Belum ada tiket.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tiketList.length,
                  itemBuilder: (context, index) {
                    final tiket = tiketList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.confirmation_num, color: Colors.blue),
                        title: Text(tiket.namaWahana),
                        subtitle: Text(
                            'Tanggal: ${tiket.tanggal}\nJumlah: ${tiket.jumlah}\nStatus: ${tiket.status}'),
                      ),
                    );
                  },
                ),
    );
  }
}

class TiketModel {
  final String namaWahana;
  final String tanggal;
  final int jumlah;
  final String status;

  TiketModel({
    required this.namaWahana,
    required this.tanggal,
    required this.jumlah,
    required this.status,
  });

  factory TiketModel.fromJson(Map<String, dynamic> json) {
    return TiketModel(
      namaWahana: json['nama_wahana'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.tryParse(json['jumlah'].toString()) ?? 0,
      status: json['status'] ?? 'Tidak diketahui',
    );
  }
}
