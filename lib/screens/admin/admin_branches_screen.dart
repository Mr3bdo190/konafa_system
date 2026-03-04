import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBranchesScreen extends StatelessWidget {
  const AdminBranchesScreen({super.key});

  void _addZone(BuildContext context) {
    final nameCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منطقة توصيل', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنطقة (مثال: فرع سدس - التوصيل)')),
            TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'تكلفة التوصيل (ج.م)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && feeCtrl.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('DeliveryZones').add({
                  'name': nameCtrl.text.trim(),
                  'fee': double.parse(feeCtrl.text.trim()),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مناطق التوصيل والفروع'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addZone(context),
        label: const Text('إضافة منطقة'), icon: const Icon(Icons.add), backgroundColor: Colors.deepPurple,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('DeliveryZones').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final zones = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(15), itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                return Card(
                  child: ListTile(
                    title: Text(zone['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    subtitle: Text('رسوم التوصيل: ${zone['fee']} ج.م'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance.collection('DeliveryZones').doc(zone.id).delete(),
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
