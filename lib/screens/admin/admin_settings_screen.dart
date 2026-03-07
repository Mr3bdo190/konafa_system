import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  void _addCoupon() async {
    if (_codeCtrl.text.isEmpty || _discountCtrl.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('Coupons').doc(_codeCtrl.text.trim().toUpperCase()).set({
      'discount': int.tryParse(_discountCtrl.text.trim()) ?? 0,
      'isActive': true,
    });
    _codeCtrl.clear();
    _discountCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الكوبون بنجاح! ✅'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F8),
        appBar: AppBar(title: const Text('الإعدادات والكوبونات'), backgroundColor: Colors.orange, centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم وضع الصيانة
              const Text('إعدادات النظام', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Settings').doc('App').snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  bool isMaintenance = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    isMaintenance = snapshot.data!['isMaintenance'] ?? false;
                  }
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: SwitchListTile(
                      activeColor: Colors.red,
                      title: const Text('وضع الصيانة 🛑', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('إغلاق التطبيق أمام العملاء للصيانة.'),
                      value: isMaintenance,
                      onChanged: (val) async {
                        await FirebaseFirestore.instance.collection('Settings').doc('App').set({'isMaintenance': val}, SetOptions(merge: true));
                      },
                    ),
                  );
                },
              ),
              const Divider(height: 40, thickness: 2),

              // قسم الكوبونات
              const Text('إدارة كوبونات الخصم 🎁', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 2, child: TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'كود الخصم (مثال: KONAFA20)', border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'نسبة الخصم %', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _addCoupon,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 45)),
                        child: const Text('إضافة الكوبون', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('الكوبونات النشطة:', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Coupons').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  if (snapshot.data!.docs.isEmpty) return const Text('لا يوجد كوبونات حالياً.');
                  return ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return Card(
                        child: ListTile(
                          title: Text(doc.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          subtitle: Text('خصم: ${doc['discount']}%'),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
