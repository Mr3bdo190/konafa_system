import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final List<String> _categories = ['كنافة', 'بسبوسة', 'جلاش', 'مشروبات'];
  final String uploadcarePubKey = '39809a4a474e7c3b79e1';
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(StateSetter setDialogState, TextEditingController imageCtrl) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setDialogState(() => _isUploading = true);
      try {
        var request = http.MultipartRequest('POST', Uri.parse('https://upload.uploadcare.com/base/'));
        request.fields['UPLOADCARE_PUB_KEY'] = uploadcarePubKey;
        request.fields['UPLOADCARE_STORE'] = '1';
        
        var bytes = await image.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: image.name);
        request.files.add(multipartFile);
        
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var json = jsonDecode(responseData);
          // الحل هنا: إضافة /-/preview/ عشان الصورة تظهر كصورة واضحة للمستخدم
          String fileUrl = 'https://ucarecdn.com/${json['file']}/-/preview/'; 
          imageCtrl.text = fileUrl;
        }
      } catch (e) {
        print("خطأ في الرفع: $e");
      }
      setDialogState(() => _isUploading = false);
    }
  }

  void _showAddEditDialog([DocumentSnapshot? document]) {
    final nameCtrl = TextEditingController(text: document != null ? document['name'] : '');
    final priceCtrl = TextEditingController(text: document != null ? document['price'].toString() : '');
    final imageCtrl = TextEditingController(text: document != null ? document['image'] : '');
    
    String selectedCategory = (document != null && _categories.contains(document['category'])) 
        ? document['category'] : _categories[0];

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: imageCtrl, 
                          decoration: const InputDecoration(labelText: 'رابط الصورة', prefixIcon: Icon(Icons.link), filled: true, fillColor: Colors.white),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _isUploading 
                          ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.deepPurple))
                          : Container(
                              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(15)),
                              child: IconButton(
                                icon: const Icon(Icons.add_photo_alternate, color: Colors.deepPurple, size: 30),
                                tooltip: 'رفع صورة',
                                onPressed: () => _pickAndUploadImage(setDialogState, imageCtrl),
                              ),
                            )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _isUploading ? null : () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
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
        appBar: AppBar(title: const Text('إدارة المنيو'), backgroundColor: Colors.orange, centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة منتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('المنيو فارغ', style: TextStyle(fontSize: 18, color: Colors.grey)));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
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
                        ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood, size: 40, color: Colors.orange))
                        : const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                    ),
                    title: Text(data['name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${data['category']} \n${data['price']} ج.م', style: const TextStyle(color: Colors.orange)),
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
