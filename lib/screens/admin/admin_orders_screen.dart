import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text('إدارة الطلبات', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade200.withOpacity(0.5)))),
            Positioned(bottom: -100, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade300.withOpacity(0.4)))),
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Orders').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد طلبات حالياً', style: TextStyle(fontSize: 18, color: Colors.deepPurple)));

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final data = order.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    
                    String statusText = 'قيد المراجعة';
                    Color statusColor = Colors.orange;
                    if (status == 'preparing') { statusText = 'جاري التجهيز'; statusColor = Colors.blue; } 
                    else if (status == 'delivered') { statusText = 'تم التوصيل'; statusColor = Colors.green; }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('العميل: ${data['customerName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                                Chip(label: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), backgroundColor: statusColor),
                              ],
                            ),
                            const Divider(),
                            Text('نوع الطلب: ${data['orderType'] == 'delivery' ? 'توصيل' : 'استلام من الفرع'}', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                            Text('التفاصيل: ${data['deliveryDetails']}', style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 10),
                            Text('الإجمالي: ${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
                            const SizedBox(height: 15),
                            
                            // أزرار تغيير حالة الطلب
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (status == 'pending')
                                  ElevatedButton.icon(
                                    onPressed: () => FirebaseFirestore.instance.collection('Orders').doc(order.id).update({'status': 'preparing'}),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    icon: const Icon(Icons.soup_kitchen, color: Colors.white),
                                    label: const Text('بدء التجهيز', style: TextStyle(color: Colors.white)),
                                  ),
                                if (status == 'preparing')
                                  ElevatedButton.icon(
                                    onPressed: () => FirebaseFirestore.instance.collection('Orders').doc(order.id).update({'status': 'delivered'}),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    icon: const Icon(Icons.check_circle, color: Colors.white),
                                    label: const Text('تم التوصيل', style: TextStyle(color: Colors.white)),
                                  ),
                                if (status == 'delivered')
                                  const Text('الطلب مكتمل ✔', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
