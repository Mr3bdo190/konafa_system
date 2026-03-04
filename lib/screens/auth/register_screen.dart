import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // حقل العنوان الجديد
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برجاء ملء جميع البيانات'))); return;
    }
    setState(() => _isLoading = true);
    final user = await _authService.registerUser(
      _emailController.text.trim(), _passwordController.text.trim(),
      _nameController.text.trim(), _phoneController.text.trim(), _addressController.text.trim(), // تمرير العنوان
    );
    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: -80, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade300.withOpacity(0.4)))),
            Positioned(bottom: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade200.withOpacity(0.5)))),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.deepPurple), onPressed: () => Navigator.pop(context)),
                                const Expanded(child: Text('إنشاء حساب', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(_nameController, 'الاسم بالكامل', Icons.person),
                            const SizedBox(height: 10),
                            _buildTextField(_phoneController, 'رقم الهاتف', Icons.phone, isNumber: true),
                            const SizedBox(height: 10),
                            _buildTextField(_addressController, 'العنوان بالتفصيل', Icons.location_on), // حقل العنوان
                            const SizedBox(height: 10),
                            _buildTextField(_emailController, 'البريد الإلكتروني', Icons.email),
                            const SizedBox(height: 10),
                            _buildTextField(_passwordController, 'كلمة المرور', Icons.lock, isPassword: true),
                            const SizedBox(height: 20),
                            _isLoading ? const CircularProgressIndicator(color: Colors.deepPurple) : ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 55)),
                                    child: const Text('إنشاء الحساب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller, obscureText: isPassword, keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.deepPurple.shade300), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }
}
