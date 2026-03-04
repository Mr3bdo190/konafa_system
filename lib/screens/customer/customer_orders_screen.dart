import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('طلباتي السابقة'), backgroundColor: Colors.deepPurple, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').where('customerId', isEqualTo: uid).orderBy('timestamp', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لم تقم بأي طلبات بعد 📋', style: TextStyle(fontSize: 20, color: Colors.grey)));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var order = snapshot.data!.docs[index];
                var data = order.data() as Map<String, dynamic>;
                String status = data['status'] ?? 'pending';
                Color statusColor = status == 'pending' ? Colors.orange : (status == 'accepted' ? Colors.blue : Colors.green);
                String statusText = status == 'pending' ? 'قيد الانتظار' : (status == 'accepted' ? 'جاري التجهيز' : 'مكتمل');

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text('طلب #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الإجمالي: ${data['totalAmount']} ج.م', style: const TextStyle(color: Colors.deepPurple)),
                    trailing: Chip(label: Text(statusText, style: const TextStyle(color: Colors.white)), backgroundColor: statusColor),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('نوع الطلب: ${data['orderType']} (${data['deliveryDetails']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            ...List.generate((data['items'] as List).length, (i) {
                              var item = (data['items'] as List)[i];
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
