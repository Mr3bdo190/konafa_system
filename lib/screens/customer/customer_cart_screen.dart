import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});
  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  final _couponCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  double _discountPercentage = 0.0;
  String _appliedCoupon = '';
  bool _isProcessing = false;

  void _applyCoupon() async {
    String code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    
    var doc = await FirebaseFirestore.instance.collection('Coupons').doc(code).get();
    if (doc.exists && doc.data()!['isActive'] == true) {
      setState(() {
        _discountPercentage = (doc.data()!['discount'] ?? 0).toDouble();
        _appliedCoupon = code;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('مبروك! تم تفعيل خصم $_discountPercentage% 🎉'), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكود غير صحيح أو منتهي الصلاحية ❌'), backgroundColor: Colors.red));
    }
  }

  void _checkout(double finalTotal, List<Map<String, dynamic>> items) async {
    setState(() => _isProcessing = true);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    
    var userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    String name = userDoc['name'] ?? 'عميل';
    String phone = userDoc['phone'] ?? 'غير مسجل';
    String address = userDoc['address'] ?? 'استلام من الفرع';

    await FirebaseFirestore.instance.collection('Orders').add({
      'customerId': uid,
      'customerName': name,
      'customerPhone': phone,
      'deliveryDetails': address,
      'items': items,
      'totalAmount': finalTotal,
      'discountApplied': _discountPercentage,
      'status': 'pending',
      'orderType': address == 'استلام من الفرع' ? 'pickup' : 'delivery',
      'deliveryNotes': _notesCtrl.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // مسح السلة
    var cartDocs = await FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }

    setState(() => _isProcessing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح! 🚀'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('سلة المشتريات 🛒'), backgroundColor: Colors.deepPurple, centerTitle: true, elevation: 0),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('سلتك فارغة، اطلب دلوقتي! 😋', style: TextStyle(fontSize: 20, color: Colors.grey)));

            double subTotal = 0;
            List<Map<String, dynamic>> cartItems = [];
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              subTotal += (data['price'] * data['quantity']);
              cartItems.add({'name': data['name'], 'quantity': data['quantity'], 'price': data['price']});
            }

            double discountAmount = subTotal * (_discountPercentage / 100);
            double finalTotal = subTotal - discountAmount;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(data['image'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood))),
                          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${data['price']} ج.م x ${data['quantity']}'),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _couponCtrl, decoration: InputDecoration(hintText: 'عندك كود خصم؟', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)))),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: _applyCoupon, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20)), child: const Text('تفعيل', style: TextStyle(color: Colors.white))),
                        ],
                      ),
                      if (_discountPercentage > 0) Padding(padding: const EdgeInsets.only(top: 10), child: Text('تم تطبيق خصم $_discountPercentage% (كود: $_appliedCoupon)', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      const Divider(height: 30, thickness: 2),
                      TextField(controller: _notesCtrl, decoration: InputDecoration(hintText: 'ملاحظات للطيار (مثال: بجوار صيدلية كذا)', filled: true, fillColor: Colors.orange.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.directions_bike, color: Colors.orange))), const SizedBox(height: 15),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع:', style: TextStyle(fontSize: 18, color: Colors.grey)), Text('$subTotal ج', style: const TextStyle(fontSize: 18, decoration: TextDecoration.lineThrough, color: Colors.grey))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي بعد الخصم:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('$finalTotal ج', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.deepPurple))]),
                      const SizedBox(height: 20),
                      _isProcessing 
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _checkout(finalTotal, cartItems),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            child: const Text('تأكيد الطلب والدفع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
