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
  String _orderType = 'delivery'; // افتراضياً توصيل
  String _selectedBranch = 'فرع بني سويف (الرئيسي)'; // فرع افتراضي
  
  // الفروع المتاحة
  final List<String> _branches = ['فرع بني سويف (الرئيسي)', 'فرع ببا', 'فرع سدس'];

  void _placeOrder(CartProvider cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فارغة!'))); return;
    }
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      String userName = userDoc['name'] ?? 'عميل';
      String userAddress = userDoc['address'] ?? 'بدون عنوان';

      List<Map<String, dynamic>> orderItems = cart.items.values.map((cartItem) {
        return {'productId': cartItem.product.id, 'name': cartItem.product.name, 'price': cartItem.product.price, 'quantity': cartItem.quantity};
      }).toList();

      String deliveryDetails = _orderType == 'delivery' ? 'توصيل إلى: $userAddress' : 'استلام من: $_selectedBranch';

      DocumentReference orderRef = FirebaseFirestore.instance.collection('Orders').doc();
      OrderModel newOrder = OrderModel(
        orderId: orderRef.id, customerId: user.uid, customerName: userName,
        items: orderItems, totalAmount: cart.totalAmount, timestamp: Timestamp.now(),
        orderType: _orderType, deliveryDetails: deliveryDetails,
      );

      await orderRef.set(newOrder.toMap());
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'total_orders': FieldValue.increment(1), 'total_spent': FieldValue.increment(cart.totalAmount),
      });

      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

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
                      final cartItem = cart.items.values.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: Colors.white.withOpacity(0.8),
                        child: ListTile(
                          title: Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          subtitle: Text('الكمية: ${cartItem.quantity} x ${cartItem.product.price} ج.م'),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => cart.removeItem(cartItem.product.id)),
                        ),
                      );
                    },
                  ),
                ),
                
                // قسم اختيار التوصيل أو الاستلام
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: Colors.white.withOpacity(0.4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('توصيل للمنزل'),
                            selected: _orderType == 'delivery',
                            selectedColor: Colors.deepPurple.shade200,
                            onSelected: (val) => setState(() => _orderType = 'delivery'),
                          ),
                          const SizedBox(width: 15),
                          ChoiceChip(
                            label: const Text('استلام من الفرع'),
                            selected: _orderType == 'pickup',
                            selectedColor: Colors.deepPurple.shade200,
                            onSelected: (val) => setState(() => _orderType = 'pickup'),
                          ),
                        ],
                      ),
                      if (_orderType == 'pickup') ...[
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _selectedBranch,
                          isExpanded: true,
                          items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                          onChanged: (val) => setState(() => _selectedBranch = val!),
                        ),
                      ],
                      if (_orderType == 'delivery') ...[
                        const SizedBox(height: 10),
                        const Text('سيتم التوصيل للعنوان المسجل في حسابك', style: TextStyle(color: Colors.deepPurple, fontSize: 12)),
                      ]
                    ],
                  ),
                ),

                // الإجمالي وزر التأكيد
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5))),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الإجمالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                              Text('${cart.totalAmount} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _isLoading ? const CircularProgressIndicator(color: Colors.deepPurple) : ElevatedButton(
                                  onPressed: () => _placeOrder(cart),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 50)),
                                  child: const Text('إتمام الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
