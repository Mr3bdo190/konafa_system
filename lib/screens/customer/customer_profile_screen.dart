import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').doc(user.uid).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('تعذر تحميل البيانات'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // صورة البروفايل (أيقونة)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple.shade200,
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(userData['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                Text(userData['phone'] ?? '', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                const SizedBox(height: 30),

                // كروت الإحصائيات (عدد الطلبات والمبالغ)
                Row(
                  children: [
                    Expanded(child: _buildStatCard('عدد الطلبات', '${userData['total_orders'] ?? 0}', Icons.shopping_bag)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard('إجمالي المدفوعات', '${userData['total_spent'] ?? 0} ج.م', Icons.account_balance_wallet)),
                  ],
                ),
                const SizedBox(height: 40),

                // زر تسجيل الخروج
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple.shade300),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              const SizedBox(height: 5),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade800), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
