import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F3F8),
          appBar: AppBar(
            title: const Text('إدارة الطلبات'), backgroundColor: Colors.orange, centerTitle: true,
            bottom: const TabBar(
              indicatorColor: Colors.white, indicatorWeight: 4, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [Tab(text: 'جديدة 🆕'), Tab(text: 'تجهيز ⏳'), Tab(text: 'مكتملة ✅')],
            ),
          ),
          body: const TabBarView(
            children: [
              OrdersList(statusFilter: 'pending'),
              OrdersList(statusFilter: 'accepted'),
              OrdersList(statusFilter: 'completed_or_cancelled'),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String statusFilter;
  const OrdersList({super.key, required this.statusFilter});

  void _updateStatus(DocumentReference doc, String status) {
    doc.update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var docs = snapshot.data!.docs.where((doc) {
          String s = doc['status'] ?? '';
          if (statusFilter == 'completed_or_cancelled') return s == 'completed' || s == 'cancelled';
          return s == statusFilter;
        }).toList();

        if (docs.isEmpty) return const Center(child: Text('لا يوجد طلبات في هذا القسم'));

        // الترتيب من الأحدث للأقدم
        docs.sort((a, b) {
          var tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          var tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          return (tB ?? Timestamp.now()).compareTo(tA ?? Timestamp.now());
        });

        return ListView.builder(
          padding: const EdgeInsets.all(15), itemCount: docs.length,
          itemBuilder: (context, index) {
            var order = docs[index]; var data = order.data() as Map<String, dynamic>;
            List items = data['items'] ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('طلب #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 18)),
                      ],
                    ),
                    const Divider(),
                    Text('تفاصيل العميل:', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                    Text('${data['customerName']} - ${data['customerPhone']}\nالعنوان/الاستلام: ${data['deliveryDetails']}'),
                    const SizedBox(height: 10),
                    Text('المنتجات:', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                    ...items.map((item) => Text('- ${item['name']} (الكمية: ${item['quantity']})')),
                    const SizedBox(height: 15),
                    
                    // أزرار التحكم حسب الحالة
                    if (statusFilter == 'pending') Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'accepted'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('قبول وتجهيز', style: TextStyle(color: Colors.white)))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'cancelled'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('إلغاء الطلب', style: TextStyle(color: Colors.white)))),
                      ],
                    ),
                    if (statusFilter == 'accepted') SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'completed'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('تم التسليم (إنهاء الطلب)', style: TextStyle(color: Colors.white)))),
                    if (statusFilter == 'completed_or_cancelled') Center(child: Text(data['status'] == 'completed' ? '✅ اكتمل بنجاح' : '❌ تم الإلغاء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: data['status'] == 'completed' ? Colors.green : Colors.red))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
