import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'customer_cart_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MenuTab(),
    const CustomerCartScreen(),
    const CustomerOrdersScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, -10))]),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed, backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0, currentIndex: _selectedIndex,
              selectedItemColor: Colors.deepPurple, unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) => setState(() => _selectedIndex = index),
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'المنيو'),
                BottomNavigationBarItem(
                  icon: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').snapshots(),
                    builder: (context, snapshot) {
                      int cartCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart_rounded),
                          if (cartCount > 0)
                            Positioned(
                              right: -5, top: -5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                  label: 'السلة',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'طلباتي'),
                const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});
  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'كنافة', 'بسبوسة', 'جلاش', 'مشروبات'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('قائمة كنافة 😋', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                  ),
                  Positioned(right: -50, top: -50, child: Icon(Icons.cake, size: 200, color: Colors.white.withOpacity(0.1))),
                  Positioned(left: -30, bottom: -20, child: Icon(Icons.local_cafe, size: 150, color: Colors.white.withOpacity(0.1))),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              )
            ],
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 130.0,
              maxHeight: 130.0,
              child: Container(
                color: const Color(0xFFF5F3F8),
                child: Column(
                  children: [
                    // تم إصلاح شريط البحث بوضعه داخل Container للظل
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'نفسك في إيه النهاردة؟',
                            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                            filled: true, fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          bool isSelected = _categories[index] == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = _categories[index]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.deepPurple : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [if (isSelected) BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                                border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: 1),
                              ),
                              child: Center(child: Text(_categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.deepPurple, fontWeight: FontWeight.bold))),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SliverFillRemaining(child: Center(child: Text('المنيو فارغ')));

              var products = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                bool matchesCategory = _selectedCategory == 'الكل' || (data['category'] ?? '') == _selectedCategory;
                bool matchesSearch = _searchQuery.isEmpty || (data['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
                return matchesCategory && matchesSearch;
              }).toList();

              return SliverPadding(
                padding: const EdgeInsets.all(15),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 15, mainAxisSpacing: 15),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var itemData = products[index].data() as Map<String, dynamic>;
                      String docId = products[index].id;
                      return ProductCard(itemData: itemData, docId: docId);
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight; final double maxHeight; final Widget child;
  @override double get minExtent => minHeight;
  @override double get maxExtent => maxHeight;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String docId;
  const ProductCard({super.key, required this.itemData, required this.docId});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    String name = widget.itemData['name'] ?? 'بدون اسم';
    String image = widget.itemData['image'] ?? '';
    double price = num.tryParse(widget.itemData['price'].toString())?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(itemData: widget.itemData, docId: widget.docId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'image_${widget.docId}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: image.isNotEmpty
                          ? Image.network(image, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50, color: Colors.grey))
                          : Container(color: Colors.purple.shade50, child: const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.deepPurple))),
                    ),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => isFavorite = !isFavorite),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$price ج', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String docId;
  const ProductDetailsScreen({super.key, required this.itemData, required this.docId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  void _addToCart() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String name = widget.itemData['name'] ?? 'بدون اسم';
    double price = num.tryParse(widget.itemData['price'].toString())?.toDouble() ?? 0.0;
    String image = widget.itemData['image'] ?? '';

    await FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cart').add({
      'name': name, 'price': price, 'image': image, 'quantity': quantity,
    });
    
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة $quantity من ($name) للسلة بنجاح! 🎉'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.itemData['name'] ?? 'بدون اسم';
    String image = widget.itemData['image'] ?? '';
    double price = num.tryParse(widget.itemData['price'].toString())?.toDouble() ?? 0.0;
    String desc = widget.itemData['description'] ?? 'أشهى وألذ الحلويات الشرقية، مصنوعة بحب وعناية لترضي ذوقك.';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Hero(
                tag: 'image_${widget.docId}',
                child: image.isNotEmpty
                    ? Image.network(image, fit: BoxFit.cover)
                    : Container(color: Colors.purple.shade100, child: const Icon(Icons.fastfood, size: 100, color: Colors.deepPurple)),
              ),
            ),
            Positioned(
              top: 40, right: 20,
              child: IconButton(
                icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87))),
                        Text('${price * quantity} ج', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text('التفاصيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 10),
                    Text(desc, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                    
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: () => setState(() { if (quantity > 1) quantity--; }), icon: const Icon(Icons.remove_circle_outline, size: 35, color: Colors.deepPurple)),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                        IconButton(onPressed: () => setState(() { quantity++; }), icon: const Icon(Icons.add_circle, size: 35, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        shadowColor: Colors.deepPurple.withOpacity(0.5)
                      ),
                      child: const Text('إضافة إلى السلة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
