import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  // دي الصفحات اللي هنتنقل بينها (مبدئياً هنحط نصوص مؤقتة لحد ما نصمم كل شاشة)
  final List<Widget> _pages = [
    const Center(child: Text('شاشة المنيو والمنتجات (قريباً)', style: TextStyle(fontSize: 20, color: Colors.deepPurple))),
    const Center(child: Text('سلة المشتريات (قريباً)', style: TextStyle(fontSize: 20, color: Colors.deepPurple))),
    const Center(child: Text('تتبع طلباتي (قريباً)', style: TextStyle(fontSize: 20, color: Colors.deepPurple))),
    const Center(child: Text('إعدادات حسابي (قريباً)', style: TextStyle(fontSize: 20, color: Colors.deepPurple))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8), // نفس الخلفية البيضاء المائلة للموف
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'نظام كنافة',
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.deepPurple),
            onPressed: () {},
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // أشكال جمالية في الخلفية
            Positioned(
              top: 50, right: -50,
              child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100.withOpacity(0.5))),
            ),
            Positioned(
              bottom: 100, left: -50,
              child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade100.withOpacity(0.4))),
            ),
            // محتوى الشاشة المعروضة
            _pages[_currentIndex],
          ],
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey.shade400,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'المنيو'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'السلة'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'طلباتي'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
