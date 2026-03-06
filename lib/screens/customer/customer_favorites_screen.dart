import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_home_screen.dart'; // عشان نستخدم نفس تصميم الكارت

class CustomerFavoritesScreen extends StatelessWidget {
  const CustomerFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(
          title: const Text('مفضلاتي ❤️', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').doc(uid).collection('Favorites').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 15),
                    const Text('قائمة مفضلاتك فارغة 💔', style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const Text('اضغط على القلب في المنيو لإضافة منتجاتك', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            var products = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 15, mainAxisSpacing: 15),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var itemData = products[index].data() as Map<String, dynamic>;
                String docId = products[index].id;
                return ProductCard(itemData: itemData, docId: docId);
              },
            );
          },
        ),
      ),
    );
  }
}
