class AuthUser {
  final String id;
  final String role;
  final String name;
  final String email;
  final String phone;
  final String token;
  final String? address;
  final List<String>? neighborhoods;
  final List<String>? services;
  final double? averageRating;
  final String? status;

  const AuthUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
    this.address,
    this.neighborhoods,
    this.services,
    this.averageRating,
    this.status,
  });

  bool get isOwner => role == 'owner';
  bool get isCaregiver => role == 'caregiver';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json, String role, String token) {
    return AuthUser(
      id: json['id'] as String,
      role: role,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      token: token,
      address: json['address'] as String?,
      neighborhoods: json['neighborhoods'] != null
          ? List<String>.from(json['neighborhoods'] as List)
          : null,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : null,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'email': email,
        'phone': phone,
        'token': token,
        'address': address,
        'neighborhoods': neighborhoods,
        'services': services,
        'averageRating': averageRating,
        'status': status,
      };
}
