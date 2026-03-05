import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('العملاء'), backgroundColor: Colors.orange, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').where('role', isEqualTo: 'customer').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.data!.docs.isEmpty) return const Center(child: Text('لا يوجد عملاء حتى الآن'));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var user = snapshot.data!.docs[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    title: Text(user['name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الهاتف: ${user['phone'] ?? 'غير مسجل'}\nإجمالي المدفوعات: ${user['total_spent'] ?? 0} ج'),
                    isThreeLine: true,
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
