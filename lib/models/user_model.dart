class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? nohp;
  final String? alamat;
  final String status;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.nohp,
    this.alamat,
    this.status = 'customer',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'nohp': nohp,
      'alamat': alamat,
      'status': status,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // ditambahkan
      name: json['name'],
      email: json['email'],
      password: json['password'],
      nohp: json['nohp'],
      alamat: json['alamat'],
      status: json['status'] ?? 'customer',
    );
  }
}
