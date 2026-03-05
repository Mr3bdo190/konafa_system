import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _nameCtrl.text = doc['name'] ?? '';
        _phoneCtrl.text = doc['phone'] ?? '';
        _addressCtrl.text = doc['address'] ?? '';
      });
    }
  }

  void _saveData() async {
    setState(() => _isLoading = true);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'address': _addressCtrl.text,
    }, SetOptions(merge: true));
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ بياناتك بنجاح!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('حسابي'), backgroundColor: Colors.deepPurple, centerTitle: true, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(radius: 50, backgroundColor: Colors.deepPurple, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 20),
              _buildTextField('الاسم بالكامل', Icons.person, _nameCtrl),
              const SizedBox(height: 15),
              _buildTextField('رقم الهاتف', Icons.phone, _phoneCtrl, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField('العنوان التفصيلي', Icons.location_on, _addressCtrl, maxLines: 3),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('حفظ البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        shadowColor: Colors.grey.withOpacity(0.1), elevation: 2,
      ),
    );
  }
}
