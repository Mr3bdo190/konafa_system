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
        appBar: AppBar(title: const Text('لوحة التحكم والإحصائيات'), backgroundColor: Colors.orange, centerTitle: true, elevation: 0),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
            
            double totalRevenue = 0;
            int totalOrders = snapshot.data!.docs.length;
            int completedOrders = 0;
            int pendingOrders = 0;
            int cancelledOrders = 0;
            
            for (var doc in snapshot.data!.docs) {
              String status = doc['status'] ?? 'pending';
              if (status == 'completed') {
                completedOrders++;
                totalRevenue += num.tryParse(doc['totalAmount'].toString())?.toDouble() ?? 0.0;
              } else if (status == 'cancelled') {
                cancelledOrders++;
              } else {
                pendingOrders++;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // كروت الأرباح
                  Row(
                    children: [
                      _buildStatCard('إجمالي الأرباح', '$totalRevenue ج', Icons.monetization_on, Colors.green),
                      const SizedBox(width: 15),
                      _buildStatCard('إجمالي الطلبات', '$totalOrders', Icons.shopping_bag, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // قسم التحليلات البصرية (رسوم بيانية مبسطة)
                  const Text('مؤشرات الأداء 📊', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                    child: Column(
                      children: [
                        _buildProgressBar('طلبات مكتملة ✅', completedOrders, totalOrders, Colors.green),
                        const SizedBox(height: 15),
                        _buildProgressBar('قيد التجهيز ⏳', pendingOrders, totalOrders, Colors.orange),
                        const SizedBox(height: 15),
                        _buildProgressBar('طلبات ملغية ❌', cancelledOrders, totalOrders, Colors.red),
                      ],
                    ),
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
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String title, int count, int total, Color color) {
    double percentage = total == 0 ? 0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$count طلب (${(percentage * 100).toStringAsFixed(1)}%)', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
