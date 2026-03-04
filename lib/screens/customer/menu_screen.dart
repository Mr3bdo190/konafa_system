import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';

class CustomerMenuScreen extends StatelessWidget {
  const CustomerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // لأن الخلفية موجودة في الـ Home Screen
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('MenuItems').where('isAvailable', isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('جاري إضافة أشهى أصناف الكنافة والحلويات قريباً...', style: TextStyle(fontSize: 18, color: Colors.deepPurple)));
          }

          final menuItems = snapshot.data!.docs.map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildMenuCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.purple.shade100, child: const Icon(Icons.fastfood, size: 50, color: Colors.white)),
                ),
              ),
              // تفاصيل المنتج
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${item.price} ج.م', style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    // زر الإضافة للسلة
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('تم إضافة ${item.name} للسلة'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.deepPurple,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('إضافة للسلة', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
