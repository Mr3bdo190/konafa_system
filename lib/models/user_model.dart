class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final double totalSpent;
  final int totalOrders;

  UserModel({
    required this.uid,
    required this.name,
    this.email = '',
    required this.phone,
    required this.address,
    required this.role,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'total_spent': totalSpent,
      'total_orders': totalOrders,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? 'customer',
      totalSpent: (map['total_spent'] ?? 0).toDouble(),
      totalOrders: map['total_orders'] ?? 0,
    );
  }
}
