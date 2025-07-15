/// customer_model.dart
/// Model data Customer untuk aplikasi Flutter.

class Customer {
  final String namacustomer;
  final String username;
  final String password;
  final String email;
  final String? nohp;
  final String? alamat;

  Customer({
    required this.namacustomer,
    required this.username,
    required this.password,
    required this.email,
    this.nohp,
    this.alamat,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      namacustomer: json['namacustomer'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      nohp: json['nohp'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namacustomer': namacustomer,
      'username': username,
      'password': password,
      'email': email,
      'nohp': nohp,
      'alamat': alamat,
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
} 