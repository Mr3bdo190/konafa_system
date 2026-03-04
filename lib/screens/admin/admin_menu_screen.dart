import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item_model.dart';
import 'add_menu_item_screen.dart'; // هننشئها الخطوة الجاية

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text('إدارة المنيو', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade100.withOpacity(0.4)))),
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('MenuItems').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('المنيو فارغ، أضف أصنافاً جديدة!', style: TextStyle(fontSize: 18, color: Colors.deepPurple)));
                }

                final menuItems = snapshot.data!.docs.map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item.imageUrl.isNotEmpty
                              ? Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                              : Container(width: 60, height: 60, color: Colors.purple.shade100, child: const Icon(Icons.fastfood, color: Colors.white)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        subtitle: Text('${item.price} ج.م - ${item.isAvailable ? "متاح" : "غير متاح"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            // كود الحذف من فايربيز
                            FirebaseFirestore.instance.collection('MenuItems').doc(item.id).delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMenuItemScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة منتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
