import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uploadcare_client/uploadcare_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});
  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برجاء إكمال البيانات واختيار صورة')));
      return;
    }

    setState(() => _isUploading = true);
    try {
      // 1. الرفع إلى Uploadcare
      final client = UploadcareClient(options: ClientOptions(publicKey: AppConstants.uploadcarePublicKey));
      final fileId = await client.upload.base(SharedFile(_selectedImage!));
      final imageUrl = 'https://ucarecdn.com/$fileId/';

      // 2. الحفظ في Firebase
      await FirebaseFirestore.instance.collection('MenuItems').add({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descController.text.trim(),
        'imageUrl': imageUrl,
        'isAvailable': true,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الصنف بنجاح!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ أثناء الحفظ')));
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة صنف جديد'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepPurple)),
                child: _selectedImage == null 
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50), Text('اضغط لاختيار صورة')])
                  : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 30),
            _isUploading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 55)),
                  child: const Text('حفظ الصنف', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
          ],
        ),
      ),
    );
  }
}
