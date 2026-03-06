import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  void _showCustomerDetails(BuildContext context, String userId, Map<String, dynamic> userData) async {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Orders').where('customerId', isEqualTo: userId).get(),
        builder: (context, snapshot) {
          double totalSpent = 0; int ordersCount = 0;
          if (snapshot.hasData) {
            ordersCount = snapshot.data!.docs.length;
            for (var doc in snapshot.data!.docs) {
              if (doc['status'] != 'cancelled') {
                totalSpent += num.tryParse(doc['totalAmount'].toString())?.toDouble() ?? 0.0;
              }
            }
          }
          return Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(radius: 35, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 40, color: Colors.white)),
                    const SizedBox(width: 15),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['name'] ?? 'عميل غير مسجل الاسم', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(userData['phone'] ?? 'بدون رقم', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ))
                  ],
                ),
                const Divider(height: 40, thickness: 1.5),
                _buildInfoRow(Icons.location_on, 'العنوان', userData['address'] ?? 'لم يقم بإضافة عنوان بعد'),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.shopping_bag, 'عدد الطلبات', '$ordersCount طلب'),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.monetization_on, 'إجمالي المدفوعات', '$totalSpent ج.م', color: Colors.green),
                const SizedBox(height: 30),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('إغلاق', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))))
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? color}) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.orange)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.black87))]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('قائمة العملاء'), backgroundColor: Colors.orange, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').where('role', isEqualTo: 'customer').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              padding: const EdgeInsets.all(15), itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var user = snapshot.data!.docs[index]; var data = user.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    title: Text(data['name'] != null && data['name'].toString().isNotEmpty ? data['name'] : 'عميل جديد', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['phone'] ?? 'بدون هاتف', style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                    onTap: () => _showCustomerDetails(context, user.id, data),
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
