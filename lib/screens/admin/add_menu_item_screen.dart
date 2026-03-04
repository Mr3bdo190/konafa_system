import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
  
  XFile? _selectedImage;
  Uint8List? _imageBytes; // لعرض ورفع الصورة على الويب والموبايل
  bool _isUploading = false;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برجاء إكمال البيانات واختيار صورة')));
      return;
    }

    setState(() => _isUploading = true);
    try {
      // 1. الرفع المباشر إلى Uploadcare باستخدام HTTP (يدعم الويب والموبايل)
      var request = http.MultipartRequest('POST', Uri.parse('https://upload.uploadcare.com/base/'));
      request.fields['UPLOADCARE_PUB_KEY'] = AppConstants.uploadcarePublicKey;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: _selectedImage!.name,
      ));

      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        String fileId = jsonResponse['file'];
        String imageUrl = 'https://ucarecdn.com/$fileId/';

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
      } else {
        throw Exception('فشل رفع الصورة');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ أثناء الحفظ. تأكد من الاتصال بالإنترنت')));
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      appBar: AppBar(
        title: const Text('إضافة صنف جديد', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)), 
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.deepPurple, width: 2)),
                  child: _imageBytes == null 
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.deepPurple), SizedBox(height: 10), Text('اضغط لاختيار صورة للصنف', style: TextStyle(color: Colors.deepPurple))])
                    : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.memory(_imageBytes!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'اسم الصنف', Icons.restaurant_menu),
              const SizedBox(height: 15),
              _buildTextField(_priceController, 'السعر (ج.م)', Icons.attach_money, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_descController, 'وصف الصنف', Icons.description, maxLines: 3),
              const SizedBox(height: 30),
              _isUploading 
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 55)),
                    child: const Text('حفظ الصنف', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.deepPurple.shade300) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
