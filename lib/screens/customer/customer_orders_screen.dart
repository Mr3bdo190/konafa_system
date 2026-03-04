import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart'; // القالب الرسمي

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('طلباتي'), backgroundColor: Colors.deepPurple, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').where('customerId', isEqualTo: uid).orderBy('timestamp', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لم تقم بأي طلبات بعد 📋', style: TextStyle(fontSize: 20, color: Colors.grey)));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                // قراءة الطلب باستخدام القالب الرسمي
                var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                OrderModel order = OrderModel.fromMap(data);

                Color statusColor = order.status == 'pending' ? Colors.orange : (order.status == 'accepted' ? Colors.blue : Colors.green);
                String statusText = order.status == 'pending' ? 'قيد الانتظار' : (order.status == 'accepted' ? 'جاري التجهيز' : 'مكتمل');

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text('طلب #${order.orderId.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الإجمالي: ${order.totalAmount} ج.م', style: const TextStyle(color: Colors.deepPurple)),
                    trailing: Chip(label: Text(statusText, style: const TextStyle(color: Colors.white)), backgroundColor: statusColor),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('النوع: ${order.orderType == 'delivery' ? 'توصيل' : 'استلام'} (${order.deliveryDetails})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            ...List.generate(order.items.length, (i) {
                              var item = order.items[i];
                              return Text('- ${item['name']} (x${item['quantity']})');
                            }),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
