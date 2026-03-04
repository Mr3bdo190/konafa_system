import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../customer/customer_home_screen.dart'; // استدعاء شاشة العميل

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final user = await _authService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مرحباً ${user.name}، تم الدخول بنجاح!')),
      );
      // الانتقال لشاشة العميل
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول، تأكد من البيانات')),
      );
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
            Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade200.withOpacity(0.5)))),
            Positioned(bottom: -100, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade300.withOpacity(0.4)))),
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
                            const Text('تسجيل الدخول', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            const SizedBox(height: 30),
                            _buildTextField(_emailController, 'البريد الإلكتروني', Icons.email),
                            const SizedBox(height: 15),
                            _buildTextField(_passwordController, 'كلمة المرور', Icons.lock, isPassword: true),
                            const SizedBox(height: 30),
                            _isLoading
                                ? const CircularProgressIndicator(color: Colors.deepPurple)
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 55)),
                                    child: const Text('دخول', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: Text('ليس لديك حساب؟ إنشاء حساب', style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 16)),
                            )
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller, obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: Colors.deepPurple.shade300), filled: true, fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
