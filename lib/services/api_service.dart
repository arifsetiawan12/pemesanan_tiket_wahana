import 'dart:convert';
import 'dart:async'; // Wajib untuk menangani TimeoutException
import 'package:http/http.dart' as http;
import '../models/wahana_model.dart';
import '../models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://192.168.1.32:8000/api';

  // Registrasi Customer
  Future<Map<String, dynamic>> registerCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'namacustomer': customer.namacustomer,
        'username': customer.username,
        'email': customer.email,
        'password': customer.password,
        'nohp': customer.nohp,
        'alamat': customer.alamat,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? response.body};
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            body: {'username': username, 'password': password},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Simpan token dan customer
        await saveToken(data['token']);
        await saveCustomer(data['customer']);
        return {
          'success': true,
          'data': data,
        };
      } else {
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
            'Tidak dapat terhubung ke server. Cek koneksi internet atau server Anda.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi ke server timeout. Cek jaringan/server Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi error: $e'};
    }
  }

  // Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        await saveCustomer(data['customer']);
        return {
          'success': true,
          'data': data,
        };
      } else {
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
        'message': 'Tidak dapat terhubung ke server. Cek koneksi internet atau server Anda.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi ke server timeout. Cek jaringan/server Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi error: $e'};
    }
  }

  // Simpan data customer ke SharedPreferences
  Future<void> saveCustomer(Map<String, dynamic> customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer', jsonEncode(customer));
  }

  // Ambil data customer dari SharedPreferences
  Future<Map<String, dynamic>?> getCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('customer');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // CRUD Customer
  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customer'));
    final List data = jsonDecode(response.body);
    return data.map((json) => Customer.fromJson(json)).toList();
  }

  Future<Customer> getCustomerDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/customer/$id'));
    return Customer.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> updateCustomer(int id, Customer customer) async {
    final response = await http.put(
      Uri.parse('$baseUrl/customer/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'namacustomer': customer.namacustomer,
        'username': customer.username,
        'email': customer.email,
        'password': customer.password,
        'nohp': customer.nohp,
        'alamat': customer.alamat,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? response.body};
    }
  }

  Future<bool> deleteCustomer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/customer/$id'));
    return response.statusCode == 200;
  }

  // CRUD Wahana
  Future<List<Wahana>> getWahana() async {
    final response = await http.get(Uri.parse('$baseUrl/wahana'));
    final List data = jsonDecode(response.body);
    return data.map((json) => Wahana.fromJson(json)).toList();
  }

  Future<Wahana> getWahanaDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/wahana/$id'));
    return Wahana.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> addWahana(Map<String, dynamic> wahana, {File? foto}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/wahana'));
    wahana.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? response.body};
    }
  }

  Future<Map<String, dynamic>> updateWahana(int id, Map<String, dynamic> wahana, {File? foto}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/wahana/$id?_method=PUT'));
    wahana.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? response.body};
    }
  }

  Future<bool> deleteWahana(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/wahana/$id'));
    return response.statusCode == 200;
  }

  // Fungsi simpan token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Fungsi ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
