import 'admin_branches_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8), elevation: 0, centerTitle: true,
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
              padding: const EdgeInsets.all(20), crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
              children: [
                // كارت الطلبات مع الإشعارات
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('Orders').where('status', isEqualTo: 'pending').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    int newOrdersCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _buildDashboardCard(context, 'الطلبات', Icons.receipt_long, Colors.orange, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
                    }, badgeCount: newOrdersCount);
                  }
                ),
                _buildDashboardCard(context, 'إدارة المنيو', Icons.restaurant_menu, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMenuScreen()));
                }),
                _buildDashboardCard(context, 'العملاء', Icons.people, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomersScreen()));
                }),
                _buildDashboardCard(context, 'الفروع', Icons.storefront, Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBranchesScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {int badgeCount = 0}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5)),
                child: Center(
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
          ),
          // الإشعار الأحمر لو فيه طلبات جديدة
          if (badgeCount > 0)
            Positioned(
              top: -5, left: -5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
