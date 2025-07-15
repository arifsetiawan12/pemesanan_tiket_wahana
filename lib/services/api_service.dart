import 'dart:convert';
import 'dart:io'; // Wajib untuk menangani SocketException
import 'dart:async'; // Wajib untuk menangani TimeoutException
import 'package:http/http.dart' as http;
import '../models/wahana_model.dart';
import '../models/customer_model.dart';

class ApiService {
  static const String baseUrl =
      "http://172.20.10.2:8000/api_laravel_backend/public/api";

  /// Ambil semua data wahana
  Future<List<Wahana>> getWahana() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wahana'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Wahana.fromJson(data)).toList();
      } else {
        print('Error getWahana:  [31m${response.statusCode} - ${response.body} [0m');
        throw Exception('Gagal memuat data wahana');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Permintaan waktu habis');
    } catch (e) {
      print('Exception getWahana: $e');
      rethrow;
    }
  }

  /// Register customer baru
  Future<bool> registerCustomer(Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error registerCustomer:  [31m${response.statusCode} - ${response.body} [0m');
        return false;
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Permintaan waktu habis');
    } catch (e) {
      print('Exception registerCustomer: $e');
      return false;
    }
  }
}
