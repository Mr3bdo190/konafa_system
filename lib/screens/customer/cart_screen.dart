import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});
  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  bool _isLoading = false;
  String _orderType = 'pickup'; // استلام من الفرع افتراضياً عشان مفيش رسوم
  String? _selectedZoneName;
  double _deliveryFee = 0.0;

  void _placeOrder(CartProvider cart) async {
    if (cart.items.isEmpty) return;
    if (_orderType == 'delivery' && _selectedZoneName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برجاء اختيار منطقة التوصيل')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      
      List<Map<String, dynamic>> orderItems = cart.items.values.map((item) => {
        'name': item.product.name, 'price': item.product.price, 'quantity': item.quantity
      }).toList();

      double finalTotal = cart.totalAmount + (_orderType == 'delivery' ? _deliveryFee : 0);
      String deliveryDetails = _orderType == 'delivery' ? 'توصيل إلى: ${_selectedZoneName} - ${userDoc['address']}' : 'استلام من الفرع';

      OrderModel newOrder = OrderModel(
        orderId: FirebaseFirestore.instance.collection('Orders').doc().id,
        customerId: user.uid, customerName: userDoc['name'],
        items: orderItems, totalAmount: finalTotal, timestamp: Timestamp.now(),
        orderType: _orderType, deliveryDetails: deliveryDetails,
      );

      await FirebaseFirestore.instance.collection('Orders').doc(newOrder.orderId).set(newOrder.toMap());
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'total_orders': FieldValue.increment(1), 'total_spent': FieldValue.increment(finalTotal)});
      
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح!')));
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double finalTotal = cart.totalAmount + (_orderType == 'delivery' ? _deliveryFee : 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: cart.items.isEmpty
          ? const Center(child: Text('سلة المشتريات فارغة!', style: TextStyle(fontSize: 18, color: Colors.deepPurple)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return Card(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), child: ListTile(title: Text(item.product.name), subtitle: Text('${item.quantity} x ${item.product.price}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cart.removeItem(item.product.id))));
                    },
                  ),
                ),
                
                // خيارات التوصيل
                Container(
                  color: Colors.white.withOpacity(0.6), padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(label: const Text('استلام'), selected: _orderType == 'pickup', onSelected: (v) => setState((){ _orderType = 'pickup'; _deliveryFee = 0.0; })),
                          const SizedBox(width: 15),
                          ChoiceChip(label: const Text('توصيل'), selected: _orderType == 'delivery', onSelected: (v) => setState(() => _orderType = 'delivery')),
                        ],
                      ),
                      if (_orderType == 'delivery')
                        StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('DeliveryZones').snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                            if (!snap.hasData) return const SizedBox();
                            return DropdownButton<String>(
                              hint: const Text('اختر منطقتك'), value: _selectedZoneName, isExpanded: true,
                              items: snap.data!.docs.map((doc) => DropdownMenuItem(value: doc['name'] as String, child: Text('${doc['name']} (+${doc['fee']} ج.م)'))).toList(),
                              onChanged: (val) {
                                final selectedDoc = snap.data!.docs.firstWhere((doc) => doc['name'] == val);
                                setState(() { _selectedZoneName = val; _deliveryFee = (selectedDoc['fee'] as num).toDouble(); });
                              },
                            );
                          }
                        )
                    ],
                  ),
                ),

                // الإجمالي
                Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع:'), Text('${cart.totalAmount} ج.م')]),
                      if (_orderType == 'delivery') Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('التوصيل:'), Text('$_deliveryFee ج.م')]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي النهائي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('$finalTotal ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple))]),
                      const SizedBox(height: 15),
                      _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: () => _placeOrder(cart), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('تأكيد الطلب')),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
