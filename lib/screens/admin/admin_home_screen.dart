import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_orders_screen.dart'; // استدعاء شاشة الطلبات
import 'admin_customers_screen.dart'; // استدعاء شاشة العملاء

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text('لوحة الإدارة', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: 50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100.withOpacity(0.5)))),
            Positioned(bottom: 100, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade100.withOpacity(0.4)))),
            
            GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildDashboardCard(context, 'الطلبات', Icons.receipt_long, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen())); // تم التفعيل
                }),
                _buildDashboardCard(context, 'إدارة المنيو', Icons.restaurant_menu, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMenuScreen()));
                }),
                _buildDashboardCard(context, 'العملاء', Icons.people, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomersScreen())); // تم التفعيل
                }),
                _buildDashboardCard(context, 'الفروع', Icons.storefront, Colors.teal, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إدارة الفروع - قريباً')));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 35, backgroundColor: color.withOpacity(0.2), child: Icon(icon, size: 35, color: color)),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
