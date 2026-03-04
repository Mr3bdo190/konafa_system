import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'customer_cart_screen.dart';
import 'customer_orders_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'كنافة', 'بسبوسة', 'جلاش', 'مشروبات'];

  // الصفحات الخاصة بالعميل
  final List<Widget> _pages = [
    const MenuTab(), // واجهة المنيو (مدمجة بالأسفل)
    const CustomerCartScreen(), // شاشة السلة
    const CustomerOrdersScreen(), // شاشة تتبع الطلبات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.deepPurple.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.white.withOpacity(0.9),
              elevation: 0,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'المنيو'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلباتي'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// تصميم واجهة المنيو الزجاجية (الرئيسية)
// ==========================================
class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'كنافة', 'بسبوسة', 'جلاش', 'مشروبات'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // الخلفية الدائرية الموف
          Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade200.withOpacity(0.5)))),
          Positioned(bottom: -100, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade300.withOpacity(0.4)))),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شريط العنوان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مرحباً بك في كنافة 😋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                      )
                    ],
                  ),
                ),
                
                // تصنيفات المنيو
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _categories[index] == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = _categories[index]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.deepPurple : Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              style: TextStyle(color: isSelected ? Colors.white : Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 15),

                // عرض المنتجات بشكل آمن
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) return const Center(child: Text('حدث خطأ في تحميل البيانات'));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('المنيو فارغ حالياً', style: TextStyle(fontSize: 20, color: Colors.grey)));

                      // فلترة المنتجات حسب التصنيف
                      var products = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        if (_selectedCategory == 'الكل') return true;
                        return (data['category'] ?? '') == _selectedCategory;
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // لتجنب تداخل النصوص والصور
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var itemData = products[index].data() as Map<String, dynamic>;
                          
                          // الحماية القوية ضد أخطاء قاعدة البيانات (لمنع الشاشة الرمادية)
                          String name = itemData.containsKey('name') ? itemData['name'] : 'بدون اسم';
                          String image = itemData.containsKey('image') ? itemData['image'] : '';
                          // تحويل السعر بأمان سواء كان int أو double
                          double price = itemData.containsKey('price') ? (itemData['price'] is int ? (itemData['price'] as int).toDouble() : itemData['price']) : 0.0;

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: image.isNotEmpty
                                          ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                                          : const Icon(Icons.fastfood, size: 50, color: Colors.deepPurple),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('$price ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                                              InkWell(
                                                onTap: () async {
                                                  // إضافة للسلة
                                                  String uid = FirebaseAuth.instance.currentUser!.uid;
                                                  await FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').add({
                                                    'name': name,
                                                    'price': price,
                                                    'image': image,
                                                    'quantity': 1,
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة $name للسلة'), backgroundColor: Colors.green));
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(10)),
                                                  child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
