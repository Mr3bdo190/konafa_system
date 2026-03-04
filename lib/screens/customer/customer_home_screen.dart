import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text('نظام كنافة - القائمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // تجاهل الخطأ التحذيري الخاص بالـ context عن طريق التأكد من وجوده
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildMenu(),
      ),
    );
  }

  Widget _buildMenu() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // 1. حماية ضد أخطاء الاتصال (تمنع الشاشة الرمادية)
        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ في تحميل القائمة', style: TextStyle(color: Colors.red, fontSize: 18)));
        }

        // 2. حماية أثناء التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        // 3. حماية لو القائمة فاضية
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 15),
                Text('القائمة فارغة حالياً', style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        // 4. عرض المنتجات بشكل آمن
        return GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // نسبة الطول للعرض (مهمة لمنع تداخل العناصر)
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var item = snapshot.data!.docs[index];
            
            // حماية ضد القيم المفقودة من قاعدة البيانات
            String name = item.data().toString().contains('name') ? item['name'] : 'منتج جديد';
            double price = item.data().toString().contains('price') ? double.parse(item['price'].toString()) : 0.0;
            String image = item.data().toString().contains('image') ? item['image'] : '';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // صورة المنتج
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: image.isNotEmpty
                          ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                          : _buildPlaceholder(),
                    ),
                  ),
                  // تفاصيل المنتج
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text('$price ج.م', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ودجت بديل لو الصورة مش موجودة أو فيها خطأ
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.purple.shade50,
      child: Icon(Icons.restaurant, size: 50, color: Colors.deepPurple.shade200),
    );
  }
}
