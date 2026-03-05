import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';

class AdminHomeWrapper extends StatefulWidget {
  const AdminHomeWrapper({super.key});
  @override
  State<AdminHomeWrapper> createState() => _AdminHomeWrapperState();
}

class _AdminHomeWrapperState extends State<AdminHomeWrapper> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminOrdersScreen(),
    const AdminMenuScreen(),
    const AdminCustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'المنيو'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        mini: true,
        child: const Icon(Icons.logout, color: Colors.white),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
