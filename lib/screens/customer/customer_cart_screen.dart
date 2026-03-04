import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  String _orderType = 'توصيل';
  String _deliveryArea = 'المنطقة الأولى';
  final List<String> _areas = ['المنطقة الأولى', 'المنطقة الثانية', 'المنطقة الثالثة'];
  final TextEditingController _notesCtrl = TextEditingController();

  void _placeOrder(List<QueryDocumentSnapshot> cartItems, double total) async {
    if (cartItems.isEmpty) return;
    
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    
    // 1. إنشاء الطلب
    await FirebaseFirestore.instance.collection('Orders').add({
      'customerId': user.uid,
      'customerName': userData['name'] ?? 'عميل',
      'customerPhone': userData['phone'] ?? '',
      'customerAddress': userData['address'] ?? '',
      'items': cartItems.map((item) => item.data()).toList(),
      'totalAmount': total,
      'orderType': _orderType,
      'deliveryDetails': _orderType == 'توصيل' ? _deliveryArea : 'استلام من الفرع',
      'notes': _notesCtrl.text.trim(),
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. تفريغ السلة بعد الطلب
    for (var doc in cartItems) {
      await doc.reference.delete();
    }
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح! 🎉'), backgroundColor: Colors.green));
    _notesCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('سلة المشتريات'), backgroundColor: Colors.deepPurple, centerTitle: true),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('السلة فارغة 🛒', style: TextStyle(fontSize: 20, color: Colors.grey)));

            var cartItems = snapshot.data!.docs;
            double total = 0;
            for (var doc in cartItems) {
              var data = doc.data() as Map<String, dynamic>;
              double price = data['price'] is int ? (data['price'] as int).toDouble() : data['price'] ?? 0.0;
              int qty = data['quantity'] ?? 1;
              total += price * qty;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      var data = item.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          title: Text(data['name'] ?? 'منتج', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${data['price']} ج.م x ${data['quantity']}', style: const TextStyle(color: Colors.deepPurple)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => item.reference.delete(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // منطقة تفاصيل الدفع والطلب
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('$total ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: RadioListTile(title: const Text('توصيل'), value: 'توصيل', groupValue: _orderType, onChanged: (v) => setState(() => _orderType = v.toString()))),
                          Expanded(child: RadioListTile(title: const Text('استلام'), value: 'استلام', groupValue: _orderType, onChanged: (v) => setState(() => _orderType = v.toString()))),
                        ],
                      ),
                      if (_orderType == 'توصيل')
                        DropdownButtonFormField(
                          value: _deliveryArea,
                          items: _areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                          onChanged: (v) => setState(() => _deliveryArea = v.toString()),
                          decoration: const InputDecoration(labelText: 'منطقة التوصيل', border: OutlineInputBorder()),
                        ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => _placeOrder(cartItems, total),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: const Text('تأكيد وإرسال الطلب', style: TextStyle(fontSize: 18, color: Colors.white)),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
