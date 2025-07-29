import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/wahana_model.dart';
import '../models/user_model.dart';
import '../models/pemesanan_tiket_model.dart';
import '../models/detail_pemesanan_tiket_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // ⬅️ untuk MediaType
import 'package:mime/mime.dart'; // ⬅️ untuk lookupMimeType
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.43.144/api_laravel_backend/public/api';

  /// Fungsi login dengan header Accept: application/json agar tidak error FormatException
  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json', // Sesuai dengan jsonEncode
            },
            body: jsonEncode({'name': name, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Simpan token dan user ke SharedPreferences jika perlu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));

        return {
          'success': true,
          'data': data,
          'status': data['user']['status'], // Ambil status user
        };
      } else {
        // Jika error, coba decode JSON, jika gagal tampilkan body mentah
        try {
          final decoded = json.decode(response.body);
          return {
            'success': false,
            'message': decoded['message'] ?? response.body,
          };
        } catch (_) {
          return {'success': false, 'message': response.body};
        }
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Waktu koneksi habis. Coba beberapa saat lagi.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi error tak terduga: $e'};
    }
  }

  /// REGISTRASI USER
  Future<Map<String, dynamic>> registerUser(User user) async {
    final url = Uri.parse('$baseUrl/user');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal registrasi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan. Coba lagi.'};
    }
  }

  Future<List<Wahana>> getWahana() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wahana'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Wahana.fromJson(data)).toList();
      } else {
        print('Error getWahana: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal memuat data wahana');
      }
    } catch (e) {
      print('Exception getWahana: $e');
      rethrow;
    }
  }

  // ✅ Method ambil profil user yang sedang login
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Gagal mendapatkan profil user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saat ambil profil user: $e');
      return null;
    }
  }

  Future<bool> pesanTiket({
    required int idWahana,
    required int jumlah,
    required String tanggal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/pemesanan'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {
        'wahana_id': idWahana.toString(),
        'jumlah_tiket': jumlah.toString(),
        'tanggal_kunjungan': tanggal,
      },
    );

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>> submitPemesananTiket({
    required int customerId,
    required String tanggalKunjungan,
    required int totalTiket,
    required double totalHarga,
    required String status,
    required List<Map<String, dynamic>> detailPesanan,
    required File? buktiPembayaranFile,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }

    if (detailPesanan.isEmpty) {
      return {'success': false, 'message': 'Minimal 1 wahana harus dipilih.'};
    }

    try {
      final uri = Uri.parse('http://192.168.43.144:8000/api/pemesanan');
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['customer_id'] = customerId.toString()
            ..fields['tanggal_kunjungan'] = tanggalKunjungan
            ..fields['total_tiket'] = totalTiket.toString()
            ..fields['total_harga'] = totalHarga.toStringAsFixed(2)
            ..fields['status'] = status;

      // Tambahkan detail pesanan
      for (int i = 0; i < detailPesanan.length; i++) {
        final item = detailPesanan[i];
        final wahanaId = item['wahana_id'];
        final jumlah = item['jumlah'];
        final harga = item['harga'];
        final subtotal = item['subtotal'];

        if (wahanaId != null &&
            jumlah != null &&
            harga != null &&
            subtotal != null) {
          request.fields['wahana_id[$i]'] = wahanaId.toString();
          request.fields['jumlah[$i]'] = jumlah.toString();
          request.fields['harga[$i]'] = harga.toString();
          request.fields['subtotal[$i]'] = subtotal.toString();
        }
      }

      // Tambahkan file bukti pembayaran jika ada
      if (buktiPembayaranFile != null) {
        final mimeType =
            lookupMimeType(buktiPembayaranFile.path) ?? 'image/jpeg';
        final typeSplit = mimeType.split('/');

        final file = await http.MultipartFile.fromPath(
          'bukti_pembayaran',
          buktiPembayaranFile.path,
          contentType: MediaType(typeSplit[0], typeSplit[1]),
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final statusCode = response.statusCode;
      final responseBody = response.body;

      if (statusCode == 200 || statusCode == 201) {
        final data = json.decode(responseBody);
        return data;
      } else {
        print('⚠️ Server Error [$statusCode]: $responseBody');
        return {
          'success': false,
          'message':
              'Server error [$statusCode]: ${response.reasonPhrase ?? 'Unknown error'}',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Exception occurred: $e'};
    }
  }

  Future<List<PemesananTiket>> getRiwayatPemesanan(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pemesanan'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> pemesananList = data['data'];
      return pemesananList.map((e) => PemesananTiket.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat pemesanan');
    }
  }
}
