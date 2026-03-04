import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  // القائمة دي لازم تكون نفس اللي عند العميل بالظبط
  final List<String> _categories = ['كنافة', 'بسبوسة', 'جلاش', 'مشروبات'];
  
  void _showAddEditDialog([DocumentSnapshot? document]) {
    final nameCtrl = TextEditingController(text: document != null ? document['name'] : '');
    final priceCtrl = TextEditingController(text: document != null ? document['price'].toString() : '');
    final imageCtrl = TextEditingController(text: document != null ? document['image'] : '');
    
    // التأكد إن التصنيف المختار موجود في القائمة، وإلا نختار أول واحد
    String selectedCategory = (document != null && _categories.contains(document['category'])) 
        ? document['category'] 
        : _categories[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(document == null ? 'إضافة منتج جديد' : 'تعديل المنتج', style: const TextStyle(color: Colors.deepPurple)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج', prefixIcon: Icon(Icons.fastfood))),
                  const SizedBox(height: 10),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.attach_money))),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'التصنيف', prefixIcon: Icon(Icons.category)),
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'رابط الصورة (URL)', prefixIcon: Icon(Icons.image))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

                  // السطر ده هو اللي بيحل المشكلة: توحيد المسميات (Keys) مع العميل
                  Map<String, dynamic> productData = {
                    'name': nameCtrl.text.trim(),
                    'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                    'category': selectedCategory,
                    'image': imageCtrl.text.trim(),
                  };

                  if (document == null) {
                    await FirebaseFirestore.instance.collection('Menu').add(productData);
                  } else {
                    await document.reference.update(productData);
                  }
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green));
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('إدارة المنيو'), backgroundColor: Colors.purple, centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: Colors.purple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة منتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لم تقم بإضافة أي منتجات بعد', style: TextStyle(fontSize: 18, color: Colors.grey)));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                
                String name = data['name'] ?? 'بدون اسم';
                String category = data['category'] ?? 'غير مصنف';
                double price = num.tryParse(data['price'].toString())?.toDouble() ?? 0.0;
                String image = data['image'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image.isNotEmpty 
                        ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood, size: 40, color: Colors.deepPurple))
                        : const Icon(Icons.fastfood, size: 40, color: Colors.deepPurple),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('$category \n$price ج.م', style: const TextStyle(color: Colors.deepPurple)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(doc)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
