class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String address; // تمت إضافة العنوان
  final String role;

  UserModel({required this.uid, required this.name, required this.phone, required this.address, required this.role});

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'phone': phone, 'address': address, 'role': role};

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '', name: map['name'] ?? '', phone: map['phone'] ?? '', 
      address: map['address'] ?? '', role: map['role'] ?? 'customer',
    );
  }
}
