import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text('قائمة العملاء', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade100.withOpacity(0.4)))),
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Users').where('role', isEqualTo: 'customer').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا يوجد عملاء حتى الآن', style: TextStyle(fontSize: 18, color: Colors.deepPurple)));

                final customers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(radius: 25, backgroundColor: Colors.deepPurple.shade200, child: const Icon(Icons.person, color: Colors.white, size: 30)),
                        title: Text(customer['name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(children: [const Icon(Icons.phone, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(customer['phone'] ?? '')]),
                            const SizedBox(height: 5),
                            Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 5), Expanded(child: Text(customer['address'] ?? '', overflow: TextOverflow.ellipsis))]),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${customer['total_orders'] ?? 0} أوردر', style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text('${customer['total_spent'] ?? 0} ج.م', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
