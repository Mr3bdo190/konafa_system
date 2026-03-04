import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_profile_screen.dart';
import '../../providers/cart_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CustomerMenuScreen(),
    const CustomerCartScreen(),
    const CustomerOrdersScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(backgroundColor: Colors.white.withOpacity(0.8), elevation: 0, centerTitle: true, title: const Text('نظام كنافة', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 24))),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(top: 50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100.withOpacity(0.5)))),
            Positioned(bottom: 100, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade100.withOpacity(0.4)))),
            _pages[_currentIndex],
          ],
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  selectedItemColor: Colors.deepPurple,
                  unselectedItemColor: Colors.grey.shade400,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  items: [
                    const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'المنيو'),
                    BottomNavigationBarItem(
                      // هنا إضافة الإشعار الأحمر على السلة
                      icon: Badge(
                        label: Text(cart.itemCount.toString(), style: const TextStyle(color: Colors.white)),
                        isLabelVisible: cart.itemCount > 0, // يظهر بس لو السلة فيها حاجة
                        child: const Icon(Icons.shopping_cart_rounded),
                      ),
                      label: 'السلة',
                    ),
                    const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'طلباتي'),
                    const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}
