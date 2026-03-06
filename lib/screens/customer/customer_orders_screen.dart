import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  Widget _buildTimeline(String status) {
    int step = status == 'pending' ? 1 : (status == 'accepted' ? 2 : (status == 'completed' ? 3 : 0));
    if (status == 'cancelled') return const Center(child: Text('❌ تم إلغاء الطلب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(step >= 1, 'تم الطلب'), _buildLine(step >= 2),
        _buildDot(step >= 2, 'جاري التجهيز'), _buildLine(step >= 3),
        _buildDot(step >= 3, 'مكتمل ✅'),
      ],
    );
  }

  Widget _buildDot(bool active, String label) {
    return Column(
      children: [
        Container(width: 25, height: 25, decoration: BoxDecoration(color: active ? Colors.deepPurple : Colors.grey[300], shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.deepPurple : Colors.grey)),
      ],
    );
  }

  Widget _buildLine(bool active) {
    return Container(width: 40, height: 3, margin: const EdgeInsets.only(bottom: 20), color: active ? Colors.deepPurple : Colors.grey[300]);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('طلباتي'), backgroundColor: Colors.deepPurple, centerTitle: true, elevation: 0),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').where('customerId', isEqualTo: uid).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            var docs = snapshot.data!.docs.toList();
            if (docs.isEmpty) return const Center(child: Text('لم تقم بأي طلبات بعد 📋', style: TextStyle(fontSize: 20, color: Colors.grey)));

            docs.sort((a, b) {
              var tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              var tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              return (tB ?? Timestamp.now()).compareTo(tA ?? Timestamp.now());
            });

            return ListView.builder(
              padding: const EdgeInsets.all(15), itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                List items = data['items'] ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('طلب #${docs[index].id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                        ]),
                        const SizedBox(height: 15),
                        _buildTimeline(data['status'] ?? 'pending'),
                        const Divider(height: 30),
                        ...items.map((item) => Text('- ${item['name']} (x${item['quantity']})', style: const TextStyle(color: Colors.black87))),
                      ],
                    ),
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
