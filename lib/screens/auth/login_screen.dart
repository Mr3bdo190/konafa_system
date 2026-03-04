import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../customer/customer_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  void _handleGoogle() async {
    setState(() => _isGoogleLoading = true);
    String result = await _authService.signInWithGoogle();
    setState(() => _isGoogleLoading = false);

    if (result == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
    } else if (result == 'customer') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
    } else if (result == 'new_user') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CompleteProfileScreen()));
    } else if (result != 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $result')));
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
                            const Text('نظام كنافة - دخول', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            const SizedBox(height: 30),
                            _buildField(_emailController, 'البريد الإلكتروني', Icons.email),
                            const SizedBox(height: 15),
                            _buildField(_passwordController, 'كلمة المرور', Icons.lock, pass: true),
                            const SizedBox(height: 30),
                            _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                final user = await _authService.loginUser(_emailController.text.trim(), _passwordController.text.trim());
                                setState(() => _isLoading = false);
                                if (user != null) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => user.role == 'admin' ? const AdminHomeScreen() : const CustomerHomeScreen()));
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              child: const Text('دخول', style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                            const SizedBox(height: 15),
                            _isGoogleLoading ? const CircularProgressIndicator() : ElevatedButton.icon(
                              onPressed: _handleGoogle,
                              icon: Image.network('https://cdn-icons-png.flaticon.com/512/300/300221.png', height: 24),
                              label: const Text('الدخول بحساب جوجل', style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            ),
                            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('ليس لديك حساب؟ إنشاء حساب', style: TextStyle(color: Colors.deepPurple))),
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

  Widget _buildField(TextEditingController c, String l, IconData i, {bool pass = false}) {
    return TextField(controller: c, obscureText: pass, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i, color: Colors.deepPurple), filled: true, fillColor: Colors.white.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)));
  }
}
