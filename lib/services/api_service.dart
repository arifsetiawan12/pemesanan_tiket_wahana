import 'dart:convert';
import 'dart:async'; // Wajib untuk menangani TimeoutException
import 'package:http/http.dart' as http;
import '../models/wahana_model.dart';
import '../models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://yourdomain.com/api';

  // Registrasi
  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return jsonDecode(response.body);
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Get User Profile
  Future<User> getUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return User.fromJson(jsonDecode(response.body));
  }

  // Get List Wahana
  Future<List<Wahana>> getWahana() async {
    final response = await http.get(Uri.parse('$baseUrl/wahana'));
    final List data = jsonDecode(response.body);
    return data.map((json) => Wahana.fromJson(json)).toList();
  }

  // Get Detail Wahana
  Future<Wahana> getWahanaDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/wahana/$id'));
    return Wahana.fromJson(jsonDecode(response.body));
  }

  // Tambahkan method registerCustomer
  Future<bool> registerCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': customer.namacustomer,
        'username': customer.username,
        'email': customer.email,
        'password': customer.password,
        'nohp': customer.nohp,
        'alamat': customer.alamat,
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
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
