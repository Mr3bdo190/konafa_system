import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('يرجى تسجيل الدخول لعرض الطلبات'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        // جلب طلبات العميل الحالي فقط، مرتبة بالأحدث
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('customerId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لم تقم بأي طلبات حتى الآن، المنيو في انتظارك!', 
              style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              
              // تحديد لون وحالة الطلب
              String statusText = 'قيد المراجعة';
              Color statusColor = Colors.orange;
              IconData statusIcon = Icons.access_time;

              if (status == 'preparing') {
                statusText = 'جاري التجهيز';
                statusColor = Colors.blue;
                statusIcon = Icons.soup_kitchen;
              } else if (status == 'delivered') {
                statusText = 'تم التوصيل';
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
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
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('طلب #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                              Chip(
                                label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                backgroundColor: statusColor,
                                avatar: Icon(statusIcon, color: Colors.white, size: 16),
                              )
                            ],
                          ),
                          const Divider(),
                          Text('الإجمالي: ${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text('عدد الأصناف: ${(data['items'] as List).length}', style: TextStyle(color: Colors.grey.shade800)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
