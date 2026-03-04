import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customer/customer_home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;

  void _saveData() async {
    if (_phoneCtrl.text.isEmpty || _addressCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? 'عميل جديد',
      'email': user.email,
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'role': 'customer',
      'total_orders': 0,
      'total_spent': 0,
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إكمال بيانات الحساب')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('أهلاً بك! نحتاج لبعض التفاصيل لتوصيل طلباتك', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل')),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _saveData, child: const Text('حفظ والدخول للمنيو')),
          ],
        ),
      ),
    );
  }
}
