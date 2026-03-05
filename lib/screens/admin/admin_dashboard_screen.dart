import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('لوحة التحكم'), backgroundColor: Colors.orange, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').where('status', isEqualTo: 'completed').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            double totalRevenue = 0;
            int totalOrders = snapshot.data!.docs.length;
            
            for (var doc in snapshot.data!.docs) {
              totalRevenue += num.tryParse(doc['totalAmount'].toString())?.toDouble() ?? 0.0;
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard('إجمالي الأرباح', '$totalRevenue ج', Icons.monetization_on, Colors.green),
                      const SizedBox(width: 15),
                      _buildStatCard('الطلبات المكتملة', '$totalOrders', Icons.check_circle, Colors.blue),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
