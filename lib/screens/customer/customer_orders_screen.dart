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
                var doc = docs[index];
                var data = doc.data() as Map<String, dynamic>;
                List items = data['items'] ?? [];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3,
                  child: ExpansionTile(
                    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('طلب #${doc.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                    ]),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildTimeline(data['status'] ?? 'pending'),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...items.map((item) => Text('- ${item['name']} (x${item['quantity']})', style: const TextStyle(color: Colors.black87))),
                            
                            // نظام التقييم يظهر فقط لو الطلب مكتمل
                            if (data['status'] == 'completed') ...[
                              const Divider(height: 30),
                              Center(
                                child: data['rating'] == null 
                                ? Column(
                                    children: [
                                      const Text('ما رأيك في الأوردر؟', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(5, (starIndex) => IconButton(
                                          icon: const Icon(Icons.star_border, color: Colors.orange, size: 35),
                                          onPressed: () {
                                            doc.reference.update({'rating': starIndex + 1});
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك! ❤️'), backgroundColor: Colors.green));
                                          },
                                        )),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('تقييمك: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ...List.generate(5, (starIndex) => Icon(
                                        starIndex < (data['rating'] as int) ? Icons.star : Icons.star_border, 
                                        color: Colors.orange, size: 20
                                      ))
                                    ],
                                  )
                              )
                            ]
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
