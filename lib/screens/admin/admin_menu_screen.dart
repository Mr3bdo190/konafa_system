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
  bool _isUploading = false;
  
  final String cloudName = 'dtrtgbtss';
  final String uploadPreset = 'konafa_system';

  Future<void> _pickAndUploadImage(StateSetter setDialogState, TextEditingController imageCtrl) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setDialogState(() => _isUploading = true);
      try {
        var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', image.path));
        
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          var json = jsonDecode(responseData);
          String fileUrl = json['secure_url']; 
          imageCtrl.text = fileUrl;
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع الصورة بنجاح! ✅'), backgroundColor: Colors.green));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الرفع ❌: ${response.statusCode}'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e'), backgroundColor: Colors.red));
      }
      setDialogState(() => _isUploading = false);
    }
  }

  void _showAddEditDialog([DocumentSnapshot? document]) {
    final nameCtrl = TextEditingController(text: document != null ? document['name'] : '');
    final priceCtrl = TextEditingController(text: document != null ? document['price'].toString() : '');
    final descCtrl = TextEditingController(text: document != null ? document['description'] : ''); 
    final imageCtrl = TextEditingController(text: document != null ? document['image'] : '');
    bool isAvailable = document != null ? (document.data() as Map<String, dynamic>)['isAvailable'] ?? true : true;
    String selectedCategory = (document != null && _categories.contains(document['category'])) ? document['category'] : _categories[0];

    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(document == null ? 'إضافة منتج' : 'تعديل المنتج', style: const TextStyle(color: Colors.deepPurple)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج', prefixIcon: Icon(Icons.fastfood))),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.attach_money))),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف المنتج (المكونات والتفاصيل)', prefixIcon: Icon(Icons.description))),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory, decoration: const InputDecoration(labelText: 'التصنيف', prefixIcon: Icon(Icons.category)),
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('متوفر للطلب؟', style: TextStyle(fontWeight: FontWeight.bold)),
                    activeColor: Colors.green, value: isAvailable,
                    onChanged: (val) => setDialogState(() => isAvailable = val),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'رابط الصورة', prefixIcon: Icon(Icons.link), filled: true, fillColor: Colors.white), style: const TextStyle(fontSize: 12))),
                      const SizedBox(width: 10),
                      _isUploading ? const CircularProgressIndicator(color: Colors.deepPurple) : IconButton(icon: const Icon(Icons.add_photo_alternate, color: Colors.deepPurple, size: 30), onPressed: () => _pickAndUploadImage(setDialogState, imageCtrl))
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
                    'name': nameCtrl.text.trim(), 'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                    'description': descCtrl.text.trim(), 
                    'category': selectedCategory, 'image': imageCtrl.text.trim(), 'isAvailable': isAvailable,
                  };
                  if (document == null) await FirebaseFirestore.instance.collection('Menu').add(productData);
                  else await document.reference.update(productData);
                  if (!context.mounted) return; Navigator.pop(context);
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
        floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddEditDialog(), backgroundColor: Colors.orange, icon: const Icon(Icons.add, color: Colors.white), label: const Text('إضافة منتج')),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              padding: const EdgeInsets.all(15), itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index]; var data = doc.data() as Map<String, dynamic>;
                String image = data['image'] ?? ''; bool isAvail = data['isAvailable'] ?? true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image.isNotEmpty && image.startsWith('http') 
                        ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, color: Colors.grey)) 
                        : const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                    ),
                    title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${data['price']} ج.م \n${isAvail ? '✅ متوفر' : '❌ نفذت الكمية'}', style: TextStyle(color: isAvail ? Colors.green : Colors.red)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                    ]),
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
